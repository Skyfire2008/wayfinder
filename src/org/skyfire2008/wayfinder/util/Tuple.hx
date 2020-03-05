package org.skyfire2008.wayfinder.util;

class Tuple<A, B> {
	public var a: A;
	public var b: B;

	public function new(a: A, b: B) {
		this.a = a;
		this.b = b;
	}

	public function swap(): Tuple<B, A> {
		return new Tuple<B, A>(b, a);
	}
}
