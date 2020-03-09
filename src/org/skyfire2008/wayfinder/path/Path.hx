package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.Point;

import de.polygonal.ds.IntHashSet;

class Path {
	public var points: Array<Point>;

	public var exits: Array<Exit>;
	public var regions: IntHashSet;

	public function new() {
		this.points = [];
		this.exits = [];
		this.regions = new IntHashSet(17);
	}
}
