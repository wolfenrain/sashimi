import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:meta/meta.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_object}
/// Abstract class for defining objects in the Sashimi engine.
///
/// An object can exist out of one or more [SashimiSlice]s. These visualize the
/// object.
///
/// An object can be moved, scaled and sized in three dimensions visually while
/// it only moves, scales, sizes and rotates in two dimensions logically. This
/// is done by using a [SashimiController] which is a [PositionComponent] that
/// handles the position, size, scale and angle of the object in the logical
/// world.
///
/// The logical world is the world where the object exists. The visual world is
/// the world where the object is rendered.
/// {@endtemplate}
abstract class SashimiObject extends Component with ParentIsA<SashimiEngine> {
  /// {@macro sashimi_object}
  SashimiObject({
    required Vector3 position,
    required Vector3 size,
    Vector3? scale,
    double rotation = 0,
    SashimiController? controller,
  }) : _controller = (controller ?? PositionedController())
          ..position3D.setFrom(position)
          ..size3D.setFrom(size)
          ..scale3D.setFrom(scale ?? Vector3.all(1))
          ..rotation = rotation;

  /// The position of the object in the world.
  NotifyingVector3 get position => _controller.position3D;

  /// The size of the object.
  NotifyingVector3 get size => _controller.size3D;

  /// The scale of the object.
  NotifyingVector3 get scale => _controller.scale3D;

  /// The angle of rotation of the object.
  double get rotation => _controller.rotation;
  set rotation(double value) => _controller.rotation = value;

  /// The slices of the object.
  List<SashimiSlice> get slices => List.unmodifiable(_slices);
  final List<SashimiSlice> _slices = [];

  /// The controller of the object.
  ///
  /// This is used to control the position, size, scale and angle of the object
  /// in the logical world.
  @internal
  SashimiController get controller => _controller;
  final SashimiController _controller;

  /// The engine the object is added to.
  SashimiEngine get engine => parent;

  /// The tracker of the object.
  ///
  /// This is used to track the position of the object in the logical world.
  PositionProvider get tracker => _controller.tracker;

  /// Generates the slices of the object.
  List<SashimiSlice> generateSlices();

  /// Called internally when the fidelity of the engine changes.
  @internal
  Future<void> regenerate() {
    return parent.addAll(
      _slices
        ..forEach((slice) => slice.removeFromParent())
        ..clear()
        ..addAll(generateSlices()),
    );
  }

  @override
  @mustCallSuper
  Future<void>? onLoad() async {
    await regenerate();
    await parent.add(_controller);
  }
}
