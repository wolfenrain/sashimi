import 'dart:math';

import 'package:flame/experimental.dart';
import 'package:sashimi/sashimi.dart';

/// {@template sashimi_camera}
/// The camera used by the Sashimi Engine.
/// {@endtemplate}
class SashimiCamera extends CameraComponent {
  // TODO(wolfen): do we really need the camera component

  /// {@macro sashimi_camera}
  SashimiCamera({
    double initialTilt = 45 * degrees2Radians,
    this.minimalTilt = 22.5 * degrees2Radians,
    this.maximalTilt = 67.5 * degrees2Radians,
  })  : _tilt = initialTilt.clamp(minimalTilt, maximalTilt),
        super(world: SashimiWorld());

  /// The world rotation of the camera.
  double rotation = 0;

  double minimalTilt;
  double maximalTilt;

  double get tilt => _tilt;
  double _tilt;
  set tilt(double tilt) => _tilt = tilt.clamp(minimalTilt, maximalTilt);

  /// The zoom of the camera.
  double get zoom => viewfinder.zoom;
  set zoom(double zoom) => viewfinder.zoom = zoom.clamp(0.01, double.infinity);

  /// The position of the camera.
  // Vector2 get position => viewfinder.position;
  // set position(Vector2 value) => viewfinder.position = value;
  Vector3 position = Vector3.zero();

  final projection = Matrix4.zero();

  @override
  Rect get visibleWorldRect {
    viewfinder.angle = rotation;
    final viewportSize = viewport.size;
    final topLeft = viewfinder.transform.globalToLocal(Vector2.zero());
    final bottomRight = viewfinder.transform.globalToLocal(viewportSize);
    var minX = min(topLeft.x, bottomRight.x);
    var minY = min(topLeft.y, bottomRight.y);
    var maxX = max(topLeft.x, bottomRight.x);
    var maxY = max(topLeft.y, bottomRight.y);
    if (rotation != 0) {
      final topRight =
          viewfinder.transform.globalToLocal(Vector2(viewportSize.x, 0));
      final bottomLeft =
          viewfinder.transform.globalToLocal(Vector2(0, viewportSize.y));
      minX = min(minX, min(topRight.x, bottomLeft.x));
      minY = min(minY, min(topRight.y, bottomLeft.y));
      maxX = max(maxX, max(topRight.x, bottomLeft.x));
      maxY = max(maxY, max(topRight.y, bottomLeft.y));
    }

    viewfinder.angle = 0;

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  void update(double dt) {
    _projectionOrtho(viewport.size, -10000, 10000);

    const distance = 1;
    final pos = Vector3(
      position.x + distance * cos(rotation) * cos(tilt),
      position.y + distance * sin(rotation) * cos(tilt),
      position.z + distance * sin(tilt),
    );
    final at = Vector3(position.x, position.y, position.z);
    final up = Vector3(0, 0, 1);

    projection.lookAt(pos, at, up);

    // TODO: set the 2d position on the viewfinder maybe?

    super.update(dt);
  }

  void _projectionOrtho(Vector2 size, double near, double far) {
    projection.setIdentity();
    // Avoid division by zero.
    if (size.x == 0 || size.y == 0 || near == far) return;

    projection[0] = 2 * near / size.x;
    projection[1] = projection[2] = projection[3] = 0;

    projection[5] = 2 * near / size.y;
    projection[4] = projection[6] = projection[7] = 0;

    projection[8] = projection[9] = 0;
    projection[11] = 1;
    projection[10] = far / (far - near);

    projection[12] = projection[13] = projection[15] = 0;
    projection[14] = -near * far / (far - near);
  }
}

extension on Matrix4 {
  void lookAt(Vector3 position, Vector3 at, Vector3 upV) {
    final up = upV.clone()..normalize();
    final right = Vector3.zero();
    final look = (at - position)..normalize();

    right
      ..setFrom(up.cross(look))
      ..normalize();

    up
      ..setFrom(look.cross(right))
      ..normalize();

    final x = position.projection(right);
    final y = position.projection(up);
    final z = position.projection(look);

    this[0] = right.x;
    this[1] = up.x;
    this[2] = look.x;
    this[3] = 0.0;

    this[4] = right.y;
    this[5] = up.y;
    this[6] = look.y;
    this[7] = 0.0;

    this[8] = right.z;
    this[9] = up.z;
    this[10] = look.z;
    this[11] = 0.0;

    this[12] = -x;
    this[13] = -y;
    this[14] = -z;
    this[15] = 1;
  }
}

extension on Vector3 {
  double projection(Vector3 pVec) => (x * pVec.x) + (y * pVec.y) + (z * pVec.z);
}

extension Matrix4X on Matrix4 {
  void build({
    double positionX = 0,
    double positionY = 0,
    double positionZ = 0,
    double rotationX = 0,
    double rotationY = 0,
    double rotationZ = 0,
    double scaleX = 1,
    double scaleY = 1,
    double scaleZ = 1,
  }) {
    final sinp = sin(rotationX);
    final cosp = cos(rotationX);
    final sinh = sin(rotationY);
    final cosh = cos(rotationY);
    final sinr = sin(rotationZ);
    final cosr = cos(rotationZ);

    final sinrsinp = -sinr * -sinp; // common elements
    final cosrsinp = cosr * -sinp;

    this[0] = ((cosr * cosh) + (sinrsinp * -sinh)) * scaleX;
    this[4] = (-sinr * cosp) * scaleX;
    this[8] = ((cosr * sinh) + (sinrsinp * cosh)) * scaleX;
    this[12] = positionX;

    this[1] = ((sinr * cosh) + (cosrsinp * -sinh)) * scaleY;
    this[5] = (cosr * cosp) * scaleY;
    this[9] = ((sinr * sinh) + (cosrsinp * cosh)) * scaleY;
    this[13] = positionY;

    this[2] = (cosp * -sinh) * scaleZ;
    this[6] = sinp * scaleZ;
    this[10] = (cosp * cosh) * scaleZ;
    this[14] = positionZ;

    this[3] = this[7] = this[11] = 0.0;
    this[15] = 1.0;
  }
}
