package org.skyfire2008.wayfinder.mapGen;

import org.skyfire2008.wayfinder.util.Util;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.geom.IntPoint;

class Cave implements Generator {
	private var prob: Float;
	private var steps: Int;
	private var killThresh: Int;
	private var spawnThresh: Int;

	/**
	 * Creates a new cave generator
	 * @param prob probability of setting a field as wall
	 * @param steps refinement steps
	 * @param killThresh minimum number of neighboring walls for cell to stay a wall
	 * @param spawnThresh minimum number of neighboring walls to turn cell into a wall
	 */
	public function new(prob: Float, steps: Int, killThresh: Int, spawnThresh: Int) {
		this.prob = prob;
		this.steps = steps;
		this.killThresh = killThresh;
		this.spawnThresh = spawnThresh;
	}

	public function makeMap(width: Int, height: Int) {
		var walls: Array<Array<Bool>> = [];

		for (y in 0...height) {
			var row: Array<Bool> = [];
			for (x in 0...width) {
				row.push(Math.random() <= prob);
			}
			walls.push(row);
		}

		var getWall = (x: Int, y: Int) -> {
			x = Util.min(x, width - 1);
			x = Util.max(x, 0);
			y = Util.min(y, height - 1);
			y = Util.max(y, 0);

			return walls[y][x] ? 1 : 0;
		};

		for (i in 0...steps) {

			var newWalls: Array<Array<Bool>> = [];
			for (y in 0...height) {
				var row: Array<Bool> = [];

				for (x in 0...width) {
					var neighbors: Array<IntPoint> = [
						new IntPoint(x - 1, y - 1),
						new IntPoint(x, y - 1),
						new IntPoint(x + 1, y - 1),
						new IntPoint(x - 1, y),
						new IntPoint(x + 1, y),
						new IntPoint(x - 1, y + 1),
						new IntPoint(x, y + 1),
						new IntPoint(x + 1, y + 1)
					];

					var count: Int = 0;
					for (neighbor in neighbors) {
						count += getWall(neighbor.x, neighbor.y);
					}

					if (count < killThresh) {
						row.push(false);
					} else if (count >= spawnThresh) {
						row.push(true);
					} else {
						row.push(walls[y][x]);
					}
				}

				newWalls.push(row);
			}
			walls = newWalls;
		}

		return new Map(walls, 20, 20);
	}
}
