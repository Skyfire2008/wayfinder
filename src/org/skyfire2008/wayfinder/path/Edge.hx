package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;
import org.skyfire2008.wayfinder.geom.IntPoint;

class Edge extends PathNode {
	public var v0(default, null): IntPoint;
	public var v1(default, null): IntPoint;

	public function new(v0: IntPoint, v1: IntPoint, node0: PathNode, node1: PathNode) {
		super();
		this.pos = new IntPoint((v0.x + v1.x) >> 1, (v0.y + v1.y) >> 1);
		this.v0 = v0;
		this.v1 = v1;
		this.neighbours.push(node0);
		this.neighbours.push(node1);
	}
}
