import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sashimi/sashimi.dart';

class ExampleGame extends SashimiGame
    with KeyboardEvents, MultiTouchDragDetector {
  final TextComponent _debugText = TextComponent(
    scale: Vector2.all(0.75),
    textRenderer: TextPaint(
      style: TextPaint.defaultTextStyle.copyWith(color: Colors.green),
    ),
  );

  final rnd = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    double value(int max) => rnd.nextInt(max) - max / 2;

    for (final position in [
      for (var i = 0; i < 10; i++) ...[
        Vector3(value(5000) - 2500, value(5000) - 2500, 0),
        Vector3(value(5000) + 2500, value(5000) + 2500, 0),
        Vector3(value(5000) - 2500, value(5000) + 2500, 0),
        Vector3(value(5000) + 2500, value(5000) - 2500, 0),
        Vector3(value(5000), value(5000), 0),
      ],
    ]) {
      final scale = rnd.nextDouble() + 0.5;

      final model = Model(
        position: position,
        size: Vector3(593, 559, 140),
        scale: Vector3(scale, scale, 1),
        angle: rnd.nextInt(180) * degrees2Radians,
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
            angle: rnd.nextInt(180) * degrees2Radians,
            colors: colors,
          );
          break;
        case 1:
          object = ColoredCylinder(
            position: Vector3(position.x, position.y, 140),
            height: 100,
            diameter: 100,
            scale: Vector3.all(1),
            angle: rnd.nextInt(180) * degrees2Radians,
            colors: colors,
          );
          break;
        default:
          throw UnimplementedError('value: $value');
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
        position: Vector3(0, 0, 140),
        size: Vector2.all(64),
        scale: Vector2.all(2),
        sprite: await Sprite.load('house.png', images: images),
      ),
    );

    kamera
      ..follow(PositionComponent())
      ..viewfinder.zoom = 1;

    // Create a single sliced colored cube to act as water.
    await add(
      ColoredCuboid(
        position: Vector3(0, 0, 60),
        size: Vector3(40000, 40000, 1),
        colors: [const Color(0xFF2152FF).withOpacity(0.55)],
      ),
    );

    if (kDebugMode) {
      await addAll([FpsComponent(), _debugText]);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final rotateLeft = _keysPressed.contains(LogicalKeyboardKey.keyQ);
    final rotateRight = _keysPressed.contains(LogicalKeyboardKey.keyE);
    final rotation = rotateLeft ? 1 : (rotateRight ? -1 : 0);
    kamera.rotation += rotation * dt;

    final zoomIn = _keysPressed.contains(LogicalKeyboardKey.keyZ);
    final zoomOut = _keysPressed.contains(LogicalKeyboardKey.keyX);
    final zoom = zoomIn ? 1 : (zoomOut ? -1 : 0);
    kamera.zoom = (kamera.zoom + zoom * dt).clamp(0.1, 5);

    _debugText.text = '''
FPS: ${(firstChild<FpsComponent>()?.fps ?? 0).toStringAsFixed(2)}

Objects: ${descendants().whereType<SashimiObject>().length}
Components: ${descendants().whereType<SashimiSlice>().length}

Zoom: ${kamera.zoom.toStringAsFixed(2)}
Rotation: ${(kamera.rotation * radians2Degrees % 360).toStringAsFixed(2)} degrees
Position: ${kamera.position.x.toStringAsFixed(2)}, ${kamera.position.y.toStringAsFixed(2)}
''';
  }

  Set<LogicalKeyboardKey> _keysPressed = {};

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    _keysPressed = keysPressed;
    return KeyEventResult.handled;
  }

  final Map<int, Vector2> _dragPositions = {};
  double _previousDistance = 0;

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    _dragPositions[pointerId] = info.eventPosition.game;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    _dragPositions.remove(pointerId);
  }

  @override
  void onDragCancel(int pointerId) {
    _dragPositions.remove(pointerId);
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
          kamera.zoom = (kamera.zoom * 1.05).clamp(0.1, 5);
        }
        if (distance > _previousDistance) {
          kamera.zoom = (kamera.zoom * (1.0 / 1.05)).clamp(0.1, 5);
        }
      }
      _previousDistance = distance;
    } else {
      kamera.moveBy(
        Vector2.copy(-info.delta.game)
          ..rotate(kamera.viewfinder.angle)
          ..scale(1.0 / kamera.viewfinder.zoom),
      );
    }
  }
}

void main() => runApp(GameWidget(game: ExampleGame()));
