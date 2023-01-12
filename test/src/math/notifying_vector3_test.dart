import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sashimi/sashimi.dart';

void main() {
  /// This helper function creates a "normal" Vector3 copy of [v1],
  /// then applies [operation] to both vectors, and verifies that the
  /// end result is the same. It also checks that [v1] produces a
  /// notification during a modifying operation.
  void check(NotifyingVector3 v1, void Function(Vector3) operation) {
    final v2 = v1.clone();
    expect(v2 is NotifyingVector3, false);
    var notified = 0;
    void listener() => notified++;

    v1.addListener(listener);
    operation(v1);
    operation(v2);
    v1.removeListener(listener);
    expect(notified, 1);
    expect(v1, v2);
  }

  group('NotifyingVector3', () {
    test('constructors', () {
      final nv0 = NotifyingVector3.zero();
      expect(nv0, Vector3.zero());
      final nv1 = NotifyingVector3(3, 1415, 5);
      expect(nv1, Vector3(3, 1415, 5));
      final nv2 = NotifyingVector3.all(111);
      expect(nv2, Vector3.all(111));
      final nv3 = NotifyingVector3.copy(Vector3(4, 9, 8));
      expect(nv3, Vector3(4, 9, 8));
    });

    test('full setters', () {
      final nv = NotifyingVector3.zero();
      check(nv, (v) => v.setValues(3, 2, 1));
      check(nv, (v) => v.setFrom(Vector3(5, 8, 9)));
      check(nv, (v) => v.setZero());
      check(nv, (v) => v.splat(3.2));
      check(nv, (v) => v.copyFromArray([1, 2, 3, 4, 5]));
      check(nv, (v) => v.copyFromArray([1, 2, 3, 4, 5], 2));
      check(nv, (v) => v.xy = Vector2(7, 2));
      check(nv, (v) => v.yx = Vector2(7, 2));
      check(nv, (v) => v.rg = Vector2(1, 10));
      check(nv, (v) => v.gr = Vector2(1, 10));
      check(nv, (v) => v.st = Vector2(-5, -89));
      check(nv, (v) => v.ts = Vector2(-5, -89));
      check(nv, (v) => v.xyz = Vector3(7, 2, 1));
      check(nv, (v) => v.yxz = Vector3(7, 2, 1));
      check(nv, (v) => v.zxy = Vector3(7, 2, 1));
      check(nv, (v) => v.yzx = Vector3(7, 2, 1));
      check(nv, (v) => v.rgb = Vector3(1, 10, 9));
      check(nv, (v) => v.grb = Vector3(1, 10, 9));
      check(nv, (v) => v.stp = Vector3(-5, -89, 5));
      check(nv, (v) => v.tsp = Vector3(-5, -89, 5));
    });

    test('individual field setters', () {
      final nv = NotifyingVector3.zero();
      check(nv, (v) => v[0] = 2.5);
      check(nv, (v) => v[1] = 1.25);
      check(nv, (v) => v.x = 425);
      check(nv, (v) => v.y = -1.11e-11);
      check(nv, (v) => v.z = 400);
      check(nv, (v) => v.r = 101);
      check(nv, (v) => v.g = 102);
      check(nv, (v) => v.b = 20);
      check(nv, (v) => v.s = 103);
      check(nv, (v) => v.t = 104);
      check(nv, (v) => v.p = 100);
    });

    test('modification methods', () {
      final nv = NotifyingVector3(23, 3, 1);
      check(nv, (v) => v.length = 15);
      check(nv, (v) => v.normalize());
      check(nv, (v) => v.postmultiply(Matrix3.rotationZ(1)));
      check(nv, (v) => v.add(Vector3(0.2, -0.1, 5)));
      check(nv, (v) => v.addScaled(Vector3(2.05, 1.1, 5), 3));
      check(nv, (v) => v.sub(Vector3(9.7, 4.62, 4)));
      check(nv, (v) => v.multiply(Vector3(1.2, -0.62, 4)));
      check(nv, (v) => v.divide(Vector3(0.69, 1.23, 1)));
      check(nv, (v) => v.scale(7.802));
      check(nv, (v) => v.negate());
      check(nv, (v) => v.absolute());
      check(nv, (v) => v.clamp(Vector3(-5, -6, 1), Vector3(100, 1e20, 200)));
      check(nv, (v) => v.clampScalar(-2, 38479.10349));
      check(nv, (v) => v.floor());
      nv.scale(1.3891);
      check(nv, (v) => v.ceil());
      nv.scale(1.111);
      check(nv, (v) => v.round());
      nv.multiply(Vector3(1.23, -4.791, 6));
      check(nv, (v) => v.roundToZero());
    });

    test('storage is read-only', () {
      final nv = NotifyingVector3.zero();
      expect(nv, Vector3.zero());
      final storage = nv.storage;
      // Check that storage is not writable
      expect(() => storage[0] = 1, throwsA(isA<UnsupportedError>()));
      // Check that the vector wasn't modified, and that storage is readable
      expect(storage[0], 0);
      expect(storage[1], 0);
      expect(storage[2], 0);
    });
  });
}
