package org.skyfire2008.wayfinder;

import js.Lib;
import js.html.Blob;
import js.html.MouseEvent;
import js.html.svg.SVGElement;
import js.Browser;
import js.html.URL;

import knockout.Knockout;
import knockout.Observable;

import org.skyfire2008.wayfinder.path.Pathfinder;
import org.skyfire2008.wayfinder.path.FlowField;
import org.skyfire2008.wayfinder.path.ThetaStar;
import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.path.AStar;
import org.skyfire2008.wayfinder.path.GridGraph;
import org.skyfire2008.wayfinder.mapGen.Random;
import org.skyfire2008.wayfinder.mapGen.Generator;
import org.skyfire2008.wayfinder.mapGen.Cave;
import org.skyfire2008.wayfinder.mapGen.Maze;
import org.skyfire2008.wayfinder.util.Util;

using Lambda;

typedef GenInfo = {
	var name: String;
	var gen: Generator;
};

typedef Line = {
	var a: IntPoint;
	var b: IntPoint;
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
	public var path: Observable<Array<Line>>;
	public var flowField: Observable<FlowField>;
	public var message: Observable<String>;

	public var generators: Array<GenInfo> = [
		{name: "Random", gen: new Random(0.25)},
		{name: "Cave", gen: new Cave(0.5, 3, 4, 6)},
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
		this.flowField = Knockout.observable(null);
		this.message = Knockout.observable(null);

		this.generator = Knockout.observable(generators[0]);
		this.walls = Knockout.observable();
		generateMap();
	}

	public function stopDrawing() {
		drawing = false;
	}

	public function onTileMouseDown(x: Int, y: Int, e: MouseEvent) {

		// skip non-main(left) button presses
		if (e.button != 0) {
			return;
		}

		var isWall = walls.get()[y][x];

		if (settingStart.get()) {
			startPos.set(new IntPoint(x, y));
			settingStart.set(false);

		} else if (settingEnd.get()) {
			endPos.set(new IntPoint(x, y));
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
		this.navMesh.set(new NavMesh(walls));
	}

	public function genNavMeshImproved() {
		var walls = this.walls.get().map(function(line) {
			return line.map(function(elem) {
				return elem.get();
			});
		});

		this.navMesh.set(new NavMesh(walls, true));
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
		this.flowField.set(null);
		this.path.set(null);
		this.startPos.set(null);
		this.endPos.set(null);
	}

	public function genFlowField() {
		var boolWalls: Array<Array<Bool>> = [];
		for (wall in walls.get()) {
			boolWalls.push(wall.map((e) -> e.get()));
		}

		if (endPos.get() == null) {
			message.set("Set end position first!");
		} else {
			var timeStart = Browser.window.performance.now();
			var temp = new FlowField(boolWalls, endPos.get());
			var time = Browser.window.performance.now() - timeStart;
			flowField.set(temp);
			message.set("Flow field generated in: " + time);
		}
	}

	public function findFlowFieldPath() {

		if (flowField.get() == null) {
			message.set("Generate a flow field first");
		}

		try {
			var field = flowField.get();
			var start = this.startPos.get();
			var timeStart = Browser.window.performance.now();
			var temp = field.getPath(start);
			var time = Browser.window.performance.now() - timeStart;

			var resultingPath: Array<Line> = [];
			var pathLength: Float = 0;
			for (i in 0...temp.length - 1) {
				var a = temp[i];
				var b = temp[i + 1];
				resultingPath.push({a: a, b: b});
				var dx = b.x - a.x;
				var dy = b.y - a.y;
				pathLength += Math.sqrt(dx * dx + dy * dy);
			}

			path.set(resultingPath);
			message.set("Path length: " + pathLength + ", elapsed time: " + time);

		} catch (e) {
			message.set(e.message);
		}
	}

	public function setStart() {
		settingStart.set(true);
		settingEnd.set(false);
	}

	public function setEnd() {
		settingStart.set(false);
		settingEnd.set(true);
	}

	public function findAPathNavMesh() {
		var navMeshValue = navMesh.get();
		if (navMeshValue != null) {

			var aStar = new AStar();
			try {
				var timeStart = Browser.window.performance.now();
				var points = aStar.findPath(startPos.get(), endPos.get(), navMeshValue);
				var time = Browser.window.performance.now() - timeStart;

				calcAndSetPathLines(points, time);

			} catch (e) {
				message.set(e.message);
			}

		} else {
			message.set("Generate navmesh first");
		}
	}

	public function findThetaPath() {
		findPathGrid(new ThetaStar());
	}

	public function findAPath() {
		findPathGrid(new AStar());
	}

	public function exportSvg() {
		var svg: SVGElement = cast Browser.document.getElementById("mainSvg").cloneNode(true);
		svg.removeAttribute("data-bind");
		svg.setAttribute("xmlns", "http://www.w3.org/2000/svg");
		svg.setAttribute("version", "1.1");

		var i = 0;
		while (i < svg.childNodes.length) {
			var child = svg.childNodes[i];
			i++;

			if (child.nodeType == js.html.Node.COMMENT_NODE || child.nodeType == js.html.Node.TEXT_NODE) {
				svg.removeChild(child);
				i--;
			} else if (child.nodeType == js.html.Node.ELEMENT_NODE) {
				var elem: SVGElement = cast child;
				if (elem.hasAttribute("data-bind")) {
					elem.removeAttribute("data-bind");
				}
			}
		}

		var a = Browser.document.createAnchorElement();
		a.download = "diagram.svg";
		a.href = URL.createObjectURL(new Blob([svg.outerHTML]));
		a.addEventListener("click", () -> Browser.window.setTimeout(() -> URL.revokeObjectURL(a.href), 1000));
		a.click();
	}

	private function calcAndSetPathLines(points: Array<IntPoint>, time: Float) {
		var resultingPath: Array<Line> = [];
		var pathLength: Float = 0;
		for (i in 0...points.length - 1) {
			var a = points[i];
			var b = points[i + 1];
			resultingPath.push({a: a, b: b});
			var dx = b.x - a.x;
			var dy = b.y - a.y;
			pathLength += Math.sqrt(dx * dx + dy * dy);
		}

		path.set(resultingPath);
		message.set("Path length: " + pathLength + ", elapsed time: " + time);
	}

	private function findPathGrid(pathfinder: Pathfinder) {
		// convert wall array to grid graph
		var boolWalls: Array<Array<Bool>> = [];
		for (wall in walls.get()) {
			boolWalls.push(wall.map((e) -> e.get()));
		}
		var grid = new GridGraph(boolWalls);

		try {
			var timeStart = Browser.window.performance.now();
			var points = pathfinder.findPath(startPos.get(), endPos.get(), grid);
			var time = Browser.window.performance.now() - timeStart;
			calcAndSetPathLines(points, time);
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
		var viewModel = new ViewModel(59, 59, 16, 16);
		Knockout.applyBindings(viewModel);
	}
}
