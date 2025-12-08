package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;
import org.skyfire2008.wayfinder.geom.IntPoint;

class Edge extends PathNode {
	public var p0(default, null): IntPoint;
	public var p1(default, null): IntPoint;

	public function new(p0: IntPoint, p1: IntPoint, node0: PathNode, node1: PathNode) {
		super();
		this.pos = new IntPoint((p0.x + p1.x) >> 1, (p0.y + p1.y) >> 1);
		this.p0 = p0;
		this.p1 = p1;
		this.neighbours.push(node0);
		this.neighbours.push(node1);
	}
}
