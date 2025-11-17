package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntRect;

class Node {
	public var rect(default, null): IntRect;
	public var edges(default, null): Array<Edge>;

	public function new(rect: IntRect, edges: Array<Edge>) {
		this.rect = rect;
		this.edges = edges;
	}
}
