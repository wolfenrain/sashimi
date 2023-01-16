import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ColoredCylinder', () {
    late ColoredCylinder cylinder;

    setUp(() {
      cylinder = ColoredCylinder(
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
      );
    });

    sashimiGame.testGameWidget(
      'controller position equals bottom slice position',
      setUp: (game, tester) => game.ensureAdd(cylinder),
      verify: (game, tester) async {
        final object = game.descendants().whereType<ColoredCylinder>().first
          ..position.setValues(10, 10, 10)
          ..angle = 10 * degrees2Radians;

        game
          ..update(0)
          ..update(0);

        final controller = object.controller;
        final slice = object.slices.first;

        expect(slice.position, equals(controller.position));
      },
    );

    for (final angle in List.generate(360 ~/ 10, (index) => 10 * index)) {
      testGolden(
        'renders correctly at $angle degrees',
        (game) async {
          await game.ensureAdd(cylinder);

          // We need to update twice to ensure the sprite is rendered correctly
          game
            ..update(0)
            ..update(0);
        },
        goldenFile: 'golden/colored_cylinder/$angle.png',
        game: SashimiGame()..kamera.viewfinder.angle = angle * degrees2Radians,
      );
    }
  });
}
