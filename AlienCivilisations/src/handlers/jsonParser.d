module src.handlers.jsonParser;

import std.json;
import std.file;
import std.stdio;
import src.entities.player;
import src.entities.knowledgeTree;
import src.entities.branch;
import src.entities.ship;
import src.entities.map;
import src.entities.planet;
import src.screens.play;
import std.conv;
import std.typecons;
import std.algorithm : sort;
import std.format;
import src.containers.gameState;
import src.containers.vector2d;

class JSONParser {
	/** Parses object Play into json structure preserving camera position and game state **/
	static JSONValue playToJSON(Play play) {
		GameState state = play.gameState;
		Vector2d camPos = play.cameraPosition;
		JSONValue save = ["game" : "AlienCivilisations"];
		save.object["date"] = __TIME__ ~ " " ~ __DATE__;
		save.object["cameraPosition"] = vecToJSON(camPos);
		save.object["gameState"] = stateToJSON(state);
		writeln(save.toPrettyString());
		return save;
	}
	/** Parses GameState object and its contents into JSON **/
	private static JSONValue stateToJSON(GameState state) {
		JSONValue jState = ["queuePosition" : state.queuePosition];
		jState.object["players"] = playersToJSON(state.players);
		jState.object["map"] = mapToJSON(state.map);
		return jState;
	}
	/** Converts Map object and its contents into JSONValue **/
	private static JSONValue mapToJSON(Map map) {
		JSONValue jMap = ["size" : map.size];
		jMap.object["planets"] = JSONValue();
		jMap["planets"].type = JSON_TYPE.ARRAY;
		foreach(planet; map.planets) {
			jMap["planets"].array ~= planetToJSON(planet);
		}
		return jMap;
	}
	/** Converts Planet object into JSONValue **/
	private static JSONValue planetToJSON(Planet planet, ) {
		JSONValue jsonPlanet = ["name" : planet.name];
		jsonPlanet.object["uniqueId"] = planet.uniqueId;
		jsonPlanet.object["position"] = vecToJSON(planet.position);
		jsonPlanet.object["radius"] = planet.radius;
		jsonPlanet.object["breathableAtmosphere"] = planet.breathableAtmosphere;
		jsonPlanet.object["ownerId"] = planet.owner ? planet.owner.uniqueId : -1;
		jsonPlanet.object["population"] = planet.population.idup;
		jsonPlanet.object["food"] = planet.food;
		jsonPlanet.object["militaryUnits"] = planet.militaryUnits;
		JSONValue[] jShipOrders = shipsToJSON(planet.shipOrders);
		foreach(i, jorder; jShipOrders) {
			jorder.object["index"] = i;
		}
		jsonPlanet.object["shipOrders"] = jShipOrders;
		return jsonPlanet;
	}
	/** Converts Vector2d object into JSONValue **/
	private static JSONValue vecToJSON(Vector2d vec) {
		return JSONValue(["x": vec.x, "y": vec.y]);
	}
	/** Converts Player object and its knowledge tree and ships into JSONValue **/
	private static JSONValue[] playersToJSON(Player[] players){
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
	private static JSONValue[] shipsToJSON(Ship[] ships) {
		JSONValue[] jShips;
		foreach(ship; ships){
			JSONValue json = ["type" : ""];
			if(MilitaryShip ms = cast(MilitaryShip)ship) {
				json["type"] = "Military";
			} else {
				json["type"] = "Inhabitation";
			}
			json.object["eneEff"] = JSONValue(ship.eneEff);
			json.object["sciEff"] = JSONValue(ship.sciEff);
			json.object["completion"] = JSONValue(ship.completion);
			json.object["onboard"] = JSONValue(ship.onboard);
			jShips ~= json;
		}
		return jShips;
	}
	/** Converts KnowledgeTree object into JSONValue **/
	private static JSONValue ktToJSON(KnowledgeTree kt) {
		JSONValue jkt = JSONValue();
		jkt.type = JSON_TYPE.OBJECT;
		jkt.object["branches"] = JSONValue();
		jkt["branches"].type = JSON_TYPE.OBJECT;
		foreach(branch; kt.branches) {
			jkt["branches"].object[branch.name] = branch.points;
		}
		jkt.object["orders"] =  JSONValue();
		jkt.object["orders"].type = JSON_TYPE.ARRAY;
		foreach(i, order; kt.orders) {
			JSONValue jorder = ["index" : i];
			jorder.object["branch"] = order[0];
			jkt["orders"].array ~= jorder;
		}
		return jkt;
	}
	/** Parses file in json format to associative array of type JSONValue **/
	static JSONValue fileToJSON(File file) {
		string fileString = readText(file.name);
		return parseJSON(fileString);
	}
	/** Parses valid json structure to GameState **/
	static GameState jsonToState(JSONValue json) {
		try {
			Player[] players;
			JSONValue[] jplayers = json["gameState"]["players"].array;
			foreach(JSONValue jplayer; jplayers){
				players ~= jsonToPlayer(jplayer);
			}
			Map map = jsonToMap(json["gameState"]["map"], players);
			int queuePosition = to!int(json["gameState"]["queuePosition"].integer);
			return new GameState(map, players, queuePosition);
		} catch(JSONException e) {
			writeln(e.toString);
		}
		return null;
	}
	/** Parses valid json structure to src.entities.Map **/
	static Map jsonToMap(JSONValue jmap, Player[] players) {
		JSONValue[] jplanets = jmap["planets"].array;
		Planet[] planets;
		foreach(jplanet; jplanets) {
			planets ~= jsonToPlanet(jplanet, players);
		}
		float size = safeFloat(jmap["size"]);
		return new Map(size, planets);
	}
	/** Parses valid json structure to Planet, adds owner if one's id was saved. Order queue is not currently sorted **/
	static Planet jsonToPlanet(JSONValue jplanet, Player[] players) {
		string name = jplanet["name"].str;
		int uniqueId = to!int(jplanet["uniqueId"].integer);
		Vector2d pos = jsonToVec(jplanet["position"]);
		float radius = safeFloat(jplanet["radius"]);
		bool ba = jplanet["breathableAtmosphere"].type == JSON_TYPE.TRUE;
		JSONValue[] jpop = jplanet["population"].array;
		uint[8] pop = [0,0,0,0,0,0,0,0];
		for(int i = 0; i<8; i++) {
			pop[i] = to!uint(jpop[i].integer);
   		}
		double food = safeFloat(jplanet["food"]);
		uint mu = to!uint(jplanet["militaryUnits"].integer);
		JSONValue[] jsonSO = jplanet["shipOrders"].array;
		Tuple!(Ship, int)[] shipOrdersIndexed;
		foreach(jship; jsonSO) {
			Ship s = jsonToShip(jship);
			int index = to!int(jship["index"].integer);
			//shipOrders ~= jsonToShip(jship);
			shipOrdersIndexed ~= tuple(s, index);
		}
		sort!("a[1] < b[1]")(shipOrdersIndexed);
		Ship[] shipOrders;
		foreach(shipOrder; shipOrdersIndexed) {
			shipOrders ~= shipOrder[0];
		}
		debug writefln("Added %s orders to planet %s", shipOrders.length, name);
		Planet planet = new Planet(uniqueId, name, pos, radius, ba, pop, food, mu, shipOrders);
		int ownerIndex = to!int(jplanet["ownerId"].integer);
		if(ownerIndex > -1) {
			planet.setOwner(Player.findPlayerWithId(ownerIndex, players));
		}
		return planet;
	}
	/** Parses valid json structure to Vector2d struct **/
	static Vector2d jsonToVec(JSONValue jvec) {
		float x = safeFloat(jvec["x"]);
		float y = safeFloat(jvec["y"]);
		return Vector2d(x, y);
	}
	/** Parses valid json structure to Player **/
	static Player jsonToPlayer(JSONValue jplayer) {
		int uniqueId = to!int(jplayer["uniqueId"].integer);
		string name = jplayer["name"].str;
		KnowledgeTree kt = jsonToKT(jplayer["knowledgeTree"]);
		Ship[] ships;
		JSONValue[] jships = jplayer["ships"].array;
		foreach(JSONValue jship; jships) {
			ships ~= jsonToShip(jship);
		}
		return new Player(uniqueId, name, kt, ships);
	}
	/** Parses valid json structure to Ship **/
	static Ship jsonToShip(JSONValue jship) {
		double eneEff = safeFloat(jship["eneEff"]);
		double sciEff = safeFloat(jship["sciEff"]);
		double completion = safeFloat(jship["completion"]);
		string type = jship["type"].str;
		if(type == "Military") {
			int onboard = to!int(jship["onboard"].integer);
			MilitaryShip ms = new MilitaryShip(eneEff, sciEff, completion);
			ms.addUnits(onboard);
			return ms;
		} else {
			return new InhabitationShip(eneEff, sciEff, completion);
		}
	}
	/** Parses valid json structure to KnowledgeTree. Orders are sorted by index **/
	static KnowledgeTree jsonToKT(JSONValue jkt) {
		uint ene = to!uint(jkt["branches"]["Energy"].integer);
		uint foo = to!uint(jkt["branches"]["Food"].integer);
		uint mil = to!uint(jkt["branches"]["Military"].integer);
		uint sci = to!uint(jkt["branches"]["Science"].integer);
		uint[4] points = [ene, foo, mil, sci];
		Tuple!(BranchName, int)[] orders;
		JSONValue[] jorders = jkt["orders"].array;
		foreach(jorder; jorders){
			BranchName branch = to!BranchName(jorder["branch"].str);
			int index = to!int(jorder["index"].integer);
			orders ~= tuple(branch, index);
		}
		sort!q{a[1] < b[1]}(orders);
		KnowledgeTree kt = new KnowledgeTree(points);
		foreach(order; orders) {
			kt.addOrder(order[0]);
		}
		return kt;
	}
	/** Ensures parsing JSONValue to floating point number, whether it was saved as integer in json
	Return 0.0 if format has been mismatched **/
	static float safeFloat(JSONValue value) {
		try {
			if(value.type == JSON_TYPE.INTEGER){
				return value.integer;
			}
			return value.floating;
		} catch (JSONException e) {
			debug writeln(e.toString);
			debug writefln("Couldn't convert float safely, type: %s", value.type);
		}
		return 0.0;
	}
}