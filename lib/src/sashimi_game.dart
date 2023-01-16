import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart' as game;
import 'package:flutter/foundation.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_game}
/// The game that provides pseudo 3D features.
/// {@endtemplate}
class SashimiGame extends game.FlameGame {
  @override
  @Deprecated('Sashimi does not use the built-in camera, use `kamera` instead.')
  game.Camera get camera => super.camera;

  /// The camera component that is used to render the world.
  SashimiCamera get kamera => _engine.camera;

  final SashimiEngine _engine = SashimiEngine();

  /// The engine that is used to render the game.
  @visibleForTesting
  SashimiEngine get engine => _engine;

  /// Whether the visual world should cull components.
  bool get visualCulling => _engine.visualCulling;
  set visualCulling(bool value) => _engine.visualCulling = value;

  /// Whether the logical world should cull components.
  bool get logicalCulling => _engine.logicalCulling;
  set logicalCulling(bool value) => _engine.logicalCulling = value;

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
