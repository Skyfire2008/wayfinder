package org.skyfire2008.wayfinder;

import js.html.FileReader;

import haxe.Json;

import js.Lib;
import js.Browser;
import js.html.Blob;
import js.html.MouseEvent;
import js.html.Event;
import js.html.InputElement;
import js.html.svg.SVGElement;
import js.html.URL;

import knockout.Knockout;
import knockout.Observable;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.Pathfinder;
import org.skyfire2008.wayfinder.path.FlowField;
import org.skyfire2008.wayfinder.path.ThetaStar;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.path.AStar;
import org.skyfire2008.wayfinder.path.GridGraph;
import org.skyfire2008.wayfinder.mapGen.Random;
import org.skyfire2008.wayfinder.mapGen.Generator;
import org.skyfire2008.wayfinder.mapGen.Cave;
import org.skyfire2008.wayfinder.mapGen.Maze;
import org.skyfire2008.wayfinder.mapGen.Empty;
import org.skyfire2008.wayfinder.test.TestCase.TestCaseDef;

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
	public var ensureConnectivity: Observable<Bool>;

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
	public var closed: Observable<Array<IntPoint>>;
	public var flowField: Observable<FlowField>;
	public var message: Observable<String>;

	public var generators: Array<GenInfo> = [
		{name: "Random", gen: new Random(0.3)},
		{name: "Cave", gen: new Cave(0.5, 3, 4, 6)},
		{name: "Maze", gen: new Maze()},
		{name: "Empty", gen: new Empty()}
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
		this.ensureConnectivity = Knockout.observable(false);

		this.removing = Knockout.observable(false);
		this.settingStart = Knockout.observable(false);
		this.settingEnd = Knockout.observable(false);
		this.startPos = Knockout.observable(null);
		this.endPos = Knockout.observable(null);

		this.navMesh = Knockout.observable(null);
		this.path = Knockout.observable([]);
		this.closed = Knockout.observable([]);
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
				map.walls[y][x] = isWall.get();
			}
		}
	}

	public function onTileMouseEnter(x: Int, y: Int, e: MouseEvent) {
		var isWall = walls.get()[y][x];
		if (drawing && isWall.get() == removing.get()) {
			isWall.set(!isWall.get());
			map.walls[y][x] = isWall.get();
		}
	}

	public function genNavMesh() {
		var walls = this.walls.get().map(function(line) {
			return line.map(function(elem) {
				return elem.get();
			});
		});

		var timeStart = Browser.window.performance.now();
		var navMesh = NavMesh.makeNavMesh(walls);
		var time = Browser.window.performance.now() - timeStart;
		message.set('Nav mesh generated in: ${time}');

		this.navMesh.set(navMesh);
	}

	public function genNavMeshImproved() {
		var walls = this.walls.get().map(function(line) {
			return line.map(function(elem) {
				return elem.get();
			});
		});

		var timeStart = Browser.window.performance.now();
		var navMesh = NavMesh.makeNavMesh(walls, true);
		var time = Browser.window.performance.now() - timeStart;
		message.set('Nav mesh generated in: ${time}');

		this.navMesh.set(navMesh);
	}

	public function generateMap() {
		var width = this.tempWidth.get();
		var height = this.tempHeight.get();

		this.map = generator.get().gen.makeMap(width, height);
		if (ensureConnectivity.get()) {
			map.ensureConnectivity();
		}

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
				var foo = aStar.findPath(startPos.get(), endPos.get(), navMeshValue);
				var time = Browser.window.performance.now() - timeStart;

				calcAndSetPathLines(foo.path, time);

			} catch (e) {
				message.set(e.message);
			}

		} else {
			message.set("Generate navmesh first");
		}
	}

	public function findThetaPathNavMesh() {
		var navMeshValue = navMesh.get();
		if (navMeshValue != null) {

			var thetaStar = new ThetaStar();
			try {
				var timeStart = Browser.window.performance.now();
				var foo = thetaStar.findPath(startPos.get(), endPos.get(), navMeshValue);
				var time = Browser.window.performance.now() - timeStart;

				calcAndSetPathLines(foo.path, time);

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

	public function exportTestCase() {
		var navMesh = this.navMesh.get();

		var points: Array<IntPointDef> = [];
		if (this.startPos.get() != null) {
			points.push(IntPoint.exportDef(this.startPos.get()));
		}
		if (this.endPos.get() != null) {
			points.push(IntPoint.exportDef(this.endPos.get()));
		}

		var result: TestCaseDef = {
			map: Map.exportDef(this.map),
			navMesh: navMesh != null ? NavMesh.exportDef(navMesh) : null,
			points: points
		};

		var resultText = Json.stringify(result, null, "  ");

		var a = Browser.document.createAnchorElement();
		a.download = "testCase.json";
		a.href = URL.createObjectURL(new Blob([resultText]));
		a.addEventListener("click", () -> Browser.window.setTimeout(() -> URL.revokeObjectURL(a.href), 1000));
		a.click();
	}

	public function importTestCase(_: Any, e: Event) {
		var elem: InputElement = cast e.target;

		var fr = new FileReader();
		fr.addEventListener("load", () -> {
			var testCaseDef: TestCaseDef = Json.parse(fr.result);

			// import map
			this.map = Map.importDef(testCaseDef.map);
			var newWalls = [
				for (y in 0...map.height) [
					for (x in 0...map.width)
						Knockout.observable(map.walls[y][x])
				]
			];
			this.walls.set(newWalls);
			this.width.set(map.width);
			this.height.set(map.height);

			// import navmesh
			if (testCaseDef.navMesh != null) {
				this.navMesh.set(NavMesh.importDef(testCaseDef.navMesh, map.width, map.height));
			} else if (testCaseDef.newNM != null) {
				this.navMesh.set(NavMesh.importDef(cast testCaseDef.newNM, map.width, map.height));
			} else {
				this.navMesh.set(null);
			}

			// set start and end pos
			if (testCaseDef.points != null && testCaseDef.points.length >= 2) {
				this.startPos.set(IntPoint.importDef(testCaseDef.points[0]));
				this.endPos.set(IntPoint.importDef(testCaseDef.points[1]));
			} else {
				this.startPos.set(null);
				this.endPos.set(null);
			}

			// reset state
			this.message.set(null);
			this.flowField.set(null);
			this.path.set(null);
			this.closed.set([]);

		});
		fr.readAsText(elem.files[0]);
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
			var foo = pathfinder.findPath(startPos.get(), endPos.get(), grid);
			var time = Browser.window.performance.now() - timeStart;
			calcAndSetPathLines(foo.path, time);
			trace('closed points: ${foo.closed.length}');
			closed.set(foo.closed);

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
