package org.skyfire2008.wayfinder.path;

class Border {
	public var x: Int;
	public var y: Int;
	public var length: Int;

	public function new(x: Int, y: Int, length: Int) {
		this.x = x;
		this.y = y;
		this.length = length;
	}
}

class Check {
	public var horizontal: Border = null;
	public var vertical: Border = null;

	public function new() {}
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

	public static function makeNodes(tiles: Array<Array<Bool>>): Array<Region> {
		var width = tiles[0].length;
		var height = tiles.length;

		// 2d array, showing where regions are located
		var regions: Array<Array<Region>> = [for (y in 0...height) [for (x in 0...width) null]];
		var y = 0;
		var regionList = new Array<Region>();

		while (y < height) {
			var x = 0;
			while (x < width) {
				// if current tile is empty
				if (!tiles[y][x]) {
					var tileRegion = regions[y][x];
					// if current tile not occupied by region
					if (tileRegion == null) {
						var region = Node.makeRegion(x, y, regions, tiles);
						trace('made region $region');
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

		var checks = [for (y in 0...height) [for (x in 0...width) new Check()]];
		var x = 0;
		var y = 0;
		for (region in regionList) {
			// right
			x = region.right;
			y = region.y;
			while (y < region.bottom + 1) {
				var check = checks[y][x];
				if (check.horizontal == null) {} else {
					y += check.horizontal.length;
				}
				y++;
			}

			// bottom

			// left

			// top
		}
		return regionList;
	}
}
