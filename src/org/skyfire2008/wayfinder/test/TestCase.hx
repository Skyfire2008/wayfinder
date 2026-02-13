package org.skyfire2008.wayfinder.test;

import org.skyfire2008.wayfinder.path.GridGraph;

import haxe.Timer;

import org.skyfire2008.wayfinder.path.ThetaStar;
import org.skyfire2008.wayfinder.path.AStar;
import org.skyfire2008.wayfinder.path.Pathfinder;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.NavMesh.NavMeshDef;
import org.skyfire2008.wayfinder.path.Map;
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

// FIXME: rename this shit!
typedef Foo = {
	var map: MapDef;
	var oldNM: NavMeshDef;
	var newNM: NavMeshDef;
	var points: Array<IntPointDef>;
};

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

	public function new(times: Int, units: Int, testCase: Foo) {
		this.times = times;
		this.units = units;
		map = Map.importDef(testCase.map);
		grid = new GridGraph(map.walls);
		oldNM = NavMesh.importDef(testCase.oldNM, map.width, map.height);
		newNM = NavMesh.importDef(testCase.newNM, map.width, map.height);
		points = testCase.points.map((p) -> IntPoint.importDef(p));

		aStar = new AStar();
		thetaStar = new ThetaStar();
	}

	private inline function runTest(pathfinder: Pathfinder, graph: PathGraph): Float {
		#if cpp
		cpp.vm.Gc.enterGCFreeZone();
		#end
		var testTimes: Array<Float> = [];
		for (i in 0...times) {
			var timeStart = Timer.stamp();
			var path = pathfinder.findPath(points[0], points[1], graph);
			testTimes.push(Timer.stamp() - timeStart);
		}
		testTimes.sort((x, y) -> x > y ? 1 : -1);

		#if cpp
		cpp.vm.Gc.exitGCFreeZone();
		#end

		return testTimes[Std.int(testTimes.length / 2)];
	}

	private inline function runMassTest(pathfinder: Pathfinder, graph: PathGraph): Float {
		#if cpp
		cpp.vm.Gc.enterGCFreeZone();
		#end

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

		#if cpp
		cpp.vm.Gc.exitGCFreeZone();
		#end

		return testTimes[Std.int(testTimes.length / 2)];
	}

	public function runAStar(): Float {
		return runTest(aStar, grid);
	}

	public function runMassAStar(): Float {
		return runMassTest(aStar, grid);
	}

	public function runThetaStar(): Float {
		return runTest(thetaStar, grid);
	}

	public function runMassThetaStar(): Float {
		return runMassTest(thetaStar, grid);
	}
}
