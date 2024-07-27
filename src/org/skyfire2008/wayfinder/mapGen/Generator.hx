package org.skyfire2008.wayfinder.mapGen;

import org.skyfire2008.wayfinder.path.Map;

interface Generator {

	/**
	 * Generates a map of given size
	 * @param width map width 
	 * @param height map height 
	 * @return Map
	 */
	function makeMap(width: Int, height: Int): Map;

}
