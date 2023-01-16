// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../helpers/helpers.dart';

class _TestObject extends SashimiObject {
  _TestObject() : super(position: Vector3.zero(), size: Vector3.zero());

  @override
  List<SashimiSlice<SashimiObject>> generateSlices() {
    return [];
  }
}

void main() {
  group('SashimiGame', () {
    sashimiGame.testGameWidget(
      'exposes a camera',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        expect(game.kamera, isA<SashimiCamera>());
      },
    );

    sashimiGame.testGameWidget(
      'contains an engine',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        expect(game.firstChild<SashimiEngine>(), isNotNull);
      },
    );

    sashimiGame.testGameWidget(
      'can enable/disable debug mode for culling',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        expect(game.debugVisual, isFalse);
        expect(game.debugLogical, isFalse);

        game.debugVisual = true;
        game.debugLogical = true;

        expect(game.debugVisual, isTrue);
        expect(game.debugLogical, isTrue);
      },
    );

    sashimiGame.testGameWidget(
      'can enable/disable culling',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        expect(game.visualCulling, isTrue);
        expect(game.logicalCulling, isFalse);

        game.visualCulling = false;
        game.logicalCulling = true;

        expect(game.visualCulling, isFalse);
        expect(game.logicalCulling, isTrue);
      },
    );

    sashimiGame.testGameWidget(
      'add sashimi objects to the engine',
      setUp: (game, tester) => game.ensureAdd(_TestObject()),
      verify: (game, tester) async {
        expect(game.children.whereType<SashimiObject>(), isEmpty);
        expect(game.engine.firstChild<SashimiObject>(), isNotNull);
      },
    );
  });
}
