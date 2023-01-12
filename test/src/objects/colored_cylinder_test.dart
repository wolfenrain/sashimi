import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ColoredCylinder', () {
    for (final angle in List.generate(360 ~/ 10, (index) => 10 * index)) {
      testGolden(
        'renders correctly at $angle degrees',
        (game) async {
          await game.ensureAdd(
            ColoredCylinder(
              position: Vector3(0, 0, 0),
              height: 100,
              diameter: 100,
              colors: const [
                Color(0xFFFF0000),
                Color(0xFFFF0000),
                Color(0xFFFF0000),
                Color(0xFF00FF00),
                Color(0xFF00FF00),
                Color(0xFF00FF00),
                Color(0xFF0000FF),
                Color(0xFF0000FF),
                Color(0xFF0000FF),
              ],
            ),
          );

          // We need to update twice to ensure the sprite is rendered correctly
          game
            ..update(0)
            ..update(0);
        },
        goldenFile: 'golden/colored_cylinder/$angle.png',
        game: SashimiGame()
          // Disabling culling as it is not correctly implemented yet
          ..visualCulling = false
          ..kamera.viewfinder.angle = angle * degrees2Radians,
      );
    }
  });
}
