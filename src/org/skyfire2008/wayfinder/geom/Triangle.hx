package org.skyfire2008.wayfinder.geom;

using org.skyfire2008.wayfinder.geom.Point;

class Triangle {
	public var p0(default, null): Point;
	public var p1(default, null): Point;
	public var p2(default, null): Point;

	private var n0: Point;
	private var n1: Point;
	private var n2: Point;

	public function new(p0: Point, p1: Point, p2: Point) {
		this.p0 = p0;
		this.p1 = p1;
		this.p2 = p2;

		this.n0 = p1.difference(p0);
		n0.rotate90();
		this.n1 = p2.difference(p1);
		n1.rotate90();
		this.n2 = p0.difference(p2);
		n2.rotate90();
	}

	public function containsPoint(p: Point): Bool {
		var s0 = n0.dot(p) >= 0;
		var s1 = n1.dot(p) >= 0;
		var s2 = n2.dot(p) >= 0;
		return s0 == s1 && s1 == s2;
	}

	public static function triangulate(width: Float, height: Float, points: Array<Point>): Array<Triangle> {
		var a = new Point(0, 0);
		var b = new Point(0, height);
		var c = new Point(width, 0);
		var d = new Point(width, height);
		var result: Array<Triangle> = [new Triangle(a, b, c), new Triangle(a, d, c)];

		for (p in points) {
			for (i in 0...result.length) {
				var tri = result[i];
				if (tri.containsPoint(p)) {
					result.splice(i, 1);
					result.push(new Triangle(tri.p0, tri.p1, p));
					result.push(new Triangle(tri.p1, tri.p2, p));
					result.push(new Triangle(tri.p2, tri.p0, p));
					break;
				}
			}
		}

		return result;
	}
}
