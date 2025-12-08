package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;

import js.lib.Set;

import polygonal.ds.PriorityQueue;

import org.skyfire2008.wayfinder.path.Pathfinder.PathGraph;
import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.geom.IntRect;
import org.skyfire2008.wayfinder.util.IntIterator.RevIntIterator;
import org.skyfire2008.wayfinder.util.Util;

using Lambda;

typedef EdgeDef = {
	var p0: IntPointDef;
	var p1: IntPointDef;
	var node0: Int;
	var node1: Int;
};

typedef NodeDef = {
	var x: Int;
	var y: Int;
	var width: Int;
	var height: Int;
};

typedef NavMeshDef = {
	var nodes: Array<NodeDef>;
	var edges: Array<EdgeDef>;
};

class NavMesh implements PathGraph {
	private var nodes: Array<Node>;

	private var nodeGrid: Array<Array<Int>>;

	public function new(nodes: Array<Node>, nodeGrid: Array<Array<Int>>) {
		this.nodes = nodes;
		this.nodeGrid = nodeGrid;
	}

	public static function importDef(def: NavMeshDef, width: Int, height: Int): NavMesh {
		var nodes: Array<Node> = [];

		var nodeGrid: Array<Array<Int>> = [];

		// init nodeGrid
		for (y in 0...height) {
			var row: Array<Int> = [];
			for (x in 0...width) {
				row.push(-1);
			}
			nodeGrid.push(row);
		}

		var nodeId = 0;
		for (nodeDef in def.nodes) {
			var current = new Node(nodeId, new IntRect(nodeDef.x, nodeDef.y, nodeDef.width, nodeDef.height));
			nodes.push(current);

			for (y in nodeDef.y...(nodeDef.y + nodeDef.height)) {
				for (x in nodeDef.x...(nodeDef.x + nodeDef.width)) {
					nodeGrid[y][x] = nodeId;
				}
			}

			nodeId++;
		}

		for (edgeDef in def.edges) {
			var node0 = nodes[edgeDef.node0];
			var node1 = nodes[edgeDef.node1];
			var edge = new Edge(IntPoint.importDef(edgeDef.p0), IntPoint.importDef(edgeDef.p1), node0, node1);
			node0.neighbours.push(edge);
			node1.neighbours.push(edge);
		}

		return new NavMesh(nodes, nodeGrid);
	}

	public static function exportDef(navmesh: NavMesh): NavMeshDef {
		var nodes: Array<NodeDef> = [];
		var edges: Array<EdgeDef> = [];
		var edgeSet = new Set<PathNode>();

		for (node in navmesh.nodes) {
			nodes.push({
				x: node.rect.x,
				y: node.rect.y,
				width: node.rect.width,
				height: node.rect.height,
			});

			for (neighbour in node.neighbours) {
				// FIXME: do not use casting!
				var edge = cast(neighbour, Edge);

				if (!edgeSet.has(neighbour)) {
					edgeSet.add(neighbour);
					edges.push({
						p0: IntPoint.exportDef(edge.p0),
						p1: IntPoint.exportDef(edge.p1),
						node0: cast(edge.neighbours[0], Node).id,
						node1: cast(edge.neighbours[1], Node).id,
					});
				}
			}
		}

		return {
			nodes: nodes,
			edges: edges
		};

		return null;
	}

	/**
	 * Creates a new navmesh from a wall array
	 * @param walls 		wall array
	 * @param useGlobal 	if enabled, will use a different algorithm for rectangle decomposition
	 */
	public static function makeNavMesh(walls: Array<Array<Bool>>, useGlobal: Bool = false) {
		var width = walls[0].length;
		var height = walls.length;

		// perform the rectangle decomposition and get nodes
		var rects = useGlobal ? NavMesh.wallsToRectsGlobal(walls) : NavMesh.wallsToRects(walls);

		var nodes = [];
		var nodeGrid = [for (y in 0...height) [for (x in 0...width) -1]];
		for (rect in rects) {
			var node = new Node(nodes.length, rect);
			for (x in rect.x...rect.right) {
				for (y in rect.y...rect.bottom) {
					nodeGrid[y][x] = nodes.length;
				}
			}
			nodes.push(node);
		}

		// now get the edges between nodes
		var x = 0;
		var y = 0;
		for (node in nodes) {
			// right
			if (node.rect.right < width) {
				x = node.rect.right;
				y = node.rect.y;
				while (y < node.rect.bottom) {
					if (walls[y][x]) {
						y++;
					} else {
						var other = nodes[nodeGrid[y][x]];
						var y0 = Util.max(node.rect.y, other.rect.y);
						var y1 = Util.min(node.rect.bottom, other.rect.bottom);
						y = y1;

						var p0 = new IntPoint(x, y0);
						var p1 = new IntPoint(x, y1);
						var edge = new Edge(p0, p1, node, other);
						node.neighbours.push(edge);
						other.neighbours.push(edge);
					}
				}
			}

			// bottom
			if (node.rect.bottom < height) {
				x = node.rect.x;
				y = node.rect.bottom;
				while (x < node.rect.right) {
					if (walls[y][x]) {
						x++;
					} else {
						var other = nodes[nodeGrid[y][x]];
						var x0 = Util.max(node.rect.x, other.rect.x);
						var x1 = Util.min(node.rect.right, other.rect.right);
						x = x1;

						var p0 = new IntPoint(x0, y);
						var p1 = new IntPoint(x1, y);
						var edge = new Edge(p0, p1, node, other);
						node.neighbours.push(edge);
						other.neighbours.push(edge);
					}
				}
			}
		}

		return new NavMesh(nodes, nodeGrid);
	}

	public function getNode(pos: IntPoint): Node {
		return getNodeRaw(pos.x, pos.y);
	}

	private inline function getNodeRaw(x: Int, y: Int): Node {
		var result: Node = null;

		if (x >= 0 && x < this.nodeGrid[0].length && y >= 0 && y < this.nodeGrid.length) {
			var nodeId = nodeGrid[y][x];

			if (nodeId >= 0) {
				result = nodes[nodeId];
			}
		}

		return result;
	}

	public function checkVisibility(p0: IntPoint, p1: IntPoint): Bool {

		#if debug
		var nodeSet = new Set<Node>();
		var points: Array<Point> = [];
		#end

		var stepX = p1.x >= p0.x ? 1 : -1;
		var stepY = p1.y >= p0.y ? 1 : -1;
		var v: IntPoint = new IntPoint(p1.x - p0.x, p1.y - p0.y);

		var x = p0.x + 0.5;
		var y = p0.y + 0.5;
		var node = getNode(p0);

		var endNode = getNode(p1);

		while (node != endNode) {

			#if debug
			if (nodeSet.has(node)) {
				trace(nodeSet);
				trace(points);
				throw "A node has been visited more than once!";
			} else {
				nodeSet.add(node);
				points.push(new Point(x, y));
			}
			#end

			// get distance to rectangle's border in movement direction
			var xDist = stepX > 0 ? node.rect.right - x : node.rect.x - x;
			var yDist = stepY > 0 ? node.rect.bottom - y : node.rect.y - y;

			// calculate "time" that it would take to move this distance
			var tX = xDist / v.x;
			var tY = yDist / v.y;

			// choose movement with lowest time
			if (tX < tY) {
				x += xDist;
				y += v.y * tX;

				var indX = Std.int(x) + (stepX > 0 ? 0 : -1);
				var indY = Math.floor(y);

				// dirty hack
				if (y == indY) {
					indY += stepY;
				}

				node = getNodeRaw(indX, indY);

			} else {
				x += v.x * tY;
				y += yDist;

				var indX = Math.floor(x);
				var indY = Std.int(y) + (stepY > 0 ? 0 : -1);

				// dirty hack
				if (x == indX) {
					indX += stepX;
				}

				node = getNodeRaw(indX, indY);
			}

			// if node is null, this is a wall
			if (node == null) {
				return false;
			}
		}

		return true;
	}

	/**
	 * Decomposes the level into rectangles using a greedy algorithm selecting the best global rectangle first
	 * @param walls 		2d array fo walls
	 * @return Array<IntRect>
	 */
	public static function wallsToRectsGlobal(walls: Array<Array<Bool>>): Array<IntRect> {
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
		var maxRects: Array<Array<IntRect>> = [];
		var queue = new PriorityQueue<IntRect>();
		for (y in 0...height) {
			var currentRow: Array<IntRect> = [];
			maxRects.push(currentRow);

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

					// add rect to array and queue
					var rect = new IntRect(x, y, bestWidth, bestHeight);
					currentRow.push(rect);
					queue.enqueue(rect);
				} else {
					currentRow.push(null);
				}
			}
		}

		// TODO: implement quadtree to manage added rects
		var addedRects: Array<IntRect> = [];
		// fetch rects from priority queue
		while (!queue.empty()) {
			var rect = queue.dequeue();

			var skip = false;
			var requeue = false;
			for (current in addedRects) {
				// if rect's origin is already covered, skip
				if (current.contains(rect.x, rect.y)) {
					skip = true;
					break;
				}

				// if it only intersects, recalculate the rect
				if (current.intersects(rect)) {
					requeue = true;

					var newWidth = current.x - rect.x;
					var newHeight = current.y - rect.y;
					if (newWidth * rect.height > newHeight * rect.width) {
						rect.setWidth(newWidth);
					} else {
						rect.setHeight(newHeight);
					}
				}
			}

			if (skip) {
				continue;
			}

			if (requeue) {
				queue.enqueue(rect);
				continue;
			}

			addedRects.push(rect);
		}

		return addedRects;
	}

	/**
	 * Helper function, creates a largest possible rectangle at given coordinates
	 * @param startX left coordinate
	 * @param startY top coordiante
	 * @param rects  2d array of tiles occupied by rectangles
	 * @param tiles 2d array of walls
	 * @return IntRect
	 */
	private static function makeRect(startX: Int, startY: Int, rects: Array<Array<IntRect>>, tiles: Array<Array<Bool>>): IntRect {
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
				// if current tile is not wall and not occupied by a rectangle
				if (!tiles[y][x] && rects[y][x] == null) {
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

		var result = new IntRect(startX, startY, maxAreaWidth, maxAreaHeight);
		// occupy the cells in rects array
		for (i in 0...maxAreaWidth) {
			for (j in 0...maxAreaHeight) {
				var x = i + startX;
				var y = j + startY;
				rects[y][x] = result;
			}
		}
		return result;
	}

	/**
	 * Decomposes the level into rectangles by processing the tiles left->right and top->bottom and occupying largest possible rectangle 
	 * @param walls 		2d array fo walls
	 * @return Array<IntRect>
	 */
	public static function wallsToRects(walls: Array<Array<Bool>>): Array<IntRect> {
		var width = walls[0].length;
		var height = walls.length;

		// 2d array, showing where rects are located
		var rects: Array<Array<IntRect>> = [for (y in 0...height) [for (x in 0...width) null]];
		var y = 0;
		var rectList = new Array<IntRect>();

		// generate the rectangles
		while (y < height) {
			var x = 0;
			while (x < width) {
				// if current tile is empty
				if (!walls[y][x]) {
					var tileRect = rects[y][x];
					// if current tile not occupied by rect
					if (tileRect == null) {
						var rect = NavMesh.makeRect(x, y, rects, walls);
						rectList.push(rect);
						x += rect.width;
						// otherwise
					} else {
						x += rects[y][x].width;
					}
					// if current tile is a wall
				} else {
					x++;
				}
			}
			y++;
		}

		return rectList;
	}

}
