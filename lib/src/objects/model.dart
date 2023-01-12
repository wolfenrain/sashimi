import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
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
    super.angle,
    required this.image,
    Vector2? sliceSize,
  }) : sliceSize = sliceSize ?? size.xy;

  /// The image to use for the model.
  final Image image;

  /// The size of the individual slices in the image.
  final Vector2 sliceSize;

  @override
  List<SashimiSlice> generateSlices() {
    final sheet = SpriteSheet(image: image, srcSize: size.xy);
    final slices = (image.height / sliceSize.y).ceil();

    return [
      for (var i = 0; i < slices; i++)
        _SashimiSlice(
          owner: this,
          sprite: sheet.getSpriteById(slices - i - 1),
        ),
    ];
  }

  @override
  void recalculate() {
    // TODO(wolfen): correct spacing logic.
    final betweenSlices = size.z / (image.height / sliceSize.y) * scale.z;
    var distance = 0.0;

    for (var i = 0; i < slices.length; i++) {
      slices[i].priority = (position.z + i + distance).toInt();
      distance += betweenSlices;
    }
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
  final Paint paint = Paint()..isAntiAlias = false;

  @override
  void render(Canvas canvas) {
    sprite.render(canvas, size: size, overridePaint: paint);
  }
}
