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
import org.skyfire2008.wayfinder.test.TestCase.TestCaseDef;

class CPPTestRunner {
	public static function main() {
		var stdin = Sys.stdin();
		var stderr = Sys.stderr();
		while (true) {
			var path: String = stdin.readLine();

			if (FileSystem.exists(path)) {
				var fileString = File.getContent(path);
				trace('$path\n');

				var test: TestCaseDef = Json.parse(fileString);
				var testCase = new TestCase(100, 16, test, (msg: String, time: Float) -> trace(msg, Math.round(time * 10000) / 10));
				testCase.runAll();

			} else {
				stderr.writeString('File $path does not exist\n');
			}
		}
	}
}
