package org.skyfire2008.wayfinder.geom;

typedef IntPointDef = {
	var x: Int;
	var y: Int;
};

class IntPoint {
	public var x: Int;
	public var y: Int;

	public static inline function distance(a: IntPoint, b: IntPoint): Float {
		var dx = a.x - b.x;
		var dy = a.y - b.y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public static function importDef(def: IntPointDef): IntPoint {
		return new IntPoint(def.x, def.y);
	}

	public static function exportDef(p: IntPoint): IntPointDef {
		return {
			x: p.x,
			y: p.y
		};
	}

	public function new(x: Int = 0, y: Int = 0) {
		this.x = x;
		this.y = y;
	}

	public function copy() {
		return new IntPoint(x, y);
	}

	public inline function add(other: IntPoint) {
		x += other.x;
		y += other.y;
	}
}
