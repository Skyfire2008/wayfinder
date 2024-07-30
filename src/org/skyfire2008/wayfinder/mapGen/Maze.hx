package org.skyfire2008.wayfinder.mapGen;

import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.geom.IntPoint;

import polygonal.ds.Prioritizable;
import polygonal.ds.PriorityQueue;

import org.skyfire2008.wayfinder.util.IntIterator;

class Passage implements Prioritizable {
	public var priority(default, null): Float;
	public var position(default, null): Int;

	public var pos(default, null): IntPoint;
	public var next(default, null): IntPoint;

	public function new(pos: IntPoint, next: IntPoint, priority: Float) {
		this.pos = pos;
		this.next = next;
		this.priority = priority;
	}
}

class Maze implements Generator {
	public function new() {}

	public function makeMap(width: Int, height: Int) {

		var walls: Array<Array<Bool>> = [];
		for (y in 0...height) {
			var row: Array<Bool> = [];
			for (x in 0...width) {
				var wall = y % 2 == 1 || x % 2 == 1;
				row.push(wall);
			}
			walls.push(row);
		}

		var added: Array<Array<Bool>> = [];
		for (y in new IntIterator(0, height, 2)) {
			var row: Array<Bool> = [];
			for (x in new IntIterator(0, width, 2)) {
				row.push(false);
			}
			added.push(row);
		}

		var isAdded = (pos: IntPoint) -> {
			return added[pos.y >> 1][pos.x >> 1];
		};
		var add = (pos: IntPoint) -> {
			added[pos.y >> 1][pos.x >> 1] = true;
		};

		// init
		added[0][0] = true;
		var passageQueue = new PriorityQueue<Passage>();
		passageQueue.enqueue(new Passage({x: 1, y: 0}, {x: 2, y: 0}, Math.random()));
		passageQueue.enqueue(new Passage({x: 0, y: 1}, {x: 0, y: 2}, Math.random()));
		while (!passageQueue.isEmpty()) {
			var passage = passageQueue.dequeue();
			if (isAdded(passage.next)) {
				continue;
			}

			add(passage.next);
			walls[passage.pos.y][passage.pos.x] = false;

			var getProb = (pos: IntPoint, isX: Bool) -> {
				return Math.random();
			}

			if (passage.next.x + 2 < width) {
				var next: IntPoint = {x: passage.next.x + 2, y: passage.next.y};
				if (!isAdded(next)) {
					var pos = {x: passage.next.x + 1, y: passage.next.y};
					passageQueue.enqueue(new Passage(pos, next, getProb(pos, true)));
				}
			}

			if (passage.next.y + 2 < height) {
				var next: IntPoint = {x: passage.next.x, y: passage.next.y + 2};
				if (!isAdded(next)) {
					var pos = {x: passage.next.x, y: passage.next.y + 1};
					passageQueue.enqueue(new Passage(pos, next, getProb(pos, false)));
				}
			}

			if (passage.next.x - 2 >= 0) {
				var next: IntPoint = {x: passage.next.x - 2, y: passage.next.y};
				if (!isAdded(next)) {
					var pos = {x: passage.next.x - 1, y: passage.next.y};
					passageQueue.enqueue(new Passage(pos, next, getProb(pos, true)));
				}
			}

			if (passage.next.y - 2 >= 0) {
				var next: IntPoint = {x: passage.next.x, y: passage.next.y - 2};
				if (!isAdded(next)) {
					var pos = {x: passage.next.x, y: passage.next.y - 1};
					passageQueue.enqueue(new Passage(pos, next, getProb(pos, false)));
				}
			}
		}

		return new Map(walls, 20, 20);
	}
}
