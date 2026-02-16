package org.skyfire2008.wayfinder.test;

import haxe.Timer;

import org.skyfire2008.wayfinder.path.ThetaStar;
import org.skyfire2008.wayfinder.path.AStar;
import org.skyfire2008.wayfinder.path.Pathfinder;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.NavMesh.NavMeshDef;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.path.GridGraph;
import org.skyfire2008.wayfinder.path.FlowField;
import org.skyfire2008.wayfinder.path.Map.MapDef;
import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.geom.IntPoint.IntPointDef;

typedef TestCaseDef = {
	var map: MapDef;
	var navMesh: NavMeshDef;
	var ?oldNM: NavMeshDef;
	var ?newNM: NavMeshDef;
	var points: Array<IntPointDef>;
}

class TestCase {
	private var times: Int;
	private var units: Int;
	private var map: Map;
	private var grid: GridGraph;
	private var oldNM: NavMesh;
	private var newNM: NavMesh;
	private var points: Array<IntPoint>;

	private var aStar: AStar;
	private var thetaStar: ThetaStar;
	private var reportFunc: (String, Float) -> Void;

	public function new(times: Int, units: Int, testCase: TestCaseDef, reportFunc: (String, Float) -> Void) {
		this.times = times;
		this.units = units;
		map = Map.importDef(testCase.map);
		grid = new GridGraph(map.walls);
		oldNM = NavMesh.importDef(testCase.oldNM, map.width, map.height);
		newNM = NavMesh.importDef(testCase.newNM, map.width, map.height);
		points = testCase.points.map((p) -> IntPoint.importDef(p));

		aStar = new AStar();
		thetaStar = new ThetaStar();
		this.reportFunc = reportFunc;
	}

	private inline function runTest(pathfinder: Pathfinder, graph: PathGraph): Float {
		var testTimes: Array<Float> = [];
		for (i in 0...times) {
			var timeStart = Timer.stamp();
			var path = pathfinder.findPath(points[0], points[1], graph);
			testTimes.push(Timer.stamp() - timeStart);
		}
		testTimes.sort((x, y) -> x > y ? 1 : -1);

		return testTimes[Std.int(testTimes.length / 2)];
	}

	private inline function runMassTest(pathfinder: Pathfinder, graph: PathGraph): Float {

		var testTimes: Array<Float> = [];
		for (i in 0...times) {
			var totalTime = 0.0;

			for (j in 1...units + 1) {
				var timeStart = Timer.stamp();
				var path = pathfinder.findPath(points[0], points[j], graph);
				totalTime += Timer.stamp() - timeStart;
			}

			testTimes.push(totalTime);
		}
		testTimes.sort((x, y) -> x > y ? 1 : -1);

		return testTimes[Std.int(testTimes.length / 2)];
	}

	private function runSingleFlowFieldTest(): Float {
		var totalTime = 0.0;
		for (i in 0...times) {
			var timeStart = Timer.stamp();
			var flowField = new FlowField(map.walls, points[1]);
			var path = flowField.getPath(points[0]);
			totalTime += Timer.stamp() - timeStart;
		}
		return totalTime / times;
	}

	private function runMassFlowFieldTest(): Float {
		var flowField = new FlowField(map.walls, points[0]);

		var testTimes: Array<Float> = [];
		for (i in 0...times) {
			var totalTime = 0.0;

			for (j in 1...points.length) {
				testTimes[j] = 0;
				var timeStart = Timer.stamp();
				var path = flowField.getPath(points[j]);
				totalTime += Timer.stamp() - timeStart;
			}

			testTimes.push(totalTime);
		}
		testTimes.sort((x, y) -> x > y ? 1 : -1);

		return testTimes[Std.int(testTimes.length / 2)];
	}

	public function runAll() {
		// A* ON GRID:
		reportFunc("A* on grid", runTest(aStar, grid));

		// MASS A* ON GRID:
		reportFunc('A* with ${units} units on grid', runMassTest(aStar, grid));

		// THETA* ON GRID:
		reportFunc("Theta* on grid", runTest(thetaStar, grid));

		// MASS THETA* ON GRID:
		reportFunc('Theta* with ${units} units on grid', runMassTest(thetaStar, grid));

		// A* ON OLD NAVMESH:
		reportFunc("A* on old nav mesh", runTest(aStar, oldNM));

		// MASS A* ON OLD NAVMESH:
		reportFunc('A* with ${units} units on old nav mesh', runMassTest(thetaStar, oldNM));

		// THETA* ON OLD NAVMESH:
		reportFunc("Theta* on old nav mesh", runTest(thetaStar, oldNM));

		// MASS THETA* ON OLD NAV MESH
		reportFunc('Theta* with ${units} units on old nav mesh', runMassTest(thetaStar, oldNM));

		// A* ON NEW NAVMESH:
		reportFunc("A* on new nav mesh", runTest(aStar, newNM));

		// MASS A* ON NEW NAVMESH:
		reportFunc('A* with ${units} units on new nav mesh', runMassTest(aStar, newNM));

		// THETA* ON NEW NAVMESH:
		reportFunc("Theta* on new nav mesh", runTest(thetaStar, newNM));

		// MASS THETA* ON NEW NAVMESH:
		reportFunc('Theta* with ${units} units on new nav mesh', runMassTest(thetaStar, newNM));

		// FLOW FIELD:
		var flowFieldTime = runSingleFlowFieldTest();
		reportFunc("Flow field on grid", flowFieldTime);

		// MASS FLOW FIELD:
		reportFunc("Mass flow field on grid", flowFieldTime + runMassFlowFieldTest());
	}
}
