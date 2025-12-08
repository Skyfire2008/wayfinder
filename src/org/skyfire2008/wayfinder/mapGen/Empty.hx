package org.skyfire2008.wayfinder.mapGen;

import org.skyfire2008.wayfinder.path.Map;

class Empty implements Generator {
	public function new() {}

	public function makeMap(width: Int, height: Int): Map {
		var walls: Array<Array<Bool>> = [];

		for (y in 0...height) {
			var row: Array<Bool> = [];
			for (x in 0...width) {
				row.push(false);
			}
			walls.push(row);
		}

		return new Map(walls);
	}
}
