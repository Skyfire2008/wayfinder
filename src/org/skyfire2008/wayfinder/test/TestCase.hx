package org.skyfire2008.wayfinder.test;

typedef PointDef = {
	var x: Int;
	var y: Int;
};

typedef TestCaseDef = {
	var walls: String;
	var width: Int;
	var height: Int;
	var points: Array<PointDef>;
}
