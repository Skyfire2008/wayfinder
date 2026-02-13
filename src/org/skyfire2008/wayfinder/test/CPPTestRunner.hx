package org.skyfire2008.wayfinder.test;

import haxe.io.Input;
import haxe.Json;

import sys.io.File;
import sys.FileSystem;

import Sys;

import org.skyfire2008.wayfinder.path.Map.MapDef;
import org.skyfire2008.wayfinder.path.NavMesh.NavMeshDef;
import org.skyfire2008.wayfinder.geom.IntPoint.IntPointDef;
import org.skyfire2008.wayfinder.test.TestCase;
import org.skyfire2008.wayfinder.test.TestCase.Foo;

class CPPTestRunner {
	public static function main() {
		var stdin = Sys.stdin();
		var stderr = Sys.stderr();
		var stdout = Sys.stdout();
		while (true) {
			var path: String = stdin.readLine();

			if (FileSystem.exists(path)) {
				var fileString = File.getContent(path);

				var test: Foo = Json.parse(fileString);
				var testCase = new TestCase(100, 16, test);

				stdout.writeString('A* on grid: ${testCase.runAStar()}\n');
				stdout.writeString('Mass A* on grid: ${testCase.runMassAStar()}\n');
				stdout.writeString('Theta* on grid: ${testCase.runThetaStar()}\n');
				stdout.writeString('Mass Theta* on grid: ${testCase.runMassThetaStar()}\n');

				stdout.writeString("\n");

			} else {
				stderr.writeString('File $path does not exist\n');
			}
		}
	}
}
