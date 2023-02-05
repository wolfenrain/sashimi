import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sashimi/sashimi.dart';

class ExampleGame extends SashimiGame
    with MultiTouchDragDetector, ScrollDetector {
  ExampleGame() : super(engine: SashimiEngine());

  final TextComponent _debugText = TextComponent(
    scale: Vector2.all(0.75),
    textRenderer: TextPaint(
      style: TextPaint.defaultTextStyle.copyWith(color: Colors.green),
    ),
  );

  final rnd = Random();

  Vector3 randomPos(int middle, double min, double max) {
    double value(int max) => rnd.nextInt(max) - max / 2;
    return Vector3(value(middle) + min, value(middle) + max, 0);
  }

  late Cube cube;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // debugLogical = true;

    for (final position in [
      for (var i = 0; i < 10; i++) ...[
        randomPos(5000, -2500, -2500),
        randomPos(5000, 2500, 2500),
        randomPos(5000, -2500, 2500),
        randomPos(5000, 2500, -2500),
      ],
    ]) {
      final scale = rnd.nextDouble() + 0.5;

      final model = Model(
        position: position,
        size: Vector3(593, 559, 140),
        scale: Vector3(scale, scale, 1),
        rotation: rnd.nextInt(180) * degrees2Radians,
        image: await images.load('island.png'),
      );

      await add(model);

      const amountOfSlicesPerColor = 3;
      final colors = [
        for (var i = 0; i < amountOfSlicesPerColor; i++) Colors.red,
        for (var i = 0; i < amountOfSlicesPerColor; i++) Colors.green,
        for (var i = 0; i < amountOfSlicesPerColor; i++) Colors.blue,
      ];

      final SashimiObject object;
      switch (rnd.nextInt(2)) {
        case 0:
          object = ColoredCuboid(
            position: Vector3(position.x, position.y, 140),
            size: Vector3.all(100),
            scale: Vector3.all(1),
            rotation: rnd.nextInt(180) * degrees2Radians,
            colors: colors,
          );
          break;
        case 1:
          object = ColoredCylinder(
            position: Vector3(position.x, position.y, 140),
            height: 100,
            diameter: 100,
            scale: Vector3.all(1),
            rotation: rnd.nextInt(180) * degrees2Radians,
            colors: colors,
          );
          break;
        default:
          throw RangeError('Unknown value');
      }
      await add(object);
    }

    await add(
      Model(
        position: Vector3.zero(),
        size: Vector3(593, 559, 140),
        scale: Vector3(1, 1, 1),
        image: await images.load('island.png'),
      ),
    );

    await add(
      BillboardSprite(
        position: Vector3(290, -20, 140),
        size: Vector2.all(64),
        scale: Vector2.all(2),
        sprite: await Sprite.load('house.png', images: images),
      ),
    );

    // Create a single sliced colored cube to act as water.
    await add(
      ColoredCuboid(
        position: Vector3(0, 0, 0),
        size: Vector3(40000, 40000, 60),
        colors: [
          const Color(0xFF2152FF).withOpacity(0.2),
          const Color(0xFF2152FF).withOpacity(0.2),
          const Color(0xFF2152FF).withOpacity(0.2),
        ],
      ),
    );

    // Add a custom model that floats.
    await addAll([
      Cube(
        position: Vector3(-140, -200, 140),
        scale: Vector3.all(2),
        image: await images.load('test.png'),
      ),
      Cube(
        position: Vector3(0, 0, 140),
        scale: Vector3.all(4),
        image: await images.load('test.png'),
      ),
      cube = Cube(
        position: Vector3(140, 200, 140),
        scale: Vector3.all(6),
        image: await images.load('test.png'),
      ),
    ]);

    debugLogical = true;

    if (kDebugMode) {
      await addAll([FpsComponent(), _debugText]);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    engine.camera.position.setFrom(cube.position);

    _debugText.text = '''
FPS: ${(firstChild<FpsComponent>()?.fps ?? 0).toStringAsFixed(2)}
Fidelity: ${engine.fidelity}

Objects: ${descendants().whereType<SashimiObject>().length}
Slices: ${descendants().whereType<SashimiSlice>().length}

Zoom: ${engine.camera.zoom.toStringAsFixed(2)}
Rotation: ${(engine.camera.rotation * radians2Degrees % 360).toStringAsFixed(2)} degrees
Tilt: ${(engine.camera.tilt * radians2Degrees % 360).toStringAsFixed(2)} degrees
Position: ${engine.camera.position.x.toStringAsFixed(2)}, ${engine.camera.position.y.toStringAsFixed(2)}, ${engine.camera.position.z.toStringAsFixed(2)}
''';
  }

  final Map<int, Vector2> _dragPositions = {};
  Vector2? _dragStartPosition;
  double _previousDistance = 0;

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    _dragPositions[pointerId] = info.eventPosition.game;
    _dragStartPosition = info.eventPosition.global;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    _dragPositions.remove(pointerId);
    _dragStartPosition = null;
  }

  @override
  void onDragCancel(int pointerId) {
    _dragPositions.remove(pointerId);
    _dragStartPosition = null;
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    _dragPositions[pointerId] = info.eventPosition.game;

    // If two fingers are on the screen, zoom in/out
    if (_dragPositions.length == 2) {
      final distance = _dragPositions.values.first.distanceTo(
        _dragPositions.values.last,
      );

      if (_previousDistance != 0) {
        if (distance < _previousDistance) {
          engine.camera.zoom = (engine.camera.zoom * 1.01).clamp(0.1, 5);
        }
        if (distance > _previousDistance) {
          engine.camera.zoom = (engine.camera.zoom * 0.99).clamp(0.1, 5);
        }
      }
      _previousDistance = distance;
    } else {
      // If only pointer is on the screen, move the camera within the center
      // of the screen. Otherwise, rotate and tilt the camera.
      final centerRect = size * 0.25 & size * 0.5;
      if (centerRect.containsPoint(_dragStartPosition!)) {
        engine.camera.moveBy(
          Vector2.copy(-info.delta.game),
          // ..rotate(engine.camera.rotation)
          // ..scale(1.0 / engine.camera.zoom),
        );
      } else {
        engine.camera
          ..tilt += info.delta.game.y * 0.01
          ..rotation += info.delta.game.x * 0.01;
      }
    }
  }

  @override
  void onScroll(PointerScrollInfo info) {
    if (info.scrollDelta.game.y.isNegative) {
      engine.camera.zoom = (engine.camera.zoom * 1.1).clamp(0.1, 5);
    } else {
      engine.camera.zoom = (engine.camera.zoom * 0.99).clamp(0.1, 5);
    }
    super.onScroll(info);
  }
}

class Cube extends Model {
  Cube({
    required super.position,
    required super.image,
    super.scale,
  })  : _movingUp = Random().nextBool(),
        super(
          size: Vector3(16, 16, 16),
          rotation: Random().nextInt(360) * degrees2Radians,
        );

  bool _movingUp;

  @override
  void update(double dt) {
    if (position.z > 200) {
      _movingUp = false;
    } else if (position.z < 140) {
      _movingUp = true;
    }

    position.z += (_movingUp ? 1 : -1) * 10 * dt;
    rotation -= 1 * dt;
  }
}

void main() => runApp(GameWidget(game: ExampleGame()));
