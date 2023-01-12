import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:sashimi/sashimi.dart';

/// {@template colored_cuboid}
/// A cuboid that has a different color for each slice.
/// {@endtemplate}
class ColoredCuboid extends SashimiObject {
  /// {@macro colored_cuboid}
  ColoredCuboid({
    required super.position,
    required super.size,
    super.scale,
    super.angle,
    required this.colors,
  });

  /// The colors to use.
  ///
  /// Each color will be used for a slice of the cuboid. They will be spaced
  /// over the Z axis.
  final List<Color> colors;

  @override
  List<SashimiSlice> generateSlices() {
    return [
      for (var i = 0; i < colors.length; i++)
        _SashimiSlice(
          owner: this,
          color: colors[i],
        ),
    ];
  }

  @override
  void recalculate() {
    // TODO(wolfen): correct spacing logic.
    final betweenSlices = (size.z / colors.length) * scale.z;
    for (var i = 0; i < slices.length; i++) {
      slices[i].priority = (position.z + i + betweenSlices * i).toInt();
    }
  }
}

class _SashimiSlice extends SashimiSlice<ColoredCuboid> {
  _SashimiSlice({
    required super.owner,
    required this.color,
  }) : paint = Paint()..color = color;

  final Color color;

  final Paint paint;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Vector2.zero() & size, paint);
  }
}
