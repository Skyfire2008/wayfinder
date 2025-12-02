package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.Pathfinder.PathGraph;
import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;

class GridNode extends PathNode<GridNode> {
	public function new(pos: IntPoint) {
		super();
		this.pos = pos;
	}

	public function setNeighbours(neighbours: Array<GridNode>) {
		this.neighbours = neighbours;
	}
}

class GridGraph implements PathGraph<GridNode> {
	private var grid: Array<Array<GridNode>>;

	public function new(walls: Array<Array<Bool>>) {
		grid = [];

		var y = 0;
		var nodes: Array<GridNode> = [];
		// convert 2d array of walls into 2d array of nodes
		for (row in walls) {
			var nodeRow: Array<GridNode> = [];

			var x = 0;
			for (wall in row) {
				if (wall) {
					nodeRow.push(null);
				} else {
					var node = new GridNode(new IntPoint(x, y));
					nodeRow.push(node);
					nodes.push(node);
				}
				x++;
			}

			y++;
			grid.push(nodeRow);
		}

		// calculate node neighbours
		for (node in nodes) {
			var neighbours: Array<GridNode> = [];

			if (node.pos.x < grid[0].length - 1) {
				var neighbour = grid[node.pos.y][node.pos.x + 1];
				if (neighbour != null) {
					neighbours.push(neighbour);
				}
			}
			if (node.pos.x > 0) {
				var neighbour = grid[node.pos.y][node.pos.x - 1];
				if (neighbour != null) {
					neighbours.push(neighbour);
				}
			}
			if (node.pos.y > 0) {
				var neighbour = grid[node.pos.y - 1][node.pos.x];
				if (neighbour != null) {
					neighbours.push(neighbour);
				}
			}
			if (node.pos.y < grid.length - 1) {
				var neighbour = grid[node.pos.y + 1][node.pos.x];
				if (neighbour != null) {
					neighbours.push(neighbour);
				}
			}

			node.setNeighbours(neighbours);
		}
	}

	public function getNode(pos: IntPoint): GridNode {
		return grid[pos.y][pos.x];
	}

	public function checkVisibility(p0: IntPoint, p1: IntPoint): Bool {
		// this is a special case since points are integer, so no taking care of different positions inside a cell is necessary
		var stepX = p1.x > p0.x ? 1 : -1;
		var stepY = p1.y > p0.y ? 1 : -1;
		var v: IntPoint = new IntPoint(p1.x - p0.x, p1.y - p0.y);

		var tDeltaX = stepX / v.x;
		var tDeltaY = stepY / v.y;

		// distance to next horizontal border in t
		// always 0.5/abs(v.x) cause point is in the center of cell
		var tMaxX: Float;
		if (!Math.isFinite(tDeltaX)) {
			tMaxX = Math.POSITIVE_INFINITY;
		} else {
			tMaxX = 0.5 * tDeltaX;
		}

		// distance to next vertical border in t
		var tMaxY: Float;
		if (!Math.isFinite(tDeltaY)) {
			tMaxY = Math.POSITIVE_INFINITY;
		} else {
			tMaxY = 0.5 * tDeltaY;
		}

		var x = p0.x;
		var y = p0.y;

		while (x != p1.x || y != p1.y) {
			if (isWall(x, y)) {
				return false;
			}

			if (tMaxX < tMaxY) {
				tMaxX += tDeltaX;
				x += stepX;
			} else {
				tMaxY += tDeltaY;
				y += stepY;
			}
		}

		return true;
	}

	public inline function isWall(x: Int, y: Int): Bool {
		return grid[y][x] == null;
	}
}
