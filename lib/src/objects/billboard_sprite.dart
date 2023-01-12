import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sashimi/sashimi.dart';

/// {@template billboard_sprite}
/// A component that renders a [Sprite] in the world, always facing the camera.
/// {@endtemplate}
class BillboardSprite extends SashimiObject {
  /// {@macro billboard_sprite}
  BillboardSprite({
    required super.position,
    required this.sprite,
    required Vector2 size,
    Vector2? scale,
    super.angle,
  }) : super(
          size: Vector3(size.x, size.y, 1),
          scale: Vector3(scale?.x ?? 1, scale?.y ?? 1, 1),
        ) {
    controller.anchor = Anchor.bottomCenter;
  }

  /// The sprite to render.
  final Sprite sprite;

  @override
  void update(double dt) {
    // Set the angle to the viewfinder angle and subtract own angle. This
    // ensures that if angle is set to 0, the sprite will always face the
    // camera.
    controller.angle = parent.viewfinder.angle - angle;
  }

  @override
  void recalculate() {
    slices.first.priority = position.z.toInt();
  }

  @override
  List<SashimiSlice<SashimiObject>> generateSlices() {
    return [_SashimiSlice(owner: this)];
  }
}

class _SashimiSlice extends SashimiSlice<BillboardSprite> {
  _SashimiSlice({required super.owner}) : super(anchor: Anchor.bottomCenter);

  @override
  void update(double dt) {
    super.update(dt);

    // Set the position relative to the position of the controller based on the
    // anchor (bottom center).
    position.setFrom(owner.controller.positionOfAnchor(anchor));

    // Set the angle to the controller's angle as that one will always be
    // visually correct.
    angle = owner.controller.angle;
  }

  @override
  void render(Canvas canvas) {
    owner.sprite.render(canvas, size: owner.size.xy);
  }
}
