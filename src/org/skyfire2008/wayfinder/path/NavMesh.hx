package org.skyfire2008.wayfinder.path;

import polygonal.ds.PriorityQueue;

import org.skyfire2008.wayfinder.geom.Point;
import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.geom.Rectangle;
import org.skyfire2008.wayfinder.util.IntIterator.RevIntIterator;
import org.skyfire2008.wayfinder.util.Tuple;
import org.skyfire2008.wayfinder.util.Util;

using Lambda;

typedef Edge = Tuple<Int, Exit>;

class NavMesh {
	public var nodes: Array<Rectangle>;

	public var adjacencies: Array<Array<Edge>>;

	public function new(nodes: Array<Rectangle>) {
		this.nodes = nodes;
		this.adjacencies = [for (i in 0...nodes.length) []];
	}

	public function addEdge(from: Int, to: Int, exit: Exit) {
		adjacencies[from].push(new Edge(to, exit));
		adjacencies[to].push(new Edge(from, exit));
	}

	private static function addEdgePrivate(mesh: NavMesh, from: Int, to: Int, exit: Exit): Bool {
		var result = to > from;
		if (result) {
			mesh.addEdge(from, to, exit);
		}
		return result;
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

		// TODO: region 2d array should only contain indices of regions in region array
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

	public static function makeNavMeshImproved(walls: Array<Array<Bool>>, tileWidth: Float, tileHeight: Float): NavMesh {
		var width = walls[0].length;
		var height = walls.length;

		// init heights array
		var heights: Array<Array<Int>> = [];
		for (y in 0...height) {
			var curArray: Array<Int> = [];
			for (x in 0...width) {
				curArray.push(0);
			}
			heights.push(curArray);
		}

		// calculate heights
		for (x in 0...width) {
			for (y in new RevIntIterator(height - 1, 0, -1)) {
				if (walls[y][x]) {
					heights[y][x] = 0;
				} else {
					if (y == height - 1) {
						heights[y][x] = 1;
					} else {
						heights[y][x] = heights[y + 1][x] + 1;
					}
				}
			}
		}

		// calculate next smaller elements
		var nse = heights.map((row) -> Util.getNse(row));

		// use distances to calculate max rectangles for every tile, while using it as origin
		var maxRegions: Array<Array<Region>> = [];
		var queue = new PriorityQueue<Region>();
		for (y in 0...height) {
			var currentRow: Array<Region> = [];
			maxRegions.push(currentRow);

			for (x in 0...width) {
				var isWall = walls[y][x];
				if (!isWall) {

					var bestWidth = 0;
					var bestHeight = 0;
					var bestArea = 0;

					// iterate through next smaller elements to find rectangle with largest area originating in this point
					var i = x;
					while (i != width) {
						var curWidth = nse[y][i] - x;
						var curHeight = heights[y][i];
						var curArea = curWidth * curHeight;

						if (curArea > bestArea) {
							bestWidth = curWidth;
							bestHeight = curHeight;
							bestArea = curArea;
						}

						i = nse[y][i];
					}

					// add region to array and queue
					var region = new Region(x, y, bestWidth, bestHeight);
					currentRow.push(region);
					queue.enqueue(region);
				} else {
					currentRow.push(null);
				}
			}
		}

		// TODO: implement quadtree to manage added regions
		var addedRegions: Array<Region> = [];
		// fetch regions from priority queue
		while (!queue.empty()) {
			var region = queue.dequeue();

			var skip = false;
			var requeue = false;
			for (current in addedRegions) {
				// if region's origin is already covered, skip
				if (current.contains(region.x, region.y)) {
					skip = true;
					break;
				}

				// if it only intersects, recalculate the region
				if (current.intersects(region)) {
					requeue = true;

					var newWidth = current.x - region.x;
					var newHeight = current.y - region.y;
					if (newWidth * region.height > newHeight * region.width) {
						region.setWidth(newWidth);
					} else {
						region.setHeight(newHeight);
					}
				}
			}

			if (skip) {
				continue;
			}

			if (requeue) {
				queue.enqueue(region);
				continue;
			}

			addedRegions.push(region);
		}

		var result = new NavMesh(addedRegions.map(function(elem: Region) {
			return elem.toRect(tileWidth, tileHeight);
		}));

		return result;
	}

	public static function makeNavMesh(walls: Array<Array<Bool>>, tileWidth: Float, tileHeight: Float): NavMesh {
		var width = walls[0].length;
		var height = walls.length;

		var result: NavMesh = null;

		// 2d array, showing where regions are located
		var regions: Array<Array<Region>> = [for (y in 0...height) [for (x in 0...width) null]];
		var y = 0;
		var regionList = new Array<Region>();

		// generate the regions
		while (y < height) {
			var x = 0;
			while (x < width) {
				// if current tile is empty
				if (!walls[y][x]) {
					var tileRegion = regions[y][x];
					// if current tile not occupied by region
					if (tileRegion == null) {
						var region = NavMesh.makeRegion(x, y, regions, walls);
						// trace('made region $region');
						regionList.push(region);
						region.setId(regionList.length - 1);
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

		result = new NavMesh(regionList.map(function(elem: Region) {
			return elem.toRect(tileWidth, tileHeight);
		}));

		// now get the region exits
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
						NavMesh.addEdgePrivate(result, region.id, other.id, new Exit(new Point(x, y0), new Point(x, y1)));
						// trace('regions ${region.id} and ${other.id} border at x=${region.right} y=($y0, $y1)');
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
						NavMesh.addEdgePrivate(result, region.id, other.id, new Exit(new Point(x0, y), new Point(x1, y)));
						// trace('regions ${region.id} and ${other.id} border at x=($x0, $x1) y=${region.bottom}');
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
						NavMesh.addEdgePrivate(result, region.id, other.id, new Exit(new Point(x, y0), new Point(x, y1)));
						// trace('regions ${region.id} and ${other.id} border at x=${region.x} y=($y0, $y1)');
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
						NavMesh.addEdgePrivate(result, region.id, other.id, new Exit(new Point(x0, y), new Point(x1, y)));
						// trace('regions ${region.id} and ${other.id} border at x=($x0, $x1) y=${region.y}');
					}
				}
			}
		}

		return result;
	}
}
