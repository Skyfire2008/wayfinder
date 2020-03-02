package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.Util;

using Lambda;

class Border {
	public var x0: Int;
	public var y0: Int;
	public var x1: Int;
	public var y1: Int;

	public function new(x0: Int, y0: Int, x1: Int, y1: Int) {
		this.x0 = x0;
		this.y0 = y0;
		this.x1 = x1;
		this.y1 = y1;
	}
}

class Node {
	private static var curId = 0;

	public var id(default, null): Int;
	public var region(default, null): Region;
	private var exits: Array<Exit>;

	public function new(region: Region, exits: Array<Exit> = null) {
		this.id = Node.curId++;
		this.region = region;
		this.exits = exits == null ? new Array<Exit>() : exits;
	}

	/**
	 * Creates a new region at given starting coordinates
	 * @param startX left coordinate
	 * @param startY top coordiante
	 * @param regions 2d array of tiles occupied by regions
	 * @param tiles 2d array of walls
	 * @return Region
	 */
	public static function makeRegion(startX: Int, startY: Int, regions: Array<Array<Region>>, tiles: Array<Array<Bool>>): Region {
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
				// if current tile is not wall and not occupied by region
				if (!tiles[y][x] && regions[y][x] == null) {
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

		var result = new Region(startX, startY, maxAreaWidth, maxAreaHeight);
		// occupy the cells in regions array
		for (i in 0...maxAreaWidth) {
			for (j in 0...maxAreaHeight) {
				var x = i + startX;
				var y = j + startY;
				regions[y][x] = result;
			}
		}
		return result;
	}

	public static function makeNodes(walls: Array<Array<Bool>>): Array<Region> {
		var width = walls[0].length;
		var height = walls.length;

		// 2d array, showing where regions are located
		var regions: Array<Array<Region>> = [for (y in 0...height) [for (x in 0...width) null]];
		var y = 0;
		var regionList = new Array<Region>();

		while (y < height) {
			var x = 0;
			while (x < width) {
				// if current tile is empty
				if (!walls[y][x]) {
					var tileRegion = regions[y][x];
					// if current tile not occupied by region
					if (tileRegion == null) {
						var region = Node.makeRegion(x, y, regions, walls);
						// trace('made region $region');
						regionList.push(region);
						x += region.width;
						// otherwise
					} else {
						x += regions[y][x].width;
					}
					// if current tile is a wall
				} else {
					x++;
				}
			}
			y++;
		}

		var ids = regions.map(function(line: Array<Region>) {
			return line.map(function(r: Region) {
				return r != null ? r.id : 0;
			});
		});

		ids.iter(function(item: Array<Int>) {
			trace(item);
		});

		var x = 0;
		var y = 0;
		for (region in regionList) {
			// right
			if (region.right < width) {
				x = region.right;
				y = region.y;
				while (y < region.bottom) {
					if (walls[y][x]) {
						y++;
					} else {
						var other = regions[y][x];
						var y0 = Util.max(region.y, other.y);
						var y1 = Util.min(region.bottom, other.bottom);
						y = y1;
						trace('regions ${region.id} and ${other.id} border at x=${region.right} y=($y0, $y1)');
					}
				}
			}

			// bottom
			if (region.bottom < height) {
				x = region.x;
				y = region.bottom;
				while (x < region.right) {
					if (walls[y][x]) {
						x++;
					} else {
						var other = regions[y][x];
						var x0 = Util.max(region.x, other.x);
						var x1 = Util.min(region.right, other.right);
						x = x1;
						trace('regions ${region.id} and ${other.id} border at x=($x0, $x1) y=${region.bottom}');
					}
				}
			}

			// left
			if (region.x > 0) {
				x = region.x - 1;
				y = region.y;
				while (y < region.bottom) {
					if (walls[y][x]) {
						y++;
					} else {
						var other = regions[y][x];
						var y0 = Util.max(region.y, other.y);
						var y1 = Util.min(region.bottom, other.bottom);
						y = y1;
						trace('regions ${region.id} and ${other.id} border at x=${region.x} y=($y0, $y1)');
					}
				}
			}

			// top
			if (region.y > 0) {
				x = region.x;
				y = region.y - 1;
				while (x < region.right) {
					if (walls[y][x]) {
						x++;
					} else {
						var other = regions[y][x];
						var x0 = Util.max(region.x, other.x);
						var x1 = Util.min(region.right, other.right);
						x = x1;
						trace('regions ${region.id} and ${other.id} border at x=($x0, $x1) y=${region.y}');
					}
				}
			}
		}
		return regionList;
	}
}
