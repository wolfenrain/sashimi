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
          controller: controller ?? PositionedController(),
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
  BillboardController({
    super.anchor = Anchor.bottomCenter,
    super.facingCamera = true,
  });
}

class _SashimiSlice extends SashimiSlice<BillboardSprite> {
  _SashimiSlice({required super.owner})
      : super(anchor: Anchor.bottomCenter, facingCamera: true);

  @override
  void render(Canvas canvas) {
    owner.sprite.render(canvas, size: size);
  }
}
