import 'package:flame/components.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_owner}
/// A mixin that describes who the owner is of a component that was created from
/// a [SashimiObject].
///
/// This is used internally to have a strongly typed way of looking up
/// [SashimiObject]s. For instance when culling components that are not visible
/// or when components have collided.
/// {@endtemplate}
mixin SashimiOwner<Owner extends SashimiObject> on PositionComponent {
  /// The owner object of this component.
  late final Owner owner;
}
