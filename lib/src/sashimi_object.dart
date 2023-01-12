import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
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
    double angle = 0,
  })  : position = NotifyingVector3.copy(position),
        size = NotifyingVector3.copy(size),
        scale = NotifyingVector3.copy(scale ?? Vector3.all(1)),
        _angle = angle;

  /// The position of the object in the world.
  final NotifyingVector3 position;

  /// The size of the object.
  final NotifyingVector3 size;

  /// The scale of the object.
  final NotifyingVector3 scale;

  /// The angle of rotation of the object.
  double get angle => _angle;
  set angle(double value) => controller.angle = _angle = value;
  double _angle;

  /// The slices of the object.
  List<SashimiSlice> get slices => List.unmodifiable(_slices);
  final List<SashimiSlice> _slices = [];

  /// The controller of the object.
  ///
  /// This is used to control the position, size, scale and angle of the object
  /// in the logical world.
  late final controller = SashimiController(owner: this);

  /// Generates the slices of the object.
  List<SashimiSlice> generateSlices();

  /// Recalculates the priority of the slices.
  void recalculate();

  @override
  @mustCallSuper
  Future<void>? onLoad() async {
    _slices.addAll(generateSlices());
    await parent.addAll([controller, ..._slices]);
    recalculate();
  }

  @override
  void onMount() {
    super.onMount();
    size.addListener(_onSizeUpdate);
    scale.addListener(_onScaleUpdate);
    position.addListener(_onPositionUpdate);

    controller.angle = angle;
    _onSizeUpdate();
    _onScaleUpdate();
    _onPositionUpdate();
  }

  @override
  void onRemove() {
    size.removeListener(_onSizeUpdate);
    scale.removeListener(_onScaleUpdate);
    position.removeListener(_onPositionUpdate);
    super.onRemove();
  }

  void _onSizeUpdate() {
    controller.size.setValues(size.x, size.y);
    recalculate();
  }

  void _onScaleUpdate() {
    controller.scale.setValues(scale.x, scale.y);
    recalculate();
  }

  void _onPositionUpdate() {
    controller.position.setValues(position.x, position.y);
    recalculate();
  }
}
