import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
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
  final World _world = World();

  /// The camera component that is used to render the world.
  late final SashimiCamera camera = SashimiCamera(world: _world);

  /// The camera's viewfinder.
  Viewfinder get viewfinder => camera.viewfinder;

  /// The camera's viewport.
  Viewport get viewport => camera.viewport;

  /// The world that contains all the visual components.
  ///
  /// This is the world that is rendered on the screen and does not have any
  /// logical behavior like collision detection, that is handled in the
  /// [_logicalWorld].
  final _visualWorld = CullComponent<SashimiSlice>(cullingEnabled: true);

  /// The world that contains all the logical components.
  ///
  /// This is the world that does all the logical behaviors of objects, like
  /// collision detection. This world tends to have a smaller component list
  /// than the [_visualWorld] as it only has [SashimiController]s, which there
  /// is only one of per [SashimiObject].
  final _logicalWorld = CullComponent<SashimiController>();

  /// Whether the visual world should cull components.
  bool get visualCulling => _visualWorld.cullingEnabled;
  set visualCulling(bool value) => _visualWorld.cullingEnabled = value;

  /// Whether the logical world should cull components.
  bool get logicalCulling => _logicalWorld.cullingEnabled;
  set logicalCulling(bool value) => _logicalWorld.cullingEnabled = value;

  /// Debug mode for the visual world.
  bool get debugVisual => _visualWorld.debugMode;
  set debugVisual(bool value) => _visualWorld.debugMode = value;

  /// Debug mode for the logical world.
  bool get debugLogical => _logicalWorld.debugMode;
  set debugLogical(bool value) => _logicalWorld.debugMode = value;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await _world.addAll([_visualWorld, _logicalWorld]);
    await super.add(_world); // Use super.add to skip engine rules.
    await super.add(camera); // Use super.add to skip engine rules.
  }

  @override
  Future<void>? add(Component component) {
    if (component is SashimiSlice) {
      return _visualWorld.addComponent(component);
    } else if (component is SashimiController) {
      return _logicalWorld.addComponent(component);
    } else if (component is SashimiObject) {
      return super.add(component);
    }
    throw UnimplementedError(
      'Only Sashimi-based components can be added to the engine.',
    );
  }

  /// Converts a [point] from world coordinates to screen coordinates.
  Vector2 worldToScreen(Vector2 point) {
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
