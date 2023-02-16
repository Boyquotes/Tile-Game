Tile Game
=========

About
-----
Ongoing game project made in Godot engine. Inspired by games like [Dwarf Fortress](http://www.bay12games.com/dwarves/) and [CDDA](https://cataclysmdda.org/). 

Simple Documentation
---------

--------------------------------------------

**Save system**

*Desc.* <br>
Game is designed to have one general world map (read only) and multiple save files on a given world map. This allows to only require saves to save data regarding edited state of the map. 

This system is handled via aquiring map data by first accessing save file information and if not present aquiring it from static map save.

Data is saved using [SQLite wrapper](https://github.com/2shady4u/godot-sqlite) which is handled with a chunk system (64 x 64 tiles), every chunk is loaded or saved depending on data being accessed. Chunks are compressed and saved as string in Base64. 

*Members:* <br>
- [SaveManager](https://github.com/RedouxG/Tile-Game/blob/main/Global/Singletons/SaveManager.gd) (Singleton) <br>
Loads map and save file and manages data access to save files.
- [SQLSave](https://github.com/RedouxG/Tile-Game/blob/main/Global/Classes/Custom/Save/SQLSave.gd) (Class) <br>
Manages a save file directly, handles compression, SQL query and chunk system that is used to access save data from save file (database).

--------------------------------------------

**Map Editor**

To create game maps custom map editor was created. So far it only allows for creating maps with tiles from various MapManager tile maps with fully implemented save and load system.

*Members:*
- [MapEditor](https://github.com/RedouxG/Tile-Game/tree/main/DevTools/MapEditor) (Scene) <br>
Handles everything regarding map creation. 

--------------------------------------------

**Unit Tests**

[GUT](https://github.com/bitwes/Gut) is used to test functionalities and modules of the game. All the unit tests are in [UnitTesting](https://github.com/RedouxG/Tile-Game/tree/main/DevTools/UnitTesting) folder.
