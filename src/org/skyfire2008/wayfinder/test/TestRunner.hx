package org.skyfire2008.wayfinder.test;

import js.html.DivElement;
import js.html.InputElement;
import js.Lib;
import js.Browser;

class TestRunner{
	private var fileInput: InputElement;
	private var resultDiv: DivElement;

	public static function main(): Void{
		Browser.window.addEventListener("load", ()->{
			Browser.document.getElementById("fileInput")
		});
	}
}