import 'matrix.dart';

abstract interface class IPoints{
 List<Point3D> get points;
}

class Point3D{
  double x, y, z;
  double h;
  Point3D(this.x, this.y, this.z, [this.h = 1]);
  Point3D.zero() : this(0, 0, 0);
  updateWithVector(Matrix matrix){
    x = matrix[0][0];
    y = matrix[0][1];
    z = matrix[0][2];
    h = matrix[0][3];
  }
  Point3D copy() => Point3D(x, y, z);

  Point3D operator -(Point3D other){
    return Point3D(x - other.x, y - other.y, z - other.z, h);
  }

  Point3D operator -(){
    return Point3D(-x, -y, -z, h);
  }

  Point3D operator +(Point3D other){
    return Point3D(x + other.x, y + other.y, z + other.z, h);
  }

  Point3D operator /(num d){
    return Point3D(x/d, y/d, z/d);
  }
}

class Edge implements IPoints{
  final Point3D start, end;
  Edge(this.start, this.end);
  @override
  List<Point3D> get points => [start, end];
}

class Polygon implements IPoints{
  @override
  final List<Point3D> points;
  Polygon(this.points);
}

class Polyhedron implements IPoints{
  final List<Polygon> polygons;
  @override
  final List<Point3D> points;
  final List<List<int>> _polygonsByIndexes;
  Polyhedron(this.points, this._polygonsByIndexes) : polygons = [] {
    for (var polygonIndexes in _polygonsByIndexes){
      polygons.add(
        Polygon(List.generate(polygonIndexes.length, (i) => points[polygonIndexes[i]]))
      );
    }
  }

  Point3D get center {
    var sum = Point3D.zero();
    for (var point in points){
      sum = sum + point;
    }
    return sum / points.length;
  }

  Polyhedron getTransformed(Matrix transform){
    final res = copy();
    for(var point in res.points){
      point.updateWithVector(Matrix.point(point) * transform);
    }
    return res;
  }

  Polyhedron copy(){
    return Polyhedron(
      List.generate(points.length, (index) => points[index].copy()),
      _polygonsByIndexes
    );
  }

  static Polyhedron get cube => Polyhedron(
      [
        Point3D(1, 0, 0),
        Point3D(1, 1, 0),
        Point3D(0, 1, 0),
        Point3D(0, 0, 0),
        Point3D(0, 0, 1),
        Point3D(0, 1, 1),
        Point3D(1, 1, 1),
        Point3D(1, 0, 1),
      ],
      [
        [0, 1, 2, 3],
        [5, 2, 1, 6],
        [4, 5, 6, 7],
        [3, 4, 7, 0],
        [7, 6, 1, 0],
        [3, 2, 5, 4],
      ]
  );

  static get tetrahedron => Polyhedron(
      [
        Point3D(1, 0, 0),
        Point3D(0, 0, 1),
        Point3D(0, 1, 0),
        Point3D(1, 1, 1),
      ],
      [
        [0, 2, 1],
        [1, 2, 3],
        [0, 3, 2],
        [0, 1, 3]
      ]
  );

  static get octahedron => Polyhedron(
      [
        Point3D(0.5, 1, 0.5),
        Point3D(0.5, 0.5, 1),
        Point3D(0, 0.5, 0.5),
        Point3D(0.5, 0.5, 0),
        Point3D(1, 0.5, 0.5),
        Point3D(0.5, 0, 0.5),
      ],
      [
        [0, 4, 1],
        [0, 3, 4],
        [0, 2, 3],
        [0, 1, 2],
        [5, 1, 4],
        [5, 4, 3],
        [5, 3, 2],
        [5, 2, 1],
      ]
  );
}