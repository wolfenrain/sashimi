import 'package:flame/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../../helpers/helpers.dart';

void main() {
  group('BillboardSprite', () {
    for (final angle in List.generate(360 ~/ 10, (index) => 10 * index)) {
      testGolden(
        'renders correctly at $angle degrees',
        (game) async {
          await game.ensureAdd(
            BillboardSprite(
              position: Vector3(0, 0, 0),
              size: Vector2.all(64),
              scale: Vector2.all(2),
              sprite: Sprite(await loadImage('house.png')),
            ),
          );

          // We need to update twice to ensure the sprite is rendered correctly
          game
            ..update(0)
            ..update(0);
        },
        goldenFile: 'golden/billboard_sprite/$angle.png',
        game: SashimiGame()..kamera.viewfinder.angle = angle * degrees2Radians,
      );
    }
  });
}
