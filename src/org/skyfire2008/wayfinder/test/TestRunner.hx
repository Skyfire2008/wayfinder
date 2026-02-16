package org.skyfire2008.wayfinder.test;

import haxe.Json;

import js.html.Performance;
import js.html.FileReader;
import js.html.DivElement;
import js.html.InputElement;
import js.Lib;
import js.Browser;

import org.skyfire2008.wayfinder.path.FlowField;
import org.skyfire2008.wayfinder.path.GridGraph;
import org.skyfire2008.wayfinder.path.ThetaStar;
import org.skyfire2008.wayfinder.path.AStar;
import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.NavMesh.NavMeshDef;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.path.Map.MapDef;
import org.skyfire2008.wayfinder.path.Pathfinder;
import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.geom.IntPoint.IntPointDef;
import org.skyfire2008.wayfinder.test.TestCase;

using Lambda;

class TestRunner {
	private static var fileInput: InputElement;
	private static var resultDiv: DivElement;

	private static var test: TestCase = null;

	// INFO: how many times each test runs
	private static var times = 100;

	// INFO: how many units are used for mass tests
	private static var units = 16;

	private static function appendHeader(fileName: String) {
		var hr = Browser.document.createElement("hr");
		var h2 = Browser.document.createElement("h2");
		h2.textContent = fileName;

		resultDiv.appendChild(hr);
		resultDiv.appendChild(h2);
	}

	private static function appendTime(description: String, time: Float): Void {
		var div = Browser.document.createElement("div");
		div.textContent = '${description}: ${Math.round(time * 10000) / 10}';
		resultDiv.appendChild(div);
	}

	public static function main(): Void {
		Browser.window.addEventListener("load", () -> {
			fileInput = cast Browser.document.getElementById("fileInput");
			resultDiv = cast Browser.document.getElementById("resultDiv");

			fileInput.addEventListener("change", (e) -> {
				var fr = new FileReader();

				fr.addEventListener("load", () -> {
					var testCase = Json.parse(fr.result);

					test = new TestCase(1, 16, testCase, appendTime);

					appendHeader(fileInput.files[0].name);
					test.runAll();
				});

				fr.readAsText(fileInput.files[0]);
			});
		});
	}
}
