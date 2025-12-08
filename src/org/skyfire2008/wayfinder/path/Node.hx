package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.geom.IntRect;
import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;

class Node extends PathNode {
	public var id(default, null): Int;
	public var rect(default, null): IntRect;

	public function new(id: Int, rect: IntRect) {
		super();
		this.pos = new IntPoint(Std.int(rect.x + rect.width / 2), Std.int(rect.y + rect.height / 2));
		this.id = id;
		this.rect = rect;
	}
}
