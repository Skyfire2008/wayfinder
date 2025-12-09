package org.skyfire2008.wayfinder.test;

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

	private static function runTest(pathfinder: Pathfinder, graph: PathGraph): Float {

		var totalTime = 0.0;
		for (i in 0...1000) {
			var timeStart = Browser.window.performance.now();
			var path = pathfinder.findPath(points[0], points[1], graph);
			totalTime += Browser.window.performance.now() - timeStart;
		}
		return totalTime / 1000;
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

					// A* ON GRID:
					var aStarTime = runTest(aStar, grid);

					// THETA* ON GRID
					var thetaStarTime = runTest(thetaStar, grid);

					// A* ON OLD NAVMESH:
					var aStarOldNMTime = runTest(aStar, oldNM);

					// A* ON NEW NAVMESH:
					var aStarNewNMTime = runTest(aStar, newNM);

					// THETA* ON OLD NAVMESH:
					var thetaStarOldNMTime = runTest(thetaStar, oldNM);

					// THETA* ON NEW NAVMESH:
					var thetaStarNewNMTime = runTest(thetaStar, newNM);

					// append result to div
					appendTime("A* on grid", aStarTime);
					appendTime("Theta* on grid", thetaStarTime);
					appendTime("A* on old nav mesh", aStarOldNMTime);
					appendTime("A* on new nav mesh", aStarNewNMTime);
					appendTime("Theta* on old nav mesh", thetaStarOldNMTime);
					appendTime("Theta* on new nav mesh", thetaStarNewNMTime);
				});

				fr.readAsText(fileInput.files[0]);
			});
		});
	}
}
