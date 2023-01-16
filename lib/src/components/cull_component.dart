import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:sashimi/sashimi.dart';

/// {@template cull_component}
/// A component that culls its children based on whether they are inside the
/// screen or not.
/// {@endtemplate}
class CullComponent<T extends SashimiOwner> extends Component
    with HasGameRef<SashimiGame>, HasAncestor<SashimiEngine> {
  /// {@macro cull_component}
  CullComponent({
    bool cullingEnabled = false,
  }) : _cullingEnabled = cullingEnabled;

  /// List of inactive components that are not visible.
  final List<T> _inactive = [];

  /// List of active components that are visible.
  late final List<T> _active;

  /// The camera of the engine.
  CameraComponent get camera => ancestor.camera;

  /// If culling is enabled for this component.
  bool get cullingEnabled => _cullingEnabled;
  set cullingEnabled(bool value) {
    _cullingEnabled = value;

    // If culling got disabled, add all the culled components to the engine.
    if (!_cullingEnabled) {
      _inactive
        ..forEach(super.add)
        ..clear();
    }
  }

  bool _cullingEnabled;

  @override
  FutureOr<void> onLoad() {
    children.register<T>();
    _active = children.query<T>();
    return super.onLoad();
  }

  /// Adds a component to the component.
  ///
  /// If culling is disabled, it will be immediately added otherwise it will be
  /// added to the list of culled components so it can be checked later.
  Future<void> addComponent(T component) async {
    if (!cullingEnabled) return super.add(component);
    return _inactive.add(component);
  }

  @override
  Future<void> add(Component component) {
    throw UnsupportedError(
      '''Cannot directly add components to a CullComponent, use addComponent instead''',
    );
  }

  @override
  void update(double dt) {
    if (!cullingEnabled) return;

    // Remove active components that are no longer visible.
    for (final component in _active) {
      if (camera.canSee(component)) continue;
      _inactive.add(component);
      remove(component);
    }

    // Add non-active components that have become visible.
    for (final component in _inactive.where((c) => c.parent == null).toList()) {
      if (!camera.canSee(component)) continue;
      _inactive.remove(component);
      super.add(component); // Bypass unimplemented add method.
    }

    // Reorder all children to ensure their priorities are correct after adding.
    reorderChildren();
  }
}
