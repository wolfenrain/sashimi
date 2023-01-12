import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_slice}
/// Represents a slice of a [SashimiObject].
/// {@endtemplate}
class SashimiSlice<Owner extends SashimiObject> extends PositionComponent
    with SashimiOwner<Owner>, HasAncestor<SashimiEngine> {
  /// {@macro sashimi_slice}
  SashimiSlice({
    required Owner owner,
  }) : super(anchor: Anchor.center) {
    this.owner = owner;
  }

  @override
  @mustCallSuper
  void update(double dt) {
    size.setValues(owner.size.x, owner.size.y);
    scale.setValues(owner.scale.x, owner.scale.y);
    position.setValues(
      sin(ancestor.viewfinder.angle) * priority + owner.position.x,
      -cos(ancestor.viewfinder.angle) * priority + owner.position.y,
    );
    angle = owner.angle;
  }
}
