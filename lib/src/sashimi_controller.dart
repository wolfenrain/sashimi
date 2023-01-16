import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_controller}
/// The controller of a [SashimiObject].
///
/// This is used to control the position, size, scale and angle of the object
/// in the logical world.
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
    this.owner = owner..addListener(realign);
  }

  /// Realign the component with [owner].
  @mustCallSuper
  void realign() {
    angle = owner.angle;
    size.setValues(owner.size.x, owner.size.y);
    scale.setValues(owner.scale.x, owner.scale.y);
    position.setValues(owner.position.x, owner.position.y);
  }
}
