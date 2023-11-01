import 'dart:math';

import 'package:graphics_lab6/primtives.dart';

class Matrix {
  Matrix(int rows, int cols, this.value);

  Matrix.point(Point3D point) : this(1, 4, [[point.x, point.y, point.z, 1]]);

  Matrix.trimetric(double xAngle, double yAngle)
    : this(4, 4,
      [
        [cos(yAngle), sin(xAngle) * sin(yAngle), 0, 0],
        [0, cos(xAngle), 0, 0],
        [sin(yAngle), -sin(xAngle) * cos(yAngle), 0, 0],
        [0, 0, 0, 1],
      ]
  );

  Matrix.dimetric(double zRatio, bool xAnglePos, bool yAnglePos) : this.trimetric(
    asin(zRatio * (xAnglePos ? 1 : -1) / sqrt2),
    asin(zRatio * (yAnglePos ? 1 : -1) / sqrt(2 - zRatio * zRatio))
  );

  Matrix.isometric(bool xAnglePos, bool yAnglePos) : this.dimetric(0.8165, xAnglePos, yAnglePos);

  Matrix.perspective1(double zProjectionCenter) : this(4, 4,
    [
      [1, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 0, -1/zProjectionCenter],
      [0, 0, 0, 1],
    ]
  );

  Matrix.perspective2(double xProjectionCenter, double yProjectionCenter) : this(4, 4,
    [
      [1, 0, 0, -1/xProjectionCenter],
      [0, 1, 0, -1/yProjectionCenter],
      [0, 0, 0, 0],
      [0, 0, 0, 1],
    ]
  );

  Matrix.perspective3(double xProjectionCenter, double yProjectionCenter, double zProjectionCenter) : this(4, 4,
    [
      [1, 0, 0, -1/xProjectionCenter],
      [0, 1, 0, -1/yProjectionCenter],
      [0, 0, 0, -1/zProjectionCenter],
      [0, 0, 0, 1],
    ]
  );

  Matrix.translation(Point3D tr)
    : this(4, 4,
    [
      [1, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],
      [tr.x, tr.y, tr.z, 1],
    ]
  );

  Matrix.scaling(Point3D sc)
      : this(4, 4,
      [
        [sc.x, 0, 0, 0],
        [0, sc.y, 0, 0],
        [0, 0, sc.z, 0],
        [0, 0, 0, 1],
      ]
  );

  Matrix.rotation(double a, Point3D v)
    : this(4, 4,
    [
      [v.x * v.x + cos(a) * (1 - v.x * v.x), v.x * (1 - cos(a)) * v.y + v.z * sin(a), v.x * (1 - cos(a)) * v.z - v.y * sin(a), 0],
      [v.x * (1 - cos(a)) * v.y - v.z * sin(a), v.y * v.y + cos(a) * (1 - v.y * v.y), v.y * (1 - cos(a)) * v.z + v.x * sin(a), 0],
      [v.x * (1 - cos(a)) * v.z + v.y * sin(a), v.y * (1 - cos(a)) * v.z - v.x * sin(a), v.z * v.z + cos(a) * (1 - v.z * v.z), 0],
      [0, 0, 0, 1]
    ]
  );



  // Matrix.scaling(double k, double x, double y)
  //     : this(3, 3, [
  //   [k,0,0,],
  //   [0,k,0],
  //   [-x*(k-1),-y*(k-1), -1],
  // ]);


  final List<List<double>> value;

  int get rows => value.length;

  int get cols => value[0].length;

  List<double> operator [](int index) {
    return value[index];
  }

  Matrix operator *(Matrix other) {
    final newValue = List.filled(rows, List.filled(other.cols, 0.0));
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < other.cols; j++) {
        for (int k = 0; k < cols; k++) {
          newValue[i][j] += this[i][k] * other[k][j];
        }
      }
    }
    return Matrix(rows, other.cols, newValue);
  }
}
