package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.Pathfinder.PathGraph;
import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;

class GridNode extends PathNode<GridNode> {
	private static var nodeKey = 0;

	public function new(pos: IntPoint) {
		super();
		this.key = nodeKey++;
		this.pos = pos;
	}
}

class GridGraph implements PathGraph<GridNode> {
	private var grid: Array<Array<GridNode>>;

	public function new(walls: Array<Array<Bool>>) {
		grid = [];

		var y = 0;
		for (row in walls) {
			var nodeRow: Array<GridNode> = [];

			var x = 0;
			for (wall in row) {
				if (wall) {
					nodeRow.push(null);
				} else {
					nodeRow.push(new GridNode(new IntPoint(x, y)));
				}
				x++;
			}

			y++;
			grid.push(nodeRow);
		}
	}

	public function getNode(pos: IntPoint): GridNode {
		return grid[pos.y][pos.x];
	}

	public function getNeighbours(node: GridNode): Array<GridNode> {
		var result: Array<GridNode> = [];

		// TODO: probably need to store it in the node itself
		if (node.pos.x < grid[0].length - 1) {
			var neighbour = grid[node.pos.y][node.pos.x + 1];
			if (neighbour != null) {
				result.push(neighbour);
			}
		}
		if (node.pos.x > 0) {
			var neighbour = grid[node.pos.y][node.pos.x - 1];
			if (neighbour != null) {
				result.push(neighbour);
			}
		}
		if (node.pos.y > 0) {
			var neighbour = grid[node.pos.y - 1][node.pos.x];
			if (neighbour != null) {
				result.push(neighbour);
			}
		}
		if (node.pos.y < grid.length - 1) {
			var neighbour = grid[node.pos.y + 1][node.pos.x];
			if (neighbour != null) {
				result.push(neighbour);
			}
		}

		return result;
	}
}
