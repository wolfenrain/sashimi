// ignore_for_file: cascade_invocations

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../helpers/helpers.dart';

class _TestObject extends SashimiObject {
  _TestObject() : super(position: Vector3.zero(), size: Vector3.all(10));

  @override
  List<SashimiSlice<SashimiObject>> generateSlices() {
    return [_TestSlice(owner: this)];
  }

  @override
  void recalculate() {}
}

class _TestSlice extends SashimiSlice {
  _TestSlice({required super.owner});
}

void main() {
  group('SashimiSlice', () {
    sashimiGame.testGameWidget(
      'sync values with owner',
      setUp: (game, tester) => game.ensureAdd(_TestObject()),
      verify: (game, tester) async {
        final object = game.descendants().whereType<_TestObject>().first;
        final slice = object.slices.first;

        game // Need two updates, first to add the slice, second to sync values.
          ..update(0)
          ..update(0);
        expect(slice.position, equals(Vector2.zero()));
        expect(slice.size, equals(Vector2.all(10)));

        object.position.setValues(10, 10, 10);
        object.size.setValues(20, 20, 20);

        game.update(0);
        expect(slice.position, equals(Vector2(10, 10)));
        expect(slice.size, equals(Vector2.all(20)));
      },
    );

    sashimiGame.testGameWidget(
      'does not update values if owner is not mounted',
      setUp: (game, tester) => game.ensureAdd(_TestObject()),
      verify: (game, tester) async {
        final object = game.descendants().whereType<_TestObject>().first;
        final slice = object.slices.first;

        object.removeFromParent();
        game.update(0); // Simulate next tick

        object.size.setValues(10, 10, 10);
        expect(slice.size, equals(Vector2(0, 0)));
      },
    );
  });
}
