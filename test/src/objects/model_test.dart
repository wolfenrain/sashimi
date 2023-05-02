import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Model', () {
    late Model model;
    late Model horizontalModel;

    setUp(() async {
      model = Model(
        position: Vector3(0, 0, 0),
        size: Vector3(593, 559, 140),
        scale: Vector3.all(0.5),
        image: await loadImage('island.png'),
      );

      horizontalModel = Model(
        position: Vector3(0, 0, 0),
        sliceSize: Vector2.all(16),
        size: Vector3(16, 16, 1),
        scale: Vector3.all(0.5),
        image: await loadImage('tram.png'),
        horizontalSlices: true,
      );
    });

    sashimiGame.testGameWidget(
      'horizontally slices sprite correctly loaded',
      setUp: (game, tester) => game.ensureAdd(horizontalModel),
      verify: (game, tester) async {
        final object = game.descendants().whereType<Model>().first
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

    testGolden(
      'renders correctly at 45 degrees',
      (game) async {
        await game.ensureAdd(horizontalModel);

        // We need to update twice to ensure the sprite is rendered correctly
        game
          ..update(0)
          ..update(0);
      },
      goldenFile: 'golden/model/H45.png',
      game: SashimiGame()..kamera.viewfinder.angle = 45 * degrees2Radians,
    );

    // ignore: cascade_invocations
    sashimiGame.testGameWidget(
      'controller position equals bottom slice position',
      setUp: (game, tester) => game.ensureAdd(model),
      verify: (game, tester) async {
        final object = game.descendants().whereType<Model>().first
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
          await game.ensureAdd(model);

          // We need to update twice to ensure the sprite is rendered correctly
          game
            ..update(0)
            ..update(0);
        },
        goldenFile: 'golden/model/$angle.png',
        game: SashimiGame()..kamera.viewfinder.angle = angle * degrees2Radians,
      );
    }
  });
}
