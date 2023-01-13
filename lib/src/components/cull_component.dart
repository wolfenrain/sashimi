import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:sashimi/sashimi.dart';

/// {@template cull_component}
/// A component that culls its children based on whether they are inside the
/// screen or not.
///
/// TODO(wolfen): this does not cull correct with rotation.
/// {@endtemplate}
class CullComponent<T extends SashimiOwner> extends Component
    with HasGameRef<SashimiGame>, HasAncestor<SashimiEngine> {
  CullComponent({this.cullingEnabled = false});

  final List<T> _culledComponents = [];

  late final List<T> _components;

  /// If culling is enabled for this component.
  ///
  /// TODO(wolfen): add culled components when it gets disabled.
  bool cullingEnabled;

  @override
  Future<void>? onLoad() {
    children.register<T>();
    _components = children.query<T>();
    return super.onLoad();
  }

  Future<void>? addComponent(T component) async {
    if (!cullingEnabled) return super.add(component);
    return _culledComponents.add(component);
  }

  @override
  Future<void> add(Component component) {
    throw UnsupportedError(
      'Cannot directly add components to a CullComponent, use addChild instead',
    );
  }

  @override
  void update(double dt) {
    if (!cullingEnabled) return;
    final transform = ancestor.viewfinder.transform;
    final topLeft = transform.globalToLocal(Vector2.zero());
    final bottomRight = transform.globalToLocal(ancestor.viewport.size.clone());

    // final topLeft = (-ancestor.viewport.size / 2)
    //   ..add(Vector2.all(16))
    //   ..scale(1 / ancestor.viewfinder.zoom)
    //   ..add(ancestor.viewfinder.position);
    // final bottomRight = ancestor.viewport.size.clone()
    //   ..scale(1 / ancestor.viewfinder.zoom)
    //   ..add(topLeft);

    final viewport =
        Rect.fromLTRB(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y);

    final removed = <T>[
      for (final component in _components)
        if (!viewport.overlaps(component.toRect())) component,
    ]..forEach(super.remove);

    final added = <T>[
      for (final component in _culledComponents.where((c) => c.parent == null))
        if (viewport.overlaps(component.toRect())) component,
    ]..forEach(super.add); // Bypass unimplemented add method.

    // for (final component in _components) {
    //   final rect = component.toRect();
    //   if (!viewportRect.overlaps(rect)) {
    //     removed.add(component..removeFromParent());
    //   }
    // }

    // for (final component in _culledComponents) {
    //   final rect = component.toRect();
    //   if (viewport.overlaps(rect) && component.parent == null) {
    //     super.add(component);
    //     added.add(component);
    //   }
    // }

    // Reorder all children to ensure their priorities are correct after adding.
    reorderChildren();

    // Remove all added components from the list of culled components and
    // add all removed components to the list of culled components.
    _culledComponents
      ..removeWhere(added.contains)
      ..addAll(removed);
  }

  @override
  void renderTree(Canvas canvas) {
    render(canvas);
    for (final c in children) {
      c.renderTree(canvas);

      // If debug mode is enabled draw a dot to represent the center of a
      // component.
      if (c is PositionComponent && debugMode) {
        final center = c.center.toOffset();
        canvas.drawCircle(center, 0.5, Paint()..color = Colors.green);
      }
    }

    if (debugMode) renderDebugMode(canvas);
  }

  @override
  void renderDebugMode(Canvas canvas) {
    if (!cullingEnabled) return;
    final transform = ancestor.viewfinder.transform;
    final topLeft = transform.globalToLocal(Vector2.zero());
    final bottomRight = transform.globalToLocal(ancestor.viewport.size.clone());

    // final topLeft = (-ancestor.viewport.size / 2)
    //   ..add(Vector2.all(16))
    //   ..scale(1 / ancestor.viewfinder.zoom)
    //   ..add(ancestor.viewfinder.position);
    // final bottomRight = ancestor.viewport.size.clone()
    //   ..scale(1 / ancestor.viewfinder.zoom)
    //   ..add(topLeft);

    final viewport =
        Rect.fromLTRB(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y);

    final paint = Paint();
    final radius = 25 / ancestor.viewfinder.zoom;
    canvas
      ..drawRect(viewport, paint..color = Colors.blue.withOpacity(0.2))
      ..drawCircle(viewport.topLeft, radius, paint..color = Colors.red)
      ..drawCircle(viewport.bottomRight, radius, paint..color = Colors.green);
  }
}
