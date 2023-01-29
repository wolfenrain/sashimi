import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_slice}
/// Represents a slice of a [SashimiObject].
/// {@endtemplate}
class SashimiSlice<Owner extends SashimiObject> extends PositionComponent
    with SashimiOwner<Owner> {
  /// {@macro sashimi_slice}
  SashimiSlice({
    required Owner owner,
    super.anchor = Anchor.center,
  }) : super() {
    this.owner = owner
      ..addListener(calculatePriority)
      ..addListener(realign);
  }

  /// Calculate the priority when the [owner] object changes.
  void calculatePriority() {
    final index = owner.slices.indexOf(this);
    final betweenSlices = owner.size.z / owner.slices.length;
    priority = (owner.position.z + index + betweenSlices * index).toInt();
  }

  /// Realign the component with [owner].
  @mustCallSuper
  void realign() {
    size.setValues(owner.size.x, owner.size.y);
    scale.setValues(owner.scale.x, owner.scale.y);
    final scaledPriority = priority * owner.scale.z;
    position.setValues(
      sin(owner.parent.camera.rotation) /
              cos(owner.parent.camera.tilt) *
              scaledPriority +
          owner.position.x,
      -cos(owner.parent.camera.rotation) /
              cos(owner.parent.camera.tilt) *
              scaledPriority +
          owner.position.y,
    );
    angle = owner.angle;
  }

  @override
  @mustCallSuper
  void update(double dt) {
    if (!owner.isMounted) return;
    realign();
  }
}
