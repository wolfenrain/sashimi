import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../helpers/helpers.dart';

class _TestObject extends SashimiObject {
  _TestObject() : super(position: Vector3.zero(), size: Vector3.all(10));

  @override
  List<SashimiSlice<SashimiObject>> generateSlices() => [];
}

void main() {
  group('SashimiController', () {
    sashimiGame.testGameWidget(
      'realigns with owner',
      setUp: (game, tester) => game.ensureAdd(_TestObject()),
      verify: (game, tester) async {
        final object = game.descendants().whereType<_TestObject>().first;
        final controller = object.controller;

        expect(controller.position, equals(Vector2.zero()));
        expect(controller.size, equals(Vector2.all(10)));

        object.position.setValues(10, 10, 10);
        object.size.setValues(20, 20, 20);

        game.update(0);
        expect(controller.position, equals(Vector2(10, 10)));
        expect(controller.size, equals(Vector2.all(20)));
      },
    );
  });
}
