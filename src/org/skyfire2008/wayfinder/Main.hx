package org.skyfire2008.wayfinder;

import js.Browser;

import org.skyfire2008.wayfinder.geom.Point;

import knockout.Knockout;
import knockout.Observable;

class ViewModel {
	public var width: Int;
	public var height: Int;

	public var tileWidth: Float;
	public var tileHeight: Float;

	public var walls: Array<Array<Observable<Bool>>>;
	public var drawing: Observable<Bool>;

	public function new(width: Int, height: Int, tileWidth: Float, tileHeight: Float) {
		this.width = width;
		this.height = height;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		this.walls = [
			for (y in 0...height) [for (x in 0...width) Knockout.observable(Math.random() > 0.5)]
		];

		this.drawing = Knockout.observable(false);
	}

	public function onMouseDown() {
		drawing.set(true);
	}

	public function onMouseUp() {
		drawing.set(false);
	}
}

class Main {
	public static function main() {
		Browser.window.addEventListener("load", init);
	}

	public static function init() {
		var viewModel = new ViewModel(50, 50, 10, 10);
		Knockout.applyBindings(viewModel);
	}
}
