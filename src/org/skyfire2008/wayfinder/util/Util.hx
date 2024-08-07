package org.skyfire2008.wayfinder.util;

class Util {
	public static inline function min(a: Int, b: Int): Int {
		return a > b ? b : a;
	}

	public static inline function max(a: Int, b: Int): Int {
		return a > b ? a : b;
	}

	public static inline function abs(a: Int): Int {
		return a > 0 ? a : -a;
	}
}
