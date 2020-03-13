package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.Point;

import de.polygonal.ds.IntHashSet;
import de.polygonal.ds.Prioritizable;

class Path {
	public var points: Array<Point>;

	public static function findPath(a: Point, b: Point): Path {}

	public function new() {
		this.points = [];
	}
}

class WipPath extends Path implements Prioritizable {
	public var exits: Array<Exit>;
	public var regions: IntHashSet;

	public var priority(default, null): Float;
	public var position(default, null): Int;

	public function new() {
		super();
		this.exits = [];
		this.regions = new IntHashSet(17);
	}
}
