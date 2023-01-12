import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Model', () {
    for (final angle in List.generate(360 ~/ 10, (index) => 10 * index)) {
      testGolden(
        'renders correctly at $angle degrees',
        (game) async {
          await game.ensureAdd(
            Model(
              position: Vector3(0, 0, 0),
              size: Vector3(593, 559, 140),
              scale: Vector3.all(0.5),
              image: await loadImage('island.png'),
            ),
          );

          // We need to update twice to ensure the sprite is rendered correctly
          game
            ..update(0)
            ..update(0);
        },
        goldenFile: 'golden/model/$angle.png',
        game: SashimiGame()
          // Disabling culling as it is not correctly implemented yet
          ..visualCulling = false
          ..kamera.viewfinder.angle = angle * degrees2Radians,
      );
    }
  });
}
