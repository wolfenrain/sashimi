import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart' as game;
import 'package:flutter/foundation.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_game}
/// The game that provides pseudo 3D features.
/// {@endtemplate}
class SashimiGame extends game.FlameGame {
  /// {@macro sashimi_game}
  SashimiGame({
    SashimiEngine? engine,
  }) : _engine = engine ?? SashimiEngine();

  @override
  @Deprecated(
    'Sashimi does not use the built-in camera, use `engine.camera` instead.',
  )
  game.Camera get camera => super.camera;

  /// The camera component that is used to render the world.
  @Deprecated('use `engine.camera` instead.')
  SashimiCamera get kamera => _engine.camera;

  final SashimiEngine _engine;

  /// The engine that powers the Sashimi game.
  SashimiEngine get engine => _engine;

  /// Whether the visual world should cull components.
  bool get visualCulling => _engine.visualCulling;
  set visualCulling(bool value) => _engine.visualCulling = value;

  /// Debug mode for the visual world.
  bool get debugVisual => _engine.debugVisual;
  set debugVisual(bool value) => _engine.debugVisual = value;

  /// Debug mode for the logical world.
  bool get debugLogical => _engine.debugLogical;
  set debugLogical(bool value) => _engine.debugLogical = value;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await super.onLoad();
    await add(_engine);
  }

  @override
  FutureOr<void> add(Component component) {
    // If the component is a SashimiObject or SashimiSlice, add it to the engine
    if (component is SashimiObject || component is SashimiSlice) {
      return _engine.add(component);
    }
    return super.add(component);
  }
}
