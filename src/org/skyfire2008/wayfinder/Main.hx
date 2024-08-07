package org.skyfire2008.wayfinder;

import js.html.InputElement;
import js.html.Event;

import org.skyfire2008.wayfinder.mapGen.Random;

import js.html.MouseEvent;
import js.Browser;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.path.Path;
import org.skyfire2008.wayfinder.mapGen.Generator;
import org.skyfire2008.wayfinder.mapGen.Cave;
import org.skyfire2008.wayfinder.mapGen.Maze;

import knockout.Knockout;
import knockout.Observable;

using Lambda;

typedef GenInfo = {
	var name: String;
	var gen: Generator;
};

class ViewModel {
	public var tempWidth: Observable<Int>;
	public var tempHeight: Observable<Int>;
	public var height: Observable<Int>;
	public var width: Observable<Int>;

	public var tileWidth: Float;
	public var tileHeight: Float;

	public var walls: Observable<Array<Array<Observable<Bool>>>>;
	public var removing: Observable<Bool>;
	public var settingStart: Observable<Bool>;
	public var settingEnd: Observable<Bool>;
	public var startPos: Observable<IntPoint>;
	public var endPos: Observable<IntPoint>;

	public var navMesh: Observable<NavMesh>;
	public var path: Observable<Array<IntPoint>>;
	public var message: Observable<String>;

	public var generators: Array<GenInfo> = [
		{name: "Random", gen: new Random(0.4)},
		{name: "Cave", gen: new Cave(0.5, 3, 4, 5)},
		{name: "Maze", gen: new Maze()}
	];
	public var generator: Observable<GenInfo>;
	private var map: Map;

	private var drawing = false;
	private var mapChanged = false;

	public function new(width: Int, height: Int, tileWidth: Float, tileHeight: Float) {
		this.tempWidth = Knockout.observable(width);
		this.tempHeight = Knockout.observable(height);
		this.width = Knockout.observable(width);
		this.height = Knockout.observable(height);
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		this.removing = Knockout.observable(false);
		this.settingStart = Knockout.observable(false);
		this.settingEnd = Knockout.observable(false);
		this.startPos = Knockout.observable(null);
		this.endPos = Knockout.observable(null);

		this.navMesh = Knockout.observable(null);
		this.path = Knockout.observable([]);
		this.message = Knockout.observable(null);

		this.generator = Knockout.observable(generators[0]);
		this.walls = Knockout.observable();
		generateMap();
	}

	public function stopDrawing() {
		drawing = false;
	}

	public function onTileMouseDown(x: Int, y: Int, e: MouseEvent) {
		var isWall = walls.get()[y][x];

		if (settingStart.get()) {
			startPos.set({x: x, y: y});
			settingStart.set(false);

		} else if (settingEnd.get()) {
			endPos.set({x: x, y: y});
			settingEnd.set(false);

		} else {
			drawing = true;
			removing.set(isWall.get());
			if (removing.get() == isWall.get()) {
				isWall.set(!isWall.get());
			}
		}
	}

	public function onTileMouseEnter(x: Int, y: Int, e: MouseEvent) {
		var isWall = walls.get()[y][x];
		if (drawing && isWall.get() == removing.get()) {
			isWall.set(!isWall.get());
		}
	}

	public function genNavMesh() {
		var walls = this.walls.get().map(function(line) {
			return line.map(function(elem) {
				return elem.get();
			});
		});
		this.navMesh.set(NavMesh.makeNavMesh(walls, this.tileWidth, this.tileHeight));
	}

	public function generateMap() {
		var width = this.tempWidth.get();
		var height = this.tempHeight.get();

		this.map = generator.get().gen.makeMap(width, height);
		var newWalls = [
			for (y in 0...height) [
				for (x in 0...width)
					Knockout.observable(map.walls[y][x])
			]
		];
		this.walls.set(newWalls);
		this.width.set(width);
		this.height.set(height);

		// reset state
		this.message.set(null);
		this.navMesh.set(null);
		this.path.set(null);
		this.startPos.set(null);
		this.endPos.set(null);
	}

	public function setStart() {
		settingStart.set(true);
		settingEnd.set(false);
	}

	public function setEnd() {
		settingStart.set(false);
		settingEnd.set(true);
	}

	public function findPath() {
		var boolWalls: Array<Array<Bool>> = [];
		for (wall in walls.get()) {
			boolWalls.push(wall.map((e) -> e.get()));
		}

		var map = new Map(boolWalls, tileWidth, tileHeight);
		try {
			var temp = Path.findThetaStar(map, startPos.get(), endPos.get());
			path.set(temp.points);
		} catch (e) {
			message.set(e.message);
		}
	}
}

class Main {
	public static function main() {
		Browser.window.addEventListener("load", init);
	}

	public static function init() {
		var viewModel = new ViewModel(59, 59, 20, 20);
		Knockout.applyBindings(viewModel);
	}
}
