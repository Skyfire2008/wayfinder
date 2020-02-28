package org.skyfire2008.wayfinder.test;

import org.skyfire2008.wayfinder.path.Region;
import org.skyfire2008.wayfinder.path.Node;

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

		var regions: Array<Array<Region>> = [for (y in 0...height) [for (x in 0...width) null]];

		trace(Node.makeRegion(0, 0, regions, tiles));
		trace(Node.makeRegion(5, 2, regions, tiles));
		trace(Node.makeRegion(2, 4, regions, tiles));

		trace(Node.makeNodes(tiles));
	}
}
