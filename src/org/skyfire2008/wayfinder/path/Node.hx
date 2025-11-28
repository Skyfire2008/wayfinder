package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.geom.IntRect;
import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;

class Node extends PathNode<Node> {
	public var rect(default, null): IntRect;
	public var edges(default, null): Array<Edge>;

	public function new(key: Int, rect: IntRect, edges: Array<Edge>) {
		super();
		// TODO: this should be a normal point instead
		this.pos = new IntPoint(Std.int(rect.x + rect.width / 2), Std.int(rect.y + rect.height / 2));
		this.key = key;
		this.rect = rect;
		this.edges = edges;
	}
}
