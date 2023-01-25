// ignore_for_file: cascade_invocations

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../helpers/helpers.dart';

class _TestObject extends SashimiObject {
  _TestObject() : super(position: Vector3.zero(), size: Vector3.zero());

  @override
  List<SashimiSlice<SashimiObject>> generateSlices() {
    return [_TestSlice(owner: this)];
  }
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
      'culls slices',
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

        // Back in view, added in two ticks.
        object.position.y = 0;
        game.update(0);
        expect(slice.isMounted, isFalse);
        game.update(0);
        expect(slice.isMounted, isTrue);
      },
    );

    sashimiGame.testGameWidget(
      'does not cull controllers',
      setUp: (game, tester) => game.ensureAdd(_TestObject()),
      verify: (game, tester) async {
        final object = game.descendants().whereType<_TestObject>().first;
        final controller = object.controller;

        // Should be mounted directly
        expect(controller.isMounted, isTrue);

        // Stays loaded when out of view.
        object.position.y = 800;
        game.update(0);
        expect(controller.isMounted, isTrue);
        game.update(0);
        expect(controller.isMounted, isTrue);

        // Stays loaded when in view.
        object.position.y = 0;
        game.update(0);
        expect(controller.isMounted, isTrue);
        game.update(0);
        expect(controller.isMounted, isTrue);
      },
    );

    sashimiGame.testGameWidget(
      'none Sashimi-based objects get added to the world directly',
      setUp: (game, tester) => game.ready(),
      verify: (game, tester) async {
        final engine = game.engine;
        final world = engine.firstChild<World>()!;

        final object = _TestObject();
        final controller = SashimiController(owner: object);
        final slice = _TestSlice(owner: object);
        final component = Component();

        await engine.add(object);
        game.update(0);
        expect(world.children.contains(object), isFalse);

        await engine.add(controller);
        game.update(0);
        expect(world.children.contains(controller), isFalse);

        await engine.add(slice);
        game.update(0);
        expect(world.children.contains(slice), isFalse);

        await engine.add(component);
        game.update(0);
        expect(world.children.contains(component), isTrue);
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
