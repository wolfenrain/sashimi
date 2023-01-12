// ignore_for_file: cascade_invocations

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../helpers/helpers.dart';

class _TestObject extends SashimiObject {
  _TestObject() : super(position: Vector3.zero(), size: Vector3.zero());

  @override
  List<SashimiSlice<SashimiObject>> generateSlices() => [];

  @override
  void recalculate() {}
}

class _TestSlice extends SashimiSlice<_TestObject> {
  _TestSlice({
    required super.owner,
  });
}

void main() {
  group('SashimiEngine', () {
    sashimiGame.testGameWidget(
      'contains world and a camera',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        final engine = game.engine;

        expect(engine.firstChild<World>(), isNotNull);
        expect(engine.firstChild<SashimiCamera>(), isNotNull);
      },
    );

    sashimiGame.testGameWidget(
      'world contains two cull components',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        final engine = game.engine;
        final world = engine.firstChild<World>()!;

        expect(world.children.whereType<CullComponent>().length, equals(2));
      },
    );

    sashimiGame.testGameWidget(
      'can enable/disable debug mode for culling',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        final engine = game.engine;

        expect(engine.debugVisual, isFalse);
        expect(engine.debugLogical, isFalse);

        engine.debugVisual = true;
        engine.debugLogical = true;

        expect(engine.debugVisual, isTrue);
        expect(engine.debugLogical, isTrue);
      },
    );

    sashimiGame.testGameWidget(
      'can enable/disable culling',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        final engine = game.engine;

        expect(engine.visualCulling, isTrue);
        expect(engine.logicalCulling, isFalse);

        engine.visualCulling = false;
        engine.logicalCulling = true;

        expect(engine.visualCulling, isFalse);
        expect(engine.logicalCulling, isTrue);
      },
    );

    sashimiGame.testGameWidget(
      'add only allows Sashimi-based components',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        final engine = game.engine;

        final object = _TestObject();
        final controller = SashimiController(owner: object);
        final slice = _TestSlice(owner: object);

        expect(engine.add(object), completes);
        expect(engine.add(controller), completes);
        expect(engine.add(slice), completes);

        expect(
          () => engine.add(Component()),
          throwsA(
            isA<UnimplementedError>().having(
              (e) => e.message,
              'message',
              equals(
                'Only Sashimi-based components can be added to the engine.',
              ),
            ),
          ),
        );
      },
    );

    sashimiGame.testGameWidget(
      'worldToScreen',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        final engine = game.engine;

        expect(
          engine.worldToScreen(Vector2.zero()),
          equals(Vector2(-400, -300)),
        );

        engine.camera.moveBy(Vector2.all(10));
        game.update(0);
        expect(
          engine.worldToScreen(Vector2.zero()),
          equals(Vector2(-390, -290)),
        );

        engine.camera.viewfinder.zoom = 0.5;
        game.update(0);
        expect(
          engine.worldToScreen(Vector2.zero()),
          equals(Vector2(-790, -590)),
        );

        engine.camera.viewfinder.angle = 45 * degrees2Radians;
        game.update(0);
        expect(
          engine.worldToScreen(Vector2.zero()),
          equals(Vector2(-131.42135623730957, -979.9494936611665)),
        );
      },
    );

    sashimiGame.testGameWidget(
      'screenToWorld',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        final engine = game.engine;

        expect(engine.screenToWorld(Vector2.zero()), equals(Vector2(400, 300)));

        engine.camera.moveBy(Vector2.all(10));
        game.update(0);
        expect(
          engine.screenToWorld(Vector2.zero()),
          equals(Vector2(390, 290)),
        );

        engine.camera.viewfinder.zoom = 0.5;
        game.update(0);
        expect(
          engine.screenToWorld(Vector2.zero()),
          equals(Vector2(395, 295)),
        );

        engine.camera.viewfinder.angle = 45 * degrees2Radians;
        game.update(0);
        expect(
          engine.screenToWorld(Vector2.zero()),
          equals(Vector2(392.9289321881345, 300)),
        );
      },
    );
  });
}
