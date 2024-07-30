package org.skyfire2008.wayfinder.mapGen;

import org.skyfire2008.wayfinder.path.Map;

class Random implements Generator {
	private var prob: Float;

	public function new(prob: Float) {
		this.prob = prob;
	}

	public function makeMap(width: Int, height: Int): Map {
		var walls: Array<Array<Bool>> = [];
		for (y in 0...height) {
			var row: Array<Bool> = [];
			for (x in 0...width) {
				row.push(Math.random() < prob);
			}
			walls.push(row);
		}

		return new Map(walls, 20, 20);
	}
}
