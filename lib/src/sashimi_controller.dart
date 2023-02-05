import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_controller}
/// Describes the implementation of the controlling component of a
/// [SashimiObject].
///
/// Both the [SashimiObject] and it's [SashimiSlice]s use the controller to
/// realign themselves correctly. The controller is leading in both 2D and 3D
/// space.
///
/// **Note**: The `super.update` must always be called before accessing any of
/// the 2D properties that this controller exposes.
/// {@endtemplate}
mixin SashimiController on Component {
  late final SashimiObject object;

  bool facingCamera = false;

  /// The tracker for this controller.
  ///
  /// This is used to track the position of the object in the logical world.
  late final tracker = _ControllerTracker(this);

  /// The 3D position of the [SashimiObject].
  final NotifyingVector3 position3D = NotifyingVector3.zero();

  /// The 3D size of the [SashimiObject].
  late final NotifyingVector3 size3D = NotifyingVector3.zero()
    ..addListener(() => size2D.setValues(size3D.x, size3D.y));

  /// The 3D scale of the [SashimiObject].
  late final NotifyingVector3 scale3D = NotifyingVector3.zero()
    ..addListener(() => scale2D.setValues(scale3D.x, scale3D.y));

  /// The 2D position of the [SashimiObject].
  final Vector2 position2D = Vector2.zero();

  /// The 2D scale of the [SashimiObject].
  final Vector2 size2D = Vector2.zero();

  /// The 2D size of the [SashimiObject].
  final Vector2 scale2D = Vector2.zero();

  /// The rotation of the [SashimiObject].
  double rotation = 0;

  /// The engine that this controller is part of.
  SashimiEngine get engine => parent!.parent!.parent! as SashimiEngine;

  /// The camera of the engine.
  SashimiCamera get camera => engine.camera;

  final Matrix4 _projection = Matrix4.zero();

  /// Project the rendering on the [out] Matrix.
  void project(
    Matrix4 out, {
    int sliceIndex = 0,
    int amountOfSlices = 2,
    bool facingCamera = false,
  }) {
    // Calculate the height of the object.
    final height = size3D.z * scale3D.z;
    final distance = height / (amountOfSlices == 1 ? 1 : amountOfSlices - 1);

    // If it is facing the camera we can just calculate the matrix backwards.
    if (facingCamera) {
      return out.build(
        positionX: position3D.x,
        positionY: position3D.y,
        positionZ: -position3D.z - distance * sliceIndex,
        rotationX: camera.tilt + 90 * degrees2Radians,
        rotationZ: camera.rotation - 90 * degrees2Radians,
      );
    }

    // Scaling negatively on the y-axis so that the tilting angles are:
    // 90 degrees = top
    // 0 degrees = front
    final scale = Matrix4.identity()..build(scaleZ: -1);

    // Transform with the slice index taken into account.
    final transform = Matrix4.identity()
      ..build(
        positionX: position3D.x,
        positionY: position3D.y,
        positionZ: position3D.z + distance * sliceIndex,
      );

    out.setFrom(scale..multiply(transform));
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);

    project(_projection, facingCamera: facingCamera);
    position2D.setFrom(_projection.transform2(Vector2.zero()));
  }
}

class _ControllerTracker implements PositionProvider {
  _ControllerTracker(this._controller);

  final SashimiController _controller;

  @override
  Vector2 get position => _controller.position2D;

  @override
  set position(Vector2 value) => throw UnsupportedError(
        'The 2D position of a SashimiController cannot be set directly.',
      );
}

class PositionedController extends PositionComponent with SashimiController {
  PositionedController({
    super.anchor = Anchor.center,
    bool facingCamera = false,
  }) {
    this.facingCamera = facingCamera;
  }

  @override
  void renderTree(Canvas canvas) {
    // Sync the values before rendering otherwise it will be a tick behind.
    size.setFrom(size2D);
    scale.setFrom(scale2D);
    position.setFrom(position2D);
    angle = rotation;

    super.renderTree(canvas);
  }
}
