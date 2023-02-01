import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_slice}
/// Represents a slice of a [SashimiObject].
/// {@endtemplate}
abstract class SashimiSlice<Owner extends SashimiObject>
    extends PositionComponent with SashimiOwner<Owner> {
  /// {@macro sashimi_slice}
  SashimiSlice({
    required Owner owner,
    super.anchor = Anchor.center,
  }) : super() {
    this.owner = owner;

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

  /// The engine that this slice is part of.
  SashimiEngine get engine => owner.parent;

  /// Calculate the priority when the [owner] object changes.
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
    // final betweenSlices = owner.size.z / owner.slices.length;

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
    // Sync the values before rendering otherwise it will be a tick behind.
    owner.controller.calculatePosition(
      position,
      sliceIndex: owner.slices.indexOf(this),
      amountOfSlices: owner.slices.length,
    );
    angle = owner.rotation;

    super.renderTree(canvas);
  }
}
