import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';

/// {@template sashimi_camera}
/// The camera used by the Sashimi Engine.
/// {@endtemplate}
class SashimiCamera extends CameraComponent {
  /// {@macro sashimi_camera}
  SashimiCamera({required super.world});

  /// The world rotation of the camera.
  double get rotation => viewfinder.angle;
  set rotation(double value) => viewfinder.angle = value;

  /// The zoom of the camera.
  double get zoom => viewfinder.zoom;
  set zoom(double value) => viewfinder.zoom = value;

  /// The position of the camera.
  Vector2 get position => viewfinder.position;
  set position(Vector2 value) => viewfinder.position = value;
}
