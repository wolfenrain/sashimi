import 'package:flame/experimental.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_world}
/// The root component for all sashimi components. The world is rendered
/// through the [SashimiCamera].
///
/// It applies a set of transformations to the canvas to allow the visual world
/// to tilt around its pseudo z-axis
/// {@endtemplate}
class SashimiWorld extends World {
  @override
  void renderFromCamera(Canvas canvas) {
    assert(
      CameraComponent.currentCamera is SashimiCamera,
      'SashimiWorld requires a SashimiCamera to be set as the current camera.',
    );
    final camera = CameraComponent.currentCamera! as SashimiCamera;
    return super.renderFromCamera(canvas..transform(camera.projection.storage));
  }
}
