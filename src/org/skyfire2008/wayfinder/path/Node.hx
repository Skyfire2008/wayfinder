package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.Point;
import org.skyfire2008.wayfinder.geom.Quad;

class Exit {
	public var a(default, null): Point;
	public var b(default, null): Point;
}

class Node {
	public var quad(default, null): Quad;
	private var exits: Array<Exit>;

	public static function makeQuad(startX: Int, startY: Int, quads: Array<Array<Quad>>, tiles: Array<Array<Bool>>): Quad {
		var maxArea = 0;
		var maxAreaWidth = 0;
		var maxAreaHeight = 0;
		var maxWidth = tiles[0].length - startX;

		var j = 0;
		var curHeight = 1;
		var completed = false;
		// process line-by-line while not completed
		while (!completed && j + startY < tiles.length) {
			var currentArea = 0;

			// for every line, process max possible width
			for (i in 0...maxWidth) {
				var x = i + startX;
				var y = j + startY;
				// if current tile is not wall and not occupied by quad
				if (!tiles[y][x] && quads[y][x] == null) {
					// increment current area by current height
					currentArea += curHeight;
					// if current area greater than maximum area, update maximum area and its location
					if (currentArea > maxArea) {
						maxArea = currentArea;
						maxAreaWidth = i + 1;
						maxAreaHeight = curHeight;
					}
					// if current tile is wall or occupied
				} else {
					// decrease max width
					maxWidth = i;
					if (maxWidth == 0) {
						completed = true;
					}
					break;
				}
			}
			j++;
			curHeight++;
		}

		var result = new Quad(startX, startY, maxAreaWidth, maxAreaHeight);
		// occupy the cells in quads array
		for (i in 0...maxAreaWidth) {
			for (j in 0...maxAreaHeight) {
				var x = i + startX;
				var y = j + startY;
				quads[y][x] = result;
			}
		}
		return result;
	}

	public static function makeNodes(tiles: Array<Array<Bool>>): Array<Quad> {
		var width = tiles[0].length;
		var height = tiles.length;

		// 2d array, showing where quads are located
		var quads: Array<Array<Quad>> = [for (y in 0...height) [for (x in 0...width) null]];
		var y = 0;
		var result = new Array<Quad>();

		while (y < height) {
			var x = 0;
			while (x < width) {
				// if current tile is empty
				if (!tiles[y][x]) {
					var tileQuad = quads[y][x];
					// if current tile not occupied by quad
					if (tileQuad == null) {
						var quad = Node.makeQuad(x, y, quads, tiles);
						trace('made quad $quad');
						result.push(quad);
						x += quad.width;
						// otherwise
					} else {
						x += quads[y][x].width;
					}
					// if current tile is a wall
				} else {
					x++;
				}
			}
			y++;
		}

		return result;
	}

	public function new(quad: Quad, exits: Array<Exit> = null) {
		this.quad = quad;
		this.exits = exits == null ? new Array<Exit>() : exits;
	}
}
