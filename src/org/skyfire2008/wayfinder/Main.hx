package org.skyfire2008.wayfinder;

import js.Browser;

import org.skyfire2008.wayfinder.path.NavMesh;

import knockout.Knockout;
import knockout.Observable;

using Lambda;

class ViewModel {
	public var width: Int;
	public var height: Int;

	public var tileWidth: Float;
	public var tileHeight: Float;

	public var walls: Array<Array<Observable<Bool>>>;
	public var drawing: Observable<Bool>;
	public var removing: Observable<Bool>;

	public var navMesh: Observable<NavMesh>;

	public function new(width: Int, height: Int, tileWidth: Float, tileHeight: Float) {
		this.width = width;
		this.height = height;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		this.walls = [
			for (y in 0...height) [
				for (x in 0...width)
					Knockout.observable(Math.random() > x * y / (width * height))
			]
		];

		this.drawing = Knockout.observable(false);
		this.removing = Knockout.observable(false);

		this.navMesh = Knockout.observable(null);
	}

	public function genNavMesh() {
		var walls = this.walls.map(function(line) {
			return line.map(function(elem) {
				return elem.get();
			});
		});
		this.navMesh.set(NavMesh.makeNavMesh(walls, this.tileWidth, this.tileHeight));
	}
}

class Main {
	public static function main() {
		Browser.window.addEventListener("load", init);
	}

	public static function init() {
		var viewModel = new ViewModel(15, 15, 10, 10);
		Knockout.applyBindings(viewModel);
	}
}
