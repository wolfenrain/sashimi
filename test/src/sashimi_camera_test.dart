// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

import '../helpers/helpers.dart';

void main() {
  group('SashimiCamera', () {
    sashimiGame.testGameWidget(
      'camera rotation',
      verify: (game, tester) async {
        game.kamera.rotation = 45 * degrees2Radians;

        expect(game.kamera.rotation, equals(45 * degrees2Radians));
        expect(game.kamera.viewfinder.angle, equals(45 * degrees2Radians));
      },
    );

    sashimiGame.testGameWidget(
      'camera zoom',
      verify: (game, tester) async {
        game.kamera.zoom = 0.5;

        expect(game.kamera.zoom, equals(0.5));
        expect(game.kamera.viewfinder.zoom, equals(0.5));
      },
    );

    sashimiGame.testGameWidget(
      'camera position',
      verify: (game, tester) async {
        game.kamera.position = Vector2.all(0.5);

        expect(game.kamera.position, equals(Vector2.all(0.5)));
        expect(game.kamera.viewfinder.position, equals(Vector2.all(0.5)));
      },
    );
  });
}
