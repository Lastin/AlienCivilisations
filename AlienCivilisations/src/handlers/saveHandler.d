/**
This module implements custom save handler.
This class handles reading and saving files from the drive.
It find correct directory and creates one if it doesn't exist.

Author: Maksym Makuch
 **/

module src.handlers.saveHandler;

import std.file;
import std.format;
import std.json;
import std.path;
import std.stdio;

class SaveHandler {
	static string saveDir = "~/Documents/ACSaves/";
	/** Returns true if save file for this slot exists **/
	static bool slotUsed(int slot) {
		return exists(fullPath(slot));
	}
	/** Returns File if exists in given slot **/
	static File readSlot(int slot) {
		return File(fullPath(slot));
	}
	/** Saves JSONValue as string in the file specified by the "slot" **/
	static void saveJSON(int slot, JSONValue json) {
		string fp = fullPath(slot);
		string fullSP = expandTilde(saveDir);
		if(!exists(fullSP))
			mkdirRecurse(fullSP);
		string jsonString = json.toPrettyString();
		std.file.write(fp, jsonString);
	}
	/** Returns full path to the file in given "slot" **/
	static string fullPath(int slot) {
		return expandTilde(saveDir) ~ format("slot%s.acsave", slot);
	}
	/** Reads all the files in all the slots **/
	static File[15] readSlots() {
		File[15] files;
		for(int i=0; i<15; i++) {
			if(slotUsed(i)){
				files[i] = readSlot(i);
			}
		}
		return files;
	}
	/** Returns array of booleans, indicating if slot is currently used. True if used **/
	static bool[15] usedSlots() {
		bool[15] slotsUsed;
		for(int i=0; i<15; i++) {
			slotsUsed[i] = slotUsed(i);
		}
		return slotsUsed;
	}
	/** Deletes the file in given "slot" if it exists **/
	static void deleteSave(int slot) {
		if(slotUsed(slot))
			remove(fullPath(slot));
	}
}

