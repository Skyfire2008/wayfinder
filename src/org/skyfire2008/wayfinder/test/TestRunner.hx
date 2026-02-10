package org.skyfire2008.wayfinder.test;

import org.skyfire2008.wayfinder.path.FlowField;
import org.skyfire2008.wayfinder.path.GridGraph;

import haxe.Json;

import js.html.Performance;
import js.html.FileReader;
import js.html.DivElement;
import js.html.InputElement;
import js.Lib;
import js.Browser;

import org.skyfire2008.wayfinder.path.ThetaStar;
import org.skyfire2008.wayfinder.path.AStar;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.NavMesh.NavMeshDef;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.path.Map.MapDef;
import org.skyfire2008.wayfinder.path.Pathfinder;
import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.geom.IntPoint.IntPointDef;

using Lambda;

typedef TestCase = {
	var map: MapDef;
	var oldNM: NavMeshDef;
	var newNM: NavMeshDef;
	var points: Array<IntPointDef>;
};

class TestRunner {
	private static var fileInput: InputElement;
	private static var resultDiv: DivElement;

	private static var test: TestCase = null;
	private static var map: Map = null;
	private static var grid: GridGraph = null;
	private static var oldNM: NavMesh = null;
	private static var newNM: NavMesh = null;
	private static var points: Array<IntPoint> = null;

	private static var aStar = new AStar();
	private static var thetaStar = new ThetaStar();

	// INFO: how many times each test runs
	private static var times = 100;

	// INFO: how many units are used for mass tests
	private static var units = 16;

	/**
	 * Finds path from points[0] to points[1] 100 times and calculates average time
	 * @param pathfinder 	path finding algorithm to use
	 * @param graph 		map graph
	 * @return 				average time
	 */
	private static function runTest(pathfinder: Pathfinder, graph: PathGraph): Float {
		var testTimes: Array<Float> = [];
		for (i in 0...times) {
			var timeStart = Browser.window.performance.now();
			var path = pathfinder.findPath(points[0], points[1], graph);
			testTimes.push(Browser.window.performance.now() - timeStart);
		}
		testTimes.sort((x, y) -> x > y ? 1 : -1);

		return testTimes[Std.int(testTimes.length / 2)];
	}

	private static function runMassTest(pathfinder: Pathfinder, graph: PathGraph): Float {
		var testTimes: Array<Float> = [];
		for (i in 0...times) {
			var totalTime = 0.0;

			for (j in 1...units + 1) {
				var timeStart = Browser.window.performance.now();
				var path = pathfinder.findPath(points[0], points[j], graph);
				totalTime += Browser.window.performance.now() - timeStart;
			}

			testTimes.push(totalTime);
		}
		testTimes.sort((x, y) -> x > y ? 1 : -1);

		return testTimes[Std.int(testTimes.length / 2)];
	}

	private static function runMassFlowFieldTest(): Float {
		var flowField = new FlowField(map.walls, points[0]);

		var testTimes: Array<Float> = [];
		for (i in 0...times) {
			var totalTime = 0.0;

			for (j in 1...points.length) {
				testTimes[j] = 0;
				var timeStart = Browser.window.performance.now();
				var path = flowField.getPath(points[j]);
				totalTime += Browser.window.performance.now() - timeStart;
			}

			testTimes.push(totalTime);
		}
		testTimes.sort((x, y) -> x > y ? 1 : -1);

		return testTimes[Std.int(testTimes.length / 2)];
	}

	private static function runSingleFlowFieldTest(): Float {
		var totalTime = 0.0;
		for (i in 0...times) {
			var timeStart = Browser.window.performance.now();
			var flowField = new FlowField(map.walls, points[1]);
			var path = flowField.getPath(points[0]);
			totalTime += Browser.window.performance.now() - timeStart;
		}
		return totalTime / times;
	}

	private static function appendHeader(fileName: String) {
		var hr = Browser.document.createElement("hr");
		var h2 = Browser.document.createElement("h2");
		h2.textContent = fileName;

		resultDiv.appendChild(hr);
		resultDiv.appendChild(h2);
	}

	private static function appendTime(description: String, time: Float): Void {
		var div = Browser.document.createElement("div");
		div.textContent = '${description}: ${Math.round(time * 1000) / 1000}';
		resultDiv.appendChild(div);
	}

	public static function main(): Void {
		Browser.window.addEventListener("load", () -> {
			fileInput = cast Browser.document.getElementById("fileInput");
			resultDiv = cast Browser.document.getElementById("resultDiv");

			fileInput.addEventListener("change", (e) -> {
				var fr = new FileReader();

				fr.addEventListener("load", () -> {
					test = Json.parse(fr.result);

					map = Map.importDef(test.map);
					grid = new GridGraph(map.walls);
					oldNM = NavMesh.importDef(test.oldNM, map.width, map.height);
					newNM = NavMesh.importDef(test.newNM, map.width, map.height);
					points = test.points.map((p) -> IntPoint.importDef(p));

					appendHeader(fileInput.files[0].name);

					// A* ON GRID:
					appendTime("A* on grid", runTest(aStar, grid));

					// MASS A* ON GRID:
					// appendTime('A* with ${units} units on grid', runMassTest(aStar, grid));

					// THETA* ON GRID:
					appendTime("Theta* on grid", runTest(thetaStar, grid));

					// MASS THETA* ON GRID:
					// appendTime('Theta* with ${units} units on grid', runMassTest(thetaStar, grid));

					// A* ON OLD NAVMESH:
					appendTime("A* on old nav mesh", runTest(aStar, oldNM));

					// MASS A* ON OLD NAVMESH:
					// appendTime('A* with ${units} units on old nav mesh', runMassTest(thetaStar, oldNM));

					// THETA* ON OLD NAVMESH:
					appendTime("Theta* on old nav mesh", runTest(thetaStar, oldNM));

					// MASS THETA* ON OLD NAV MESH
					// appendTime('Theta* with ${units} units on old nav mesh', runMassTest(thetaStar, oldNM));

					// A* ON NEW NAVMESH:
					appendTime("A* on new nav mesh", runTest(aStar, newNM));

					// MASS A* ON NEW NAVMESH:
					// appendTime('A* with ${units} units on new nav mesh', runMassTest(aStar, newNM));

					// THETA* ON NEW NAVMESH:
					appendTime("Theta* on new nav mesh", runTest(thetaStar, newNM));

					// MASS THETA* ON NEW NAVMESH:
					// appendTime('Theta* with ${units} units on new nav mesh', runMassTest(thetaStar, newNM));

					// FLOW FIELD:
					// var flowFieldTime = runSingleFlowFieldTest();
					// appendTime("Flow field on grid", flowFieldTime);

					// MASS FLOW FIELD:
					// appendTime("Mass flow field on grid", flowFieldTime + runMassFlowFieldTest());

				});

				fr.readAsText(fileInput.files[0]);
			});
		});
	}
}
