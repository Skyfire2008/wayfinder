package org.skyfire2008.wayfinder;

import js.html.MouseEvent;
import js.Browser;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.path.Path;
import org.skyfire2008.wayfinder.mapGen.Cave;
import org.skyfire2008.wayfinder.mapGen.Maze;

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
	public var settingStart: Observable<Bool>;
	public var settingEnd: Observable<Bool>;
	public var startPos: Observable<IntPoint>;
	public var endPos: Observable<IntPoint>;

	public var navMesh: Observable<NavMesh>;
	public var path: Observable<Array<IntPoint>>;
	public var message: Observable<String>;

	private var mapChanged = false;
	private var map: Map;

	public function new(width: Int, height: Int, tileWidth: Float, tileHeight: Float) {
		this.width = width;
		this.height = height;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		var cave = new Maze();
		var map = cave.makeMap(width, height);

		this.walls = [
			for (y in 0...height) [
				for (x in 0...width)
					Knockout.observable(map.walls[y][x])
			]
		];

		this.drawing = Knockout.observable(false);
		this.removing = Knockout.observable(false);
		this.settingStart = Knockout.observable(false);
		this.settingEnd = Knockout.observable(false);
		this.startPos = Knockout.observable(null);
		this.endPos = Knockout.observable(null);

		this.navMesh = Knockout.observable(null);
		this.path = Knockout.observable([]);
		this.message = Knockout.observable(null);
	}

	public function onTileMouseDown(x: Int, y: Int, e: MouseEvent) {
		var isWall = walls[y][x];

		if (settingStart.get()) {
			startPos.set({x: x, y: y});
			settingStart.set(false);

		} else if (settingEnd.get()) {
			endPos.set({x: x, y: y});
			settingEnd.set(false);

		} else {
			drawing.set(true);
			removing.set(isWall.get());
			if (removing.get() == isWall.get()) {
				isWall.set(!isWall.get());
			}
		}
	}

	public function onTileMouseEnter(x: Int, y: Int, e: MouseEvent) {
		var isWall = walls[y][x];
		if (drawing.get() && isWall.get() == removing.get()) {
			isWall.set(!isWall.get());
		}
	}

	public function genNavMesh() {
		var walls = this.walls.map(function(line) {
			return line.map(function(elem) {
				return elem.get();
			});
		});
		this.navMesh.set(NavMesh.makeNavMesh(walls, this.tileWidth, this.tileHeight));
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
		for (wall in walls) {
			boolWalls.push(wall.map((e) -> e.get()));
		}

		var map = new Map(boolWalls, tileWidth, tileHeight);
		try {
			var temp = Path.findAStar(map, startPos.get(), endPos.get());
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
		var viewModel = new ViewModel(39, 39, 20, 20);
		Knockout.applyBindings(viewModel);
	}
}
