package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.geom.IntRect;
import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;

class Node extends PathNode<Node> {
	public var id(default, null): Int;
	public var rect(default, null): IntRect;
	// TODO: edges are redundant with neighbours
	public var edges(default, null): Array<Edge>;

	public function new(id: Int, rect: IntRect, edges: Array<Edge>) {
		super();
		// TODO: this should be a normal point instead
		this.pos = new IntPoint(Std.int(rect.x + rect.width / 2), Std.int(rect.y + rect.height / 2));
		this.id = id;
		this.rect = rect;
		this.edges = edges;

		this.neighbours = [];
	}
}
