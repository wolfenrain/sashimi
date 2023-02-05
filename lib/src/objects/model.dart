import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:sashimi/sashimi.dart';

/// {@template model}
/// A component that models multiple slices of a 3D object.
/// {@endtemplate}
class Model extends SashimiObject {
  /// {@macro model}
  Model({
    required super.position,
    required super.size,
    super.scale,
    super.rotation,
    required this.image,
    Vector2? sliceSize,
    super.controller,
  }) : sliceSize = sliceSize ?? size.xy;

  /// The image to use for the model.
  final Image image;

  /// The size of the individual slices in the image.
  final Vector2 sliceSize;

  @override
  List<SashimiSlice> generateSlices() {
    final sheet = SpriteSheet(image: image, srcSize: sliceSize.xy);
    final slices = (image.height / sliceSize.y).ceil();

    return [
      for (var i = 0.0; i < slices; i += 1 / engine.fidelity)
        _SashimiSlice(
          owner: this,
          sprite: sheet.getSpriteById(slices - i.floor() - 1),
        ),
    ];
  }
}

class _SashimiSlice extends SashimiSlice<Model> {
  _SashimiSlice({
    required super.owner,
    required this.sprite,
  });

  final Sprite sprite;

  /// Paint with `isAntiAlias` to prevent sampling outside the image.
  ///
  /// See https://github.com/flutter/flutter/issues/67881 for more info.
  static final Paint paint = Paint()..isAntiAlias = false;

  @override
  void render(Canvas canvas) {
    sprite.render(canvas, size: size, overridePaint: paint);
  }
}
