module src.handlers.jsonParser;

import std.json;
import std.file;
import std.stdio;
import src.entities.player;
import src.handlers.containers;
import src.entities.knowledgeTree;
import src.entities.branch;
import src.entities.ship;
import src.entities.map;
import src.entities.planet;

class JsonParser {
	static bool saveState(GameState state, Vector2d camPos) {
		JSONValue save = ["game" : "AlienCivilisations"];
		save.object["date"] = __DATE__;
		save.object["cameraPosition"] = vecToJSON(camPos);
		save.object["gameState"] = stateToJSON(state);
		writeln(save.toPrettyString());
		return true;
	}
	/** Parses GameState object and its contents into JSON **/
	static JSONValue stateToJSON(GameState state) {
		JSONValue jState = ["queuePosition" : state.queuePosition];
		jState.object["players"] = playersToJSON(state.players);
		jState.object["map"] = mapToJSON(state.map);
		return jState;
	}
	/** Converts Map object and its contents into JSONValue **/
	static JSONValue mapToJSON(Map map) {
		JSONValue jMap = ["size" : map.size];
		jMap.object["planets"] = JSONValue();
		jMap["planets"].type = JSON_TYPE.ARRAY;
		foreach(planet; map.planets) {
			jMap["planets"].array ~= planetToJSON(planet);
		}
		return jMap;
	}
	/** Converts Planet object into JSONValue **/
	static JSONValue planetToJSON(Planet planet, ) {
		JSONValue jsonPlanet = ["name" : planet.name];
		jsonPlanet.object["position"] = vecToJSON(planet.position);
		jsonPlanet.object["radius"] = planet.radius;
		jsonPlanet.object["breathableAtmosphere"] = planet.breathableAtmosphere;
		jsonPlanet.object["ownerId"] = planet.owner ? planet.owner.uniqueId : -1;
		jsonPlanet.object["population"] = JSONValue([planet.population]);
		jsonPlanet.object["food"] = planet.food;
		jsonPlanet.object["militaryUnits"] = planet.militaryUnits;
		jsonPlanet.object["shipOrders"] = shipsToJSON(planet.shipOrders);
		return jsonPlanet;
	}
	/** Converts Vector2d object into JSONValue **/
	static JSONValue vecToJSON(Vector2d vec) {
		return JSONValue(["x": vec.x, "y": vec.y]);
	}
	/** Converts Player object and its knowledge tree and ships into JSONValue **/
	static JSONValue[] playersToJSON(Player[] players){
		JSONValue[] jPlayers;
		foreach(player; players) {
			JSONValue p = ["name" : player.name];
			p.object["uniqueId"] = player.uniqueId;
			p.object["knowledgeTree"] = ktToJSON(player.knowledgeTree);
			p.object["ships"] = shipsToJSON(player.ships);
			jPlayers ~= p;
		}
		return jPlayers;
	} 
	/** Converts array of Ship objects into JSONValue **/
	static JSONValue[] shipsToJSON(Ship[] ships) {
		JSONValue[] jShips;
		foreach(ship; ships){
			JSONValue json = ["type" : ""];
			if(MilitaryShip ms = cast(MilitaryShip)ship) {
				json["type"] = "MilitaryShip";
			} else {
				json["type"] = "Inhabitation";
			}
			json.object["eneEff"] = ship.eneEff;
			json.object["sciEff"] = ship.sciEff;
			json.object["completion"] = ship.completion;
			json.object["onboard"] = ship.onboard;
			jShips ~= json;
		}
		return jShips;
	}
	/** Converts KnowledgeTree object into JSONValue **/
	static JSONValue ktToJSON(KnowledgeTree kt) {
		JSONValue jkt = JSONValue();
		jkt.type = JSON_TYPE.OBJECT;
		jkt.object["branches"] = JSONValue();
		jkt["branches"].type = JSON_TYPE.ARRAY;
		foreach(branch; kt.branches) {
			jkt["branches"].array ~= JSONValue([branch.name : branch.points]);
		}
		jkt.object["orders"] =  JSONValue();
		jkt.object["orders"].type = JSON_TYPE.ARRAY;
		foreach(order; kt.orders) {
			jkt["orders"].array ~= JSONValue(order[0]);
		}
		return jkt;
	}


}