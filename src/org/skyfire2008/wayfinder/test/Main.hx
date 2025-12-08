package org.skyfire2008.wayfinder.test;

import haxe.Json;
import haxe.ds.StringMap;

import js.node.Fs;

import org.skyfire2008.wayfinder.mapGen.Maze;
import org.skyfire2008.wayfinder.mapGen.Cave;
import org.skyfire2008.wayfinder.mapGen.Random;
import org.skyfire2008.wayfinder.mapGen.Empty;
import org.skyfire2008.wayfinder.mapGen.Generator;
import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.Map;

class Main {
	public static var sizeMap: StringMap<Int> = ["small" => 50, "average" => 200, "large" => 1000];
	public static var generatorMap: StringMap<Generator> = [
		"empty" => new Empty(),
		"random" => new Random(0.3),
		"cave" => new Cave(0.5, 3, 4, 6),
		"maze" => new Maze()
	];

	private static function generateTestCase(genName: String, sizeName: String) {
		var fileName = '${genName}_${sizeName}.json';

		if (Fs.existsSync(fileName)) {
			trace('Did not generate test case: file ${fileName} already exists');
		} else {
			var size = sizeMap.get(sizeName);
			var generator = generatorMap.get(genName);
			var map = generator.makeMap(size, size);
			trace("map generated");

			map.ensureConnectivity();
			var mapDef = Map.exportDef(map);
			trace("connectivity ensured");

			// find points
			var p0: IntPoint = new IntPoint();
			if (map.isPointWall(p0)) {

				var found = false;
				var dist = 2;
				while (true) {

					for (x in 1...dist) {
						if (!map.isWall(x, dist)) {
							p0.x = x;
							p0.y = dist;
							found = true;
							break;
						}
					}

					if (found) {
						break;
					}

					for (y in 1...dist) {
						if (!map.isWall(dist, y)) {
							p0.x = dist;
							p0.y = y;
							found = true;
							break;
						}
					}

					if (found) {
						break;
					}

					dist++;
				}
			}

			var p1: IntPoint = new IntPoint(size - 1, size - 1);
			if (map.isPointWall(p1)) {

				var found = false;
				var dist = 1;
				while (true) {

					var start = size - (1 + dist);

					for (x in start...size) {
						if (!map.isWall(x, dist)) {
							p0.x = x;
							p0.y = dist;
							found = true;
							break;
						}
					}

					if (found) {
						break;
					}

					for (y in start...size) {
						if (!map.isWall(dist, y)) {
							p0.x = dist;
							p0.y = y;
							found = true;
							break;
						}
					}

					if (found) {
						break;
					}

					dist++;
				}
			}

			var points = [p0, p1];
			for (i in 0...100) {

				while (true) {
					var x = Std.int(Math.random() * size);
					var y = Std.int(Math.random() * size);
					if (!map.isWall(x, y)) {
						points.push(new IntPoint(x, y));
						break;
					}
				}
			}
			trace("points found");
			var pointsDef: Array<IntPointDef> = points.map((p) -> {x: p.x, y: p.y});

			var oldNM = NavMesh.makeNavMesh(map.walls);
			var oldNMDef = NavMesh.exportDef(oldNM);
			trace("old nav mesh created");

			var newNM = NavMesh.makeNavMesh(map.walls, true);
			var newNMDef = NavMesh.exportDef(newNM);
			trace("new nav mesh created");

			Fs.writeFileSync(fileName, Json.stringify({
				oldNM: oldNMDef,
				newNM: newNMDef,
				points: pointsDef,
				map: mapDef
			}));
			trace('test case ${fileName} saved');
		}
	}

	public static function main(): Void {
		generateTestCase("cave", "small");
	}
}
