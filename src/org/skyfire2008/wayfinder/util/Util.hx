package org.skyfire2008.wayfinder.util;

import org.skyfire2008.wayfinder.util.IntIterator.RevIntIterator;

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

	/**
	 * Returns an array of next smaller elements(index of first following element that's smaller than current one)
	 * @param values 		values to process
	 * @return Array<Int>
	 */
	public static inline function getNse(values: Array<Int>): Array<Int> {
		var stack: Array<Int> = [];
		var result: Array<Int> = [];
		stack.push(values.length);

		// process the array in reverse direction
		for (i in new RevIntIterator(values.length - 1, 0, -1)) {

			// while stack elements bigger than current, pop them
			while (stack[0] != values.length && values[i] <= values[stack[0]]) {
				stack.shift();
			}

			result.unshift(stack[0]);
			stack.unshift(i);
		}

		return result;
	}

}
