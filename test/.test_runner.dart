// GENERATED CODE - DO NOT MODIFY BY HAND
// Consider adding this file to your .gitignore.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';


import 'src/objects/colored_cuboid_test.dart' as src_objects_colored_cuboid_test_dart;
import 'src/objects/model_test.dart' as src_objects_model_test_dart;
import 'src/objects/billboard_sprite_test.dart' as src_objects_billboard_sprite_test_dart;
import 'src/objects/colored_cylinder_test.dart' as src_objects_colored_cylinder_test_dart;
import 'src/math/notifying_vector3_test.dart' as src_math_notifying_vector3_test_dart;
import 'src/sashimi_slice_test.dart' as src_sashimi_slice_test_dart;
import 'src/components/cull_component_test.dart' as src_components_cull_component_test_dart;
import 'src/sashimi_object_test.dart' as src_sashimi_object_test_dart;
import 'src/sashimi_game_test.dart' as src_sashimi_game_test_dart;
import 'src/sashimi_engine_test.dart' as src_sashimi_engine_test_dart;
import 'src/sashimi_controller_test.dart' as src_sashimi_controller_test_dart;

void main() {
  goldenFileComparator = _TestOptimizationAwareGoldenFileComparator();
  group('src_objects_colored_cuboid_test_dart', () { src_objects_colored_cuboid_test_dart.main(); });
  group('src_objects_model_test_dart', () { src_objects_model_test_dart.main(); });
  group('src_objects_billboard_sprite_test_dart', () { src_objects_billboard_sprite_test_dart.main(); });
  group('src_objects_colored_cylinder_test_dart', () { src_objects_colored_cylinder_test_dart.main(); });
  group('src_math_notifying_vector3_test_dart', () { src_math_notifying_vector3_test_dart.main(); });
  group('src_sashimi_slice_test_dart', () { src_sashimi_slice_test_dart.main(); });
  group('src_components_cull_component_test_dart', () { src_components_cull_component_test_dart.main(); });
  group('src_sashimi_object_test_dart', () { src_sashimi_object_test_dart.main(); });
  group('src_sashimi_game_test_dart', () { src_sashimi_game_test_dart.main(); });
  group('src_sashimi_engine_test_dart', () { src_sashimi_engine_test_dart.main(); });
  group('src_sashimi_controller_test_dart', () { src_sashimi_controller_test_dart.main(); });
}


class _TestOptimizationAwareGoldenFileComparator extends LocalFileComparator {
  final List<String> goldenFilePaths;

  _TestOptimizationAwareGoldenFileComparator()
      : goldenFilePaths = _goldenFilePaths,
        super(_testFile);

  static Uri get _testFile {
    final basedir =
        (goldenFileComparator as LocalFileComparator).basedir.toString();
    return Uri.parse("$basedir/.test_runner.dart");
  }

  static List<String> get _goldenFilePaths =>
      Directory.fromUri((goldenFileComparator as LocalFileComparator).basedir)
          .listSync(recursive: true, followLinks: true)
          .whereType<File>()
          .map((file) => file.path)
          .where((path) => path.endsWith('.png'))
          .toList();

  @override
  Uri getTestUri(Uri key, int? version) {
    final keyString = key.path;
    return Uri.parse(goldenFilePaths
        .singleWhere((goldenFilePath) => goldenFilePath.endsWith(keyString)));
  }
}
