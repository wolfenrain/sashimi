// ignore_for_file: cascade_invocations

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../../helpers/helpers.dart';

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
  group('CullComponent', () {
    test('throws error when trying to add a component directly', () {
      final cullComponent = CullComponent();

      expect(
        () => cullComponent.add(Component()),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            equals(
              '''Cannot directly add components to a CullComponent, use addComponent instead''',
            ),
          ),
        ),
      );
    });

    sashimiGame.testGameWidget(
      'cull slice when it is out of view',
      setUp: (game, tester) => game.ensureAdd(_TestObject()),
      verify: (game, tester) async {
        final object = game.descendants().whereType<_TestObject>().first;
        final slice = object.slices.first;

        // Should be mounted after two ticks.
        expect(slice.isMounted, isFalse);
        game.update(0);
        expect(slice.isMounted, isFalse);
        game.update(0);
        expect(slice.isMounted, isTrue);

        // Out of view, removed in two ticks.
        object.position.y = 800;
        game.update(0);
        expect(slice.isMounted, isTrue);
        game.update(0);
        expect(slice.isMounted, isFalse);
      },
    );

    sashimiGame.testGameWidget(
      'does not cull slice when it is in view',
      setUp: (game, tester) => game.ensureAdd(_TestObject()),
      verify: (game, tester) async {
        final object = game.descendants().whereType<_TestObject>().first;
        final slice = object.slices.first;

        // Should be mounted after two ticks.
        expect(slice.isMounted, isFalse);
        game.update(0);
        expect(slice.isMounted, isFalse);
        game.update(0);
        expect(slice.isMounted, isTrue);
      },
    );
  });
}
