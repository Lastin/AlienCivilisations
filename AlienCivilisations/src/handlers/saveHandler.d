module src.handlers.saveHandler;
import std.path;
import std.file;
import std.format;
import std.json;
import std.stdio;

class SaveHandler {
	static string saveDir = "~/Documents/ACSaves/";
	/** Returns true if save file for this slot exists **/
	static bool slotUsed(int slot) {
		return exists(fullPath(slot));
	}
	/** Returns File if exists **/
	static File readSlot(int slot) {
		return File(fullPath(slot));
	}
	static void saveJSON(int slot, JSONValue json) {
		string fp = fullPath(slot);
		string fullSP = expandTilde(saveDir);
		if(!exists(fullSP))
			mkdirRecurse(fullSP);
		string jsonString = json.toPrettyString();
		std.file.write(fp, jsonString);
	}
	/** Returns full path to the file **/
	static string fullPath(int slot) {
		return expandTilde(saveDir) ~ format("slot%s.acsave", slot);
	}
	static File[15] readSlots() {
		File[15] files;
		for(int i=0; i<15; i++) {
			if(slotUsed(i)){
				files[i] = readSlot(i);
			}
		}
		return files;
	}
	static bool[15] usedSlots() {
		bool[15] slotsUsed;
		for(int i=0; i<15; i++) {
			slotsUsed[i] = slotUsed(i);
		}
		return slotsUsed;
	}
	/** Deletes the file if exists **/
	static void deleteSave(int slot) {
		if(slotUsed(slot))
			remove(fullPath(slot));
	}
}

