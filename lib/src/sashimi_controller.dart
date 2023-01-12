import 'package:flame/components.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_controller}
/// The controller of a [SashimiObject].
///
/// This is used to control the position, size, scale and angle of the object
/// in the logical world.
///
/// TODO(wolfen): add collision detection
/// {@endtemplate}
class SashimiController extends PositionComponent with SashimiOwner {
  /// {@macro sashimi_controller}
  SashimiController({
    required SashimiObject owner,
  }) : super(
          anchor: Anchor.center,
          position: owner.position.xy,
          size: owner.size.xy,
          scale: owner.scale.xy,
          angle: owner.angle,
        ) {
    this.owner = owner;
  }
}
