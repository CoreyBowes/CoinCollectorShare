/*
Global information class. Contains information like what sacrifices have been made, etc.
IMPORTANT: When copying, rename the save binding string to avoid overlap.
*/
package;

import flixel.util.FlxSave;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import haxe.Serializer;
import haxe.Unserializer;
import flixel.input.keyboard.FlxKey;
// import flixel.input.actions.FlxActionInput;

/**
 * ...
 * @author CharType
 */
class Reg
{
    public static var _gravity:Float = 600; // Mostly for platformers.

    public static var _gameInitialized:Bool = false;
    public static var _gameSaves:FlxSave = null;
    public static var _autosaveShip:PlayerShip = null;
    public static var _autosaveSegments:FlxSpriteGroup = null;
    public static var _autosaveCurrentCollectible:FlxSprite = null;
    public static var _autosaveMoney:Int = 0;
    public static var _autosaveCratesCollected:Int = 0;
    public static var _autosaveCopperSegments:Int = 0;
    public static var _autosaveSilverSegments:Int = 0;
    public static var _autosaveGoldSegments:Int = 0;
    public static var _autosaveElectrumSegments:Int = 0;
    public static var _debuggingValue:Int = 0;
    public static var _loadingGame:Bool = false;
    public static var _loadingGameFromSaveSlot:Bool = false;
    public static var _saveSlotLoading:Int = 0;
    public static var _worldXBoundMin:Float = 0;
    public static var _worldXBoundMax:Float = 800;
    public static var _worldYBoundMin:Float = 0;
    public static var _worldYBoundMax:Float = 600;
    public static var _gameScaleFactor:Float = 1;

    public static var _saveSlots:Array<SaveData>;

    public static var _fireworkInput:Array<FlxKey> = [FlxKey.SPACE];
    public static var _bigFireworkInput:Array<FlxKey> = [FlxKey.F];
    public static var _boundSegmentsInput:Array<FlxKey> = [FlxKey.B];
    public static var _quicksaveInput:Array<FlxKey> = [FlxKey.Q];
    public static var _quickloadInput:Array<FlxKey> = [FlxKey.L];
    public static var _saveGameInput:Array<FlxKey> = [FlxKey.M];
    public static var _autocondenseInput:Array<FlxKey> = [FlxKey.U];
    public static var _condenseInput:Array<FlxKey> = [FlxKey.C];
    public static var _exitInput:Array<FlxKey> = [FlxKey.X, FlxKey.ESCAPE];
    public static var _toggleTetherModeInput:Array<FlxKey> = [FlxKey.T];

    /*
    Initializes all the global variables the game needs that aren't initialized elsewhere.
    */
    static public function initializeGame()
    {
        _gameSaves = new FlxSave();
        _gameSaves.bind("CharTypeGameSaves");
        if(_gameSaves.data.saveSlotsStr == null)
        {
            _saveSlots = new Array();
            _gameSaves.data.saveSlotsStr = Serializer.run(_saveSlots);
            _gameSaves.flush();
        }
        else
        {
            var saveDeserializer = new Unserializer(_gameSaves.data.saveSlotsStr);
            // saveDeserializer.setResolver(Array);
            _saveSlots = saveDeserializer.unserialize();
        }
        // Achievements.initializeAchievements();
        if(_gameSaves.data.lastTimeUpdated == null)
        {
            _gameSaves.data.lastTimeUpdated = 0.0;
        }
        if(_gameSaves.data.lastTimeUpdated < Date.now().getTime())
        {
            // Should 
            _gameSaves.data.lastTimeUpdated = Date.now().getTime();
        }
        _gameInitialized = true;
    }

    /*
    Loads game data from save into Reg's data fields. Is this necessary? Seems like we could do all this in 
    PlayState's loading function, which would mean less places to change things when loading is changed.
    Deprecated as of 6/23/19
    */
    static public function loadFromSave()
    {
        _autosaveCurrentCollectible = new Coin();
        _autosaveCurrentCollectible.x = _gameSaves.data.autosaveCurrentCollectible.x;
        _autosaveCurrentCollectible.y = _gameSaves.data.autosaveCurrentCollectible.y;

        _autosaveShip = new PlayerShip();
        _autosaveShip.x = _gameSaves.data.autosaveShip.x;
        _autosaveShip.y = _gameSaves.data.autosaveShip.y;
        _autosaveShip.angularVelocity = _gameSaves.data.autosaveShip.angularVelocity;
        _autosaveShip.angle = _gameSaves.data.autosaveShip.angle;
        _autosaveShip.velocity.x = _gameSaves.data.autosaveShip.velocity.x;
        _autosaveShip.velocity.y = _gameSaves.data.autosaveShip.velocity.y;
        _autosaveShip.acceleration.x = _gameSaves.data.autosaveShip.acceleration.x;
        _autosaveShip.acceleration.y = _gameSaves.data.autosaveShip.acceleration.y;
        
        _autosaveSegments = new FlxSpriteGroup();
        for(i in 0..._gameSaves.data.autosaveSegmentsArray.length)
        {
            var newSegment = new Coin();
            newSegment.x = _gameSaves.data.autosaveSegmentsArray[i].x;
            newSegment.y = _gameSaves.data.autosaveSegmentsArray[i].y;
            newSegment.velocity.x = _gameSaves.data.autosaveSegmentsArray[i].velocity.x;
            newSegment.velocity.y = _gameSaves.data.autosaveSegmentsArray[i].velocity.y;
            _autosaveSegments.add(newSegment);
        }

        _autosaveMoney = _gameSaves.data.autosaveMoney;
        _autosaveCratesCollected = _gameSaves.data.autosaveCratesCollected;
        _autosaveCopperSegments = _gameSaves.data.autosaveCopperSegments;
        _autosaveSilverSegments = _gameSaves.data.autosaveSilverSegments;
        _autosaveGoldSegments = _gameSaves.data.autosaveGoldSegments;
        _autosaveElectrumSegments = _gameSaves.data.autosaveElectrumSegments;
    }

    static public function loadGameFromAutosave()
    {
        _loadingGame = true;
        FlxG.switchState(new PlayState());
    }

    static public function loadGameFromSaveSlot(?slotToLoad:Int = 0)
    {
        _loadingGameFromSaveSlot = true;
        _saveSlotLoading = slotToLoad;
        FlxG.switchState(new PlayState());
    }

    /*
    TODO: Update this function to update the quicksave SaveData variable too.
    */
    static public function updateSaves()
    {
        var resavingState:PlayState = new PlayState();
        resavingState.create();
        resavingState.loadGame();
        resavingState.saveGame();
        for(i in 0..._saveSlots.length)
        {
            var updatingSave = _saveSlots[i];
            if(updatingSave != null)
            {
                resavingState = new PlayState();
                resavingState.create();
                resavingState.loadFromSaveSlot(i);
                resavingState.saveToSaveSlot(i);
            }
        }
    }
}
