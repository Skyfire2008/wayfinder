package org.skyfire2008.wayfinder.util;

class IntIterator {
	private var min: Int;
	private var max: Int;
	private var step: Int;

	private var current: Int;

	public function new(min: Int, max: Int, step: Int) {
		this.min = min;
		this.max = max;
		this.step = step;
		current = min;
	}

	public inline function hasNext(): Bool {
		return current < max;
	}

	public inline function next(): Int {
		var result = current;
		current += step;
		return result;
	}
}
