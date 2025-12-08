package org.skyfire2008.wayfinder.test;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.geom.IntRect;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.AStar;
import org.skyfire2008.wayfinder.path.Map;

// TODO: replace
class Main {
	public static function main(): Void {
		var width = 8;
		var height = 7;
		var walls = [
			0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 1, 0, 0, 1, 1,
			0, 0, 1, 1, 1, 0, 0, 0,
			0, 0, 0, 1, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0,
			1, 0, 1, 0, 0, 0, 0, 0,
			0, 0, 1, 0, 0, 0, 0, 0
		];

		var tiles = new Array<Array<Bool>>();
		for (y in 0...height) {
			var current = new Array<Bool>();
			for (x in 0...width) {
				var i = x + y * width;
				current.push(walls[i] == 1);
			}
			tiles.push(current);
		}

		var map = new Map(tiles);

		var regions: Array<Array<IntRect>> = [for (y in 0...height) [for (x in 0...width) null]];

		// trace(NavMesh.makeRegion(0, 0, regions, tiles));
		// trace(NavMesh.makeRegion(5, 2, regions, tiles));
		// trace(NavMesh.makeRegion(2, 4, regions, tiles));

		// trace(NavMesh.makeNavMesh(tiles, 10, 10));

		/* var path1 = Path.findAStar(map, new IntPoint(0, 6), new IntPoint(7, 0));
			 var path2 = Path.findAStar(map, new IntPoint(1, 2), new IntPoint(5, 2));

			trace(path1);
			trace(path2); */
	}
}
