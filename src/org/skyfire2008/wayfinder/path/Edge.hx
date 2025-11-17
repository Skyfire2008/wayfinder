package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntPoint;

class Edge {
	public var v0(default, null): IntPoint;
	public var v1(default, null): IntPoint;

	public var neighbourId(default, null): Int;

	public function new(v0: IntPoint, v1: IntPoint, neighbourId: Int) {
		this.v0 = v0;
		this.v1 = v1;
		this.neighbourId = neighbourId;
	}
}
