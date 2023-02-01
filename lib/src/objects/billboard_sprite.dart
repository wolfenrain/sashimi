import 'dart:math';

import 'package:flame/components.dart';
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
    super.rotation,
    SashimiController? controller,
  }) : super(
          size: Vector3(size.x, size.y, 1),
          scale: Vector3(scale?.x ?? 1, scale?.y ?? 1, 1),
          controller: controller ?? BillboardController(),
        );

  /// The sprite to render.
  final Sprite sprite;

  @override
  List<SashimiSlice<SashimiObject>> generateSlices() {
    return [_SashimiSlice(owner: this)];
  }
}

/// {@template billboard_controller}
/// The [SashimiController] for the [BillboardSprite].
///
/// It forces the rotation to always be equal to the camera rotation to ensure
/// it is always facing the player.
/// {@endtemplate}
class BillboardController extends PositionedController {
  /// {@macro billboard_controller}
  BillboardController({super.anchor = Anchor.bottomCenter});

  @override
  void update(double dt) {
    super.update(dt);
    rotation = engine.camera.rotation;
  }
}

class _SashimiSlice extends SashimiSlice<BillboardSprite> {
  _SashimiSlice({required super.owner}) : super(anchor: Anchor.bottomCenter);

  @override
  void calculatePriority() {
    priority = owner.position.z.toInt();
  }

  @override
  void render(Canvas canvas) {
    // Scale the canvas in the opposite direction (the world tilt) to allow the
    // sprite to render in normal 2D space. Also translating it on the y-axis
    // to place the sprite back on the original location.
    canvas
      ..scale(1, 1 / cos(owner.parent.camera.tilt))
      ..translate(0, -size.y + size.y * cos(owner.parent.camera.tilt));

    owner.sprite.render(canvas, size: size);
  }
}
