const fs = require("fs");

const resultText = fs.readFileSync("tests/results.txt").toString();

const order = [
	"aStar",
	"thetaStar",
	"aStarOldNM",
	"thetaStarOldNM",
	"aStarNewNM",
	"thetaStarNewNM",
	"flowField"
];

const singularArgMap = new Map();
singularArgMap.set("A* on grid:", "aStar");
singularArgMap.set("Theta* on grid:", "thetaStar");
singularArgMap.set("A* on old nav mesh:", "aStarOldNM");
singularArgMap.set("Theta* on old nav mesh:", "thetaStarOldNM");
singularArgMap.set("A* on new nav mesh:", "aStarNewNM");
singularArgMap.set("Theta* on new nav mesh:", "thetaStarNewNM");
singularArgMap.set("Flow field on grid:", "flowField");

const massArgMap = new Map();
massArgMap.set("A* with 16 units on grid:", "aStar");
massArgMap.set("Theta* with 16 units on grid:", "thetaStar");
massArgMap.set("A* with 16 units on old nav mesh:", "aStarOldNM");
massArgMap.set("Theta* with 16 units on old nav mesh:", "thetaStarOldNM");
massArgMap.set("A* with 16 units on new nav mesh:", "aStarNewNM");
massArgMap.set("Theta* with 16 units on new nav mesh:", "thetaStarNewNM");
massArgMap.set("Mass flow field on grid:", "flowField");

const massResults = {};
const singularResults = {};

const lines = resultText.split("\n");

let currentSingular = null;
let currentMass = null;
for (const line of lines) {

	if (line.indexOf(".json") >= 0) {
		currentSingular = {};
		singularResults[line.trim()] = currentSingular;
		currentMass = {};
		massResults[line.trim()] = currentMass;
	} else {
		let found = false;

		for (const [text, arg] of singularArgMap) {
			const index = line.indexOf(text);

			if (index >= 0) {
				found = true;
				currentSingular[arg] = line.substring(index + text.length).trim();
			}
		}

		if (found) {
			continue;
		}

		for (const [text, arg] of massArgMap) {
			const index = line.indexOf(text);

			if (index >= 0) {
				found = true;
				currentMass[arg] = line.substring(index + text.length).trim();
			}
		}
	}
}

/**
 * 
 * @param {Object} foobar 
 */
const makeCSV = (foobar) => {
	let result = "map,";
	for (const item of order) {
		result += item + ",";
	}
	result = result.substring(0, result.length - 1);
	result += "\n";

	for (const name of Object.getOwnPropertyNames(foobar)) {
		const object = foobar[name];
		result += name + ",";
		for (const item of order) {
			result += object[item] + ",";
		}

		result = result.substring(0, result.length - 1);
		result += "\n";
	}

	return result;
};

const massCsv = makeCSV(massResults);
const singularCsv = makeCSV(singularResults);

fs.writeFileSync("mass.csv", massCsv);
fs.writeFileSync("singular.csv", singularCsv);