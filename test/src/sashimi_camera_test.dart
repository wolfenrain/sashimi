// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../helpers/helpers.dart';

void main() {
  group('SashimiCamera', () {
    sashimiGame.testGameWidget(
      'camera rotation',
      verify: (game, tester) async {
        game.engine.camera.rotation = 45 * degrees2Radians;

        expect(game.engine.camera.rotation, equals(45 * degrees2Radians));
        expect(
          game.engine.camera.viewfinder.angle,
          equals(45 * degrees2Radians),
        );
      },
    );

    sashimiGame.testGameWidget(
      'camera zoom',
      verify: (game, tester) async {
        game.engine.camera.zoom = 0.5;

        expect(game.engine.camera.zoom, equals(0.5));
        expect(game.engine.camera.viewfinder.zoom, equals(0.5));
      },
    );

    sashimiGame.testGameWidget(
      'camera position',
      verify: (game, tester) async {
        game.engine.camera.position = Vector3.all(0.5);

        expect(game.engine.camera.position, equals(Vector3.all(0.5)));
        expect(
          game.engine.camera.viewfinder.position,
          equals(Vector2.all(0.5)),
        );
      },
    );
  });
}
