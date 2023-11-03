import 'dart:math';

import 'matrix.dart';

abstract interface class IPoints {
  List<Point3D> get points;
}

class Point3D {
  double x, y, z;
  double h;
  Point3D(this.x, this.y, this.z, [this.h = 1]);
  Point3D.zero() : this(0, 0, 0);
  updateWithVector(Matrix matrix) {
    x = matrix[0][0];
    y = matrix[0][1];
    z = matrix[0][2];
    h = matrix[0][3];
  }

  Point3D copy() => Point3D(x, y, z);

  Point3D operator -(Point3D other) {
    return Point3D(x - other.x, y - other.y, z - other.z, h);
  }

  Point3D operator -() {
    return Point3D(-x, -y, -z, h);
  }

  Point3D operator +(Point3D other) {
    return Point3D(x + other.x, y + other.y, z + other.z, h);
  }

  Point3D operator /(num d) {
    return Point3D(x / d, y / d, z / d);
  }
}

class Edge implements IPoints {
  final Point3D start, end;
  Edge(this.start, this.end);
  @override
  List<Point3D> get points => [start, end];
}

class Polygon implements IPoints {
  @override
  final List<Point3D> points;
  Polygon(this.points);
}

class Model implements IPoints {
  final List<Polygon> polygons;
  @override
  final List<Point3D> points;
  final List<List<int>> _polygonsByIndexes;
  Model(this.points, this._polygonsByIndexes) : polygons = [] {
    for (var polygonIndexes in _polygonsByIndexes) {
      polygons.add(Polygon(List.generate(
          polygonIndexes.length, (i) => points[polygonIndexes[i]])));
    }
  }

  Point3D get center {
    var sum = Point3D.zero();
    for (var point in points) {
      sum = sum + point;
    }
    return sum / points.length;
  }

  Model getTransformed(Matrix transform) {
    final res = copy();
    for (var point in res.points) {
      point.updateWithVector(Matrix.point(point) * transform);
    }
    return res;
  }

  Model copy() {
    return Model(
        List.generate(points.length, (index) => points[index].copy()),
        _polygonsByIndexes);
  }

  static Model get cube => Model([
        Point3D(1, 0, 0),
        Point3D(1, 1, 0),
        Point3D(0, 1, 0),
        Point3D(0, 0, 0),
        Point3D(0, 0, 1),
        Point3D(0, 1, 1),
        Point3D(1, 1, 1),
        Point3D(1, 0, 1),
      ], [
        [0, 1, 2, 3],
        [5, 2, 1, 6],
        [4, 5, 6, 7],
        [3, 4, 7, 0],
        [7, 6, 1, 0],
        [3, 2, 5, 4],
      ]);

  static get tetrahedron => Model([
        Point3D(1, 0, 0),
        Point3D(0, 0, 1),
        Point3D(0, 1, 0),
        Point3D(1, 1, 1),
      ], [
        [0, 2, 1],
        [1, 2, 3],
        [0, 3, 2],
        [0, 1, 3]
      ]);

  static get octahedron => Model([
        Point3D(0.5, 1, 0.5),
        Point3D(0.5, 0.5, 1),
        Point3D(0, 0.5, 0.5),
        Point3D(0.5, 0.5, 0),
        Point3D(1, 0.5, 0.5),
        Point3D(0.5, 0, 0.5),
      ], [
        [0, 4, 1],
        [0, 3, 4],
        [0, 2, 3],
        [0, 1, 2],
        [5, 1, 4],
        [5, 4, 3],
        [5, 3, 2],
        [5, 2, 1],
      ]);

  static double phi = (1 + sqrt(5)) / 2;

  static get icosahedron => Model(
          [
            Point3D(0, phi, 1),
            Point3D(0, phi, -1),
            Point3D(phi, 1, 0),
            Point3D(-phi, 1, 0),
            Point3D(1, 0, phi),
            Point3D(1, 0, -phi),
            Point3D(-1, 0, phi),
            Point3D(-1, 0, -phi),
            Point3D(phi, -1, 0),
            Point3D(-phi, -1, 0),
            Point3D(0, -phi, 1),
            Point3D(0, -phi, -1),
          ].map((e) => e / phi).toList(),
          [
            [0, 1, 2],
            [0, 1, 3],
            [0, 2, 4],
            [0, 3, 6],
            [0, 4, 6],
            [1, 2, 5],
            [1, 3, 7],
            [1, 5, 7],
            [2, 4, 8],
            [2, 5, 8],
            [3, 6, 9],
            [3, 7, 9],
            [4, 6, 10],
            [4, 8, 10],
            [5, 7, 11],
            [5, 8, 11],
            [6, 9, 10],
            [7, 9, 11],
            [8, 10, 11],
            [9, 10, 11],
          ]);

  static get dodecahedron {
    final double iphi = 1 / phi;
    return Model(
        [
          Point3D(1, 1, 1), // 0
          Point3D(1, 1, -1), // 1
          Point3D(1, -1, 1), // 2
          Point3D(1, -1, -1), // 3
          Point3D(-1, 1, 1), // 4
          Point3D(-1, 1, -1), // 5
          Point3D(-1, -1, 1), // 6
          Point3D(-1, -1, -1), // 7
          Point3D(0, phi, iphi), // 8
          Point3D(0, phi, -iphi), // 9
          Point3D(0, -phi, iphi), // 10
          Point3D(0, -phi, -iphi), // 11
          Point3D(iphi, 0, phi), // 12
          Point3D(-iphi, 0, phi), // 13
          Point3D(iphi, 0, -phi), // 14
          Point3D(-iphi, 0, -phi), // 15
          Point3D(phi, iphi, 0), // 16
          Point3D(phi, -iphi, 0), // 17
          Point3D(-phi, iphi, 0), // 18
          Point3D(-phi, -iphi, 0), // 19
        ].map((e) => e / phi).toList(),
        [
          [8, 9, 1, 16, 0],
          [8, 9, 5, 18, 4],
          [10, 11, 3, 17, 2],
          [10, 11, 7, 19, 6],
          [12, 13, 4, 8, 0],
          [12, 13, 6, 10, 2],
          [14, 15, 5, 9, 1],
          [14, 15, 7, 11, 3],
          [16, 17, 2, 12, 0],
          [16, 17, 3, 14, 1],
          [18, 19, 6, 13, 4],
          [18, 19, 7, 15, 5],
        ]);
  }
}
