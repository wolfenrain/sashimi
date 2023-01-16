// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../helpers/helpers.dart';

class _TestObject extends SashimiObject {
  _TestObject() : super(position: Vector3.zero(), size: Vector3.all(10));

  @override
  List<SashimiSlice<SashimiObject>> generateSlices() {
    return [_TestSlice(owner: this)];
  }
}

class _TestSlice extends SashimiSlice {
  _TestSlice({required super.owner});
}

void main() {
  group('SashimiSlice', () {
    sashimiGame.testGameWidget(
      'realigns with owner',
      setUp: (game, tester) => game.ensureAdd(_TestObject()),
      verify: (game, tester) async {
        final object = game.descendants().whereType<_TestObject>().first;
        final slice = object.slices.first;

        game.update(0);
        expect(slice.position, equals(Vector2.zero()));
        expect(slice.size, equals(Vector2.all(10)));

        object.position.setValues(10, 10, 0);
        object.size.setValues(20, 20, 20);

        game.update(0);
        expect(slice.position, equals(Vector2.all(10)));
        expect(slice.size, equals(Vector2.all(20)));
      },
    );

    sashimiGame.testGameWidget(
      'does not realigns if owner is not mounted',
      setUp: (game, tester) => game.ensureAdd(_TestObject()),
      verify: (game, tester) async {
        final object = game.descendants().whereType<_TestObject>().first;
        final slice = object.slices.first;

        object.removeFromParent();
        game.update(0); // Simulate next tick

        object.size.setValues(20, 20, 20);
        expect(slice.size, equals(Vector2.all(10)));
      },
    );
  });
}
