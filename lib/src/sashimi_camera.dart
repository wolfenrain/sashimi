import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';

/// {@template sashimi_camera}
/// The camera used by the Sashimi Engine.
/// {@endtemplate}
class SashimiCamera extends CameraComponent {
  /// {@macro sashimi_camera}
  SashimiCamera({required super.world});

  /// Move the camera by the given [offset].
  void moveBy(Vector2 offset, {double speed = double.infinity}) {
    stop();
    viewfinder.add(MoveByEffect(offset, EffectController(speed: speed)));
  }
}
