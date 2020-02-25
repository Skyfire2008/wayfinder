package org.skyfire2008.wayfinder;

import js.Browser;
import org.skyfire2008.wayfinder.geom.Point;
import org.skyfire2008.wayfinder.geom.Triangle;

class Main {
	public static function main() {
		Browser.window.addEventListener("load", init);
	}

	public static function init() {
		var points: Array<Point> = [];
		for (i in 0...10) {
			points.push(new Point(Math.random() * 800, Math.random() * 600));
		}
		trace(Triangle.triangulate(800, 600, points));
	}
}
