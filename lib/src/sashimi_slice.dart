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
    this.owner = owner;
  }

  @override
  @mustCallSuper
  void update(double dt) {
    if (!owner.isMounted) return;

    size.setValues(owner.size.x, owner.size.y);
    scale.setValues(owner.scale.x, owner.scale.y);
    position.setValues(
      sin(owner.parent.viewfinder.angle) * priority + owner.position.x,
      -cos(owner.parent.viewfinder.angle) * priority + owner.position.y,
    );
    angle = owner.angle;
  }
}
