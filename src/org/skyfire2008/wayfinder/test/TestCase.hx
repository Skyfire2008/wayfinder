package org.skyfire2008.wayfinder.test;

import org.skyfire2008.wayfinder.path.NavMesh;
import org.skyfire2008.wayfinder.path.NavMesh.NavMeshDef;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.path.Map.MapDef;
import org.skyfire2008.wayfinder.geom.IntPoint.IntPointDef;

typedef TestCaseDef = {
	var map: MapDef;
	var navMesh: NavMeshDef;
	var points: Array<IntPointDef>;
}

class TestCase {
	public function new() {}
}
