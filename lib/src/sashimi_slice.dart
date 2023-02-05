import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_slice}
/// Represents a slice of a [SashimiObject].
/// {@endtemplate}
abstract class SashimiSlice<Owner extends SashimiObject>
    extends PositionComponent {
  /// {@macro sashimi_slice}
  SashimiSlice({
    required this.owner,
    super.anchor = Anchor.center,
    this.facingCamera = false,
  }) : super() {
    // The properties needed for priority calculations.
    owner.position.addListener(calculatePriority);
    owner.size.addListener(calculatePriority);

    // Listen to size and scale changes to sync it up automatically.
    owner.size.addListener(() => size.setValues(owner.size.x, owner.size.y));
    owner.scale.addListener(
      () => scale.setValues(owner.scale.x, owner.scale.y),
    );
    size.setValues(owner.size.x, owner.size.y);
    scale.setValues(owner.scale.x, owner.scale.y);
    angle = owner.rotation;
  }

  /// The owner object of this component.
  final Owner owner;

  /// Indicates if this slice is facing the camera or not.
  bool facingCamera;

  /// The engine that this slice is part of.
  SashimiEngine get engine => owner.parent;

  final _renderProjection = Matrix4.zero();

  /// Calculate the priority when the [owner] object changes.
  ///
  /// TODO(wolfen): rework priority
  void calculatePriority() {
    // Calculate the height of the object.
    final height = owner.size.z * owner.scale.z;

    // Evenly space the slices over the height.
    final distance =
        height / (owner.slices.length == 1 ? 1 : owner.slices.length - 1);

    // Calculate the distance between the slices when tilted.
    final distanceBetweenSlices =
        distance - (distance * cos(owner.parent.camera.tilt));

    final index = owner.slices.indexOf(this);

    priority =
        (owner.position.z + index + distanceBetweenSlices * index).toInt();
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    calculatePriority();
  }

  @override
  @mustCallSuper
  void renderTree(Canvas canvas) {
    angle = owner.rotation;
    owner.controller.project(
      _renderProjection,
      sliceIndex: owner.slices.indexOf(this),
      amountOfSlices: owner.slices.length,
      facingCamera: facingCamera,
    );

    // Reset values because the rendering happens through the render projection.
    position.setZero();

    canvas
      ..save()
      // Render using the render projection.
      ..transform(_renderProjection.storage);
    super.renderTree(canvas);
    canvas.restore();

    // Restore the position to what the projection says it should be.
    position.setFrom(_renderProjection.transform2(Vector2.zero()));
  }
}
