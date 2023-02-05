import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_engine}
/// The engine behind the Sashimi engine.
///
/// The engine is responsible for rendering [SashimiObject]s and their
/// [SashimiSlice]s. It also handles the [SashimiController]s of the objects.
/// This is done through the logical world and the visual world.
///
/// The logical world is the world where the objects exists. The visual world is
/// the world where those objects are rendered. These worlds both cull objects
/// once their are out of the viewfinder. The logical world handles collision
/// and only holds [SashimiController]s, while the visual world only holds
/// [SashimiSlice]s. The [SashimiObject]s are directly added to the engine.
/// {@endtemplate}
class SashimiEngine extends Component {
  /// {@macro sashimi_engine}
  SashimiEngine({
    SashimiCamera? camera,
    int fidelity = 1,
  })  : camera = camera ?? SashimiCamera(),
        _fidelity = fidelity;

  /// The camera component that is used to render the world.
  final SashimiCamera camera;

  /// The world that contains all the visual components.
  ///
  /// This is the world that is rendered on the screen and does not have any
  /// logical behavior like collision detection, that is handled in the
  /// [_logicalWorld].
  final _visualWorld = CullComponent<SashimiSlice>();

  /// The world that contains all the logical components.
  ///
  /// This is the world that does all the logical behaviors of objects, like
  /// collision detection. This world tends to have a smaller component list
  /// than the [_visualWorld] as it only has [SashimiController]s, which there
  /// is only one of per [SashimiObject].
  final _logicalWorld = Component();

  /// Whether the visual world should cull components.
  bool get visualCulling => _visualWorld.cullingEnabled;
  set visualCulling(bool value) => _visualWorld.cullingEnabled = value;

  /// Debug mode for the visual world.
  bool get debugVisual => _visualWorld.debugMode;
  set debugVisual(bool value) => _visualWorld.debugMode = value;

  /// Debug mode for the logical world.
  bool get debugLogical => _logicalWorld.debugMode;
  set debugLogical(bool value) => _logicalWorld.debugMode = value;

  /// The fidelity of the engine, which is used to calculate the number of
  /// slices per object that need to be rendered.
  int get fidelity => _fidelity;
  int _fidelity;
  set fidelity(int value) {
    assert(fidelity >= 1 && fidelity <= 8, 'Fidelity must be between 1 and 8');
    _fidelity = value;

    // TODO(wolfen): clear the cull component when regenerating

    for (final object in _objects) {
      object.regenerate();
    }
    _visualWorld.reorderChildren();
  }

  late final List<SashimiObject> _objects;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await camera.world.addAll([_visualWorld, _logicalWorld]);
    await super.add(camera.world); // Use super.add to skip engine rules.
    await super.add(camera); // Use super.add to skip engine rules.

    children.register<SashimiObject>();
    _objects = children.query<SashimiObject>();
  }

  @override
  FutureOr<void> add(Component component) {
    if (component is SashimiSlice) {
      return _visualWorld.addComponent(component);
    } else if (component is SashimiController) {
      return _logicalWorld.add(component);
    } else if (component is SashimiObject) {
      return super.add(component);
    }
    return camera.world.add(component);
  }

  /// Converts a [point] from world coordinates to screen coordinates.
  Vector2 worldToScreen(Vector2 point) {
    // ignore: invalid_use_of_internal_member
    return camera.viewfinder.transform.globalToLocal(
      Vector2(
        point.x -
            camera.viewport.position.x +
            camera.viewport.anchor.x * camera.viewport.size.x,
        point.y -
            camera.viewport.position.y +
            camera.viewport.anchor.y * camera.viewport.size.y,
      ),
    );
  }

  /// Converts a [point] from screen coordinates to world coordinates.
  Vector2 screenToWorld(Vector2 point) {
    // ignore: invalid_use_of_internal_member
    return camera.viewfinder.transform.localToGlobal(
      Vector2(
        point.x +
            camera.viewport.position.x -
            camera.viewport.anchor.x * camera.viewport.size.x,
        point.y +
            camera.viewport.position.y -
            camera.viewport.anchor.y * camera.viewport.size.y,
      ),
    );
  }
}
