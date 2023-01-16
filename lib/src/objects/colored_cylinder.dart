import 'package:flutter/material.dart';
import 'package:sashimi/sashimi.dart';

/// {@template colored_cylinder}
/// A cylinder that has a different color for each slice.
/// {@endtemplate}
class ColoredCylinder extends SashimiObject {
  /// {@macro colored_cylinder}
  ColoredCylinder({
    required super.position,
    required double height,
    required double diameter,
    super.scale,
    super.angle,
    required this.colors,
  }) : super(size: Vector3(diameter, diameter, height));

  /// The colors to use.
  ///
  /// Each color will be used for a slice of the cylinder. They will be spaced
  /// over the Z axis.
  final List<Color> colors;

  @override
  void update(double dt) {
    // Update the position of the controller to match the bottom slice of the
    // model (the first slice in the list).
    controller.position.setFrom(slices.first.position);
  }

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
}

class _SashimiSlice extends SashimiSlice<ColoredCylinder> {
  _SashimiSlice({
    required super.owner,
    required this.color,
  }) : paint = Paint()..color = color;

  final Color color;

  final Paint paint;

  @override
  void render(Canvas canvas) {
    canvas.drawArc(Vector2.zero() & size, 0, 6.283185307179586, true, paint);
  }
}
