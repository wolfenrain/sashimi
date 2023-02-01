import 'dart:math';

import 'package:flame/experimental.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_camera}
/// The camera used by the Sashimi Engine.
/// {@endtemplate}
class SashimiCamera extends CameraComponent {
  /// {@macro sashimi_camera}
  SashimiCamera({
    double initialTilt = 60 * degrees2Radians,
    this.minimalTilt = 1 * degrees2Radians,
    this.maximalTilt = 89 * degrees2Radians,
  })  : _tilt = initialTilt.clamp(minimalTilt, maximalTilt),
        super(world: SashimiWorld());

  /// The world rotation of the camera.
  double get rotation => viewfinder.angle;
  set rotation(double value) => viewfinder.angle = value;

  double minimalTilt;
  double maximalTilt;

  double get tilt => _tilt;
  double _tilt;
  set tilt(double value) => _tilt = value.clamp(minimalTilt, maximalTilt);

  /// The zoom of the camera.
  double get zoom => viewfinder.zoom;
  set zoom(double value) =>
      viewfinder.zoom = value.clamp(0.01, double.infinity);

  /// The position of the camera.
  Vector2 get position => viewfinder.position;
  set position(Vector2 value) => viewfinder.position = value;

  @override
  Rect get visibleWorldRect {
    // TODO(wolfen): optimize by caching
    final visibleWorldRect = super.visibleWorldRect;
    final value = 1 / cos(tilt);
    return Rect.fromLTRB(
      visibleWorldRect.left * value,
      visibleWorldRect.top * value,
      visibleWorldRect.right * value,
      visibleWorldRect.bottom * value,
    );
  }
}
