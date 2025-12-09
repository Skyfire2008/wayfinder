package org.skyfire2008.wayfinder.geom;

class QuadTree {
	private var bounds: IntRect;
	private var maxItems: Int;

	private var halfWidth: Int;
	private var halfHeight: Int;
	private var mid: IntPoint;

	private var items: Array<IntRect>;
	private var children: Array<QuadTree> = [];

	private var canSplit: Bool;

	public function new(bounds: IntRect, maxItems: Int) {
		this.bounds = bounds;
		this.maxItems = maxItems;

		this.items = [];
		this.children = null;

		this.halfWidth = bounds.width >> 1;
		this.halfHeight = bounds.height >> 1;
		this.mid = new IntPoint(bounds.x + halfWidth, bounds.y + halfHeight);

		this.canSplit = bounds.width > 1 && bounds.height > 1;
	}

	/**
	 * Queries only a single point (for int rect origin overlap)
	 * @param point 	point to query
	 * @return IntRect
	 */
	public function pointOccupied(point: IntPoint): Bool {
		if (!bounds.contains(point.x, point.y)) {
			return false;
		}

		for (item in items) {
			if (item.contains(point.x, point.y)) {
				return true;
			}
		}

		if (children != null) {
			for (child in children) {
				if (child.pointOccupied(point)) {
					return true;
				}
			}
		}

		return false;
	}

	public function queryOne(rect: IntRect): IntRect {
		for (item in items) {
			if (item.intersects(rect)) {
				return item;
			}
		}

		if (children != null) {
			var index = getChildIndex(rect);
			if (index > -1) {
				return children[index].queryOne(rect);
			}
		}

		return null;
	}

	public function query(rect: IntRect): Array<IntRect> {
		var result: Array<IntRect> = [];

		for (item in items) {
			if (item.intersects(rect)) {
				result.push(item);
			}
		}

		if (children != null) {
			var index = getChildIndex(rect);
			if (index > -1) {
				result = result.concat(children[index].query(rect));
			}
		}

		return result;
	}

	public function add(item: IntRect) {
		// if already split, find the appropriate child and add
		if (children != null) {
			var index = getChildIndex(item);
			if (index == -1) {
				items.push(item);
			} else {
				children[index].add(item);
			}
		} else {
			items.push(item);
		}

		if (items.length > maxItems && canSplit) {
			canSplit = false;

			this.children = [
				new QuadTree(new IntRect(bounds.x, bounds.y, halfWidth, halfHeight), maxItems),
				new QuadTree(new IntRect(mid.x, bounds.y, bounds.width - halfWidth, halfHeight), maxItems),
				new QuadTree(new IntRect(bounds.x, mid.y, halfWidth, bounds.height - halfHeight), maxItems),
				new QuadTree(new IntRect(mid.x, mid.y, bounds.width - halfWidth, bounds.height - halfHeight), maxItems)
			];

			var newItems: Array<IntRect> = [];
			for (item in items) {
				var index = getChildIndex(item);
				if (index == -1) {
					newItems.push(item);
				} else {
					children[index].add(item);
				}
			}

			items = newItems;
		}
	}

	public function getChildIndex(item: IntRect): Int {
		var result = -1;

		if (item.right <= mid.x) {
			if (item.bottom <= mid.y) {
				// top left
				result = 0;
			} else if (item.y >= mid.y) {
				// bottom left
				result = 2;
			}
		} else if (item.x >= mid.x) {
			if (item.bottom <= mid.y) {
				// top right
				result = 1;
			} else if (item.y >= mid.y) {
				// bottom right
				result = 3;
			}
		}

		return result;
	}
}
