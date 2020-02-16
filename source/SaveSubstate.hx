package;

import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;

/**
 * ...
 * @author CharType
 */
class SaveSubstate extends FlxSubState
{
    // Declaring variables.
    public var _currentPlayState:PlayState = null;
    public var _gameSaveIcons:FlxSpriteGroup = null;
    public var _loadSlotsX:Float = 0;
    public var _loadSlotsY:Float = 0;
    public var _loadSlotsWidth:Float = 0;
    public var _loadSlotsHeight:Float = 0;
    public var _loadSlotsWidthBetween:Float = 0;
    public var _loadSlotsHeightBetween:Float = 0;
    public var _numLoadSlots:Int = 0;

	override public function new():Void
	{
        super();

        // Degugger display.
        /*
        FlxG.debugger.visible = true;
        FlxG.debugger.setLayout(MICRO);
        // FlxG.debugger.drawDebug = true;
        FlxG.log.redirectTraces = true;
        */

		_gameSaveIcons = new FlxSpriteGroup();

        // var currentSaveIcon = new FlxSprite();

        _loadSlotsX = 50;
        _loadSlotsY = 50;
        _loadSlotsWidth = 200;
        _loadSlotsHeight = 100;
        _loadSlotsWidthBetween = 250;
        _loadSlotsHeightBetween = 125;
        _numLoadSlots = 9;

        

        for(i in 0..._numLoadSlots)
        {
            var currentSaveXPos = _loadSlotsX+(i%3)*_loadSlotsWidthBetween;
            var currentSaveYPos = _loadSlotsY+Math.floor(i/3)*_loadSlotsHeightBetween;
            var currentSaveDisplay = new FlxSpriteGroup();
            var currentSaveBackground = new FlxSprite(currentSaveXPos, currentSaveYPos);
            currentSaveBackground.makeGraphic(Std.int(_loadSlotsWidth), Std.int(_loadSlotsHeight), FlxColor.BLACK);
            FlxSpriteUtil.drawRect(currentSaveBackground, 0, 0, currentSaveBackground.width, currentSaveBackground.height, 
            FlxColor.TRANSPARENT, FancyDraw._whiteLine);
            var currentSaveIcon = new FlxSprite();

            _gameSaveIcons.add(currentSaveDisplay);
            currentSaveDisplay.add(currentSaveBackground);
            if(i < Reg._saveSlots.length)
            {
                if(Reg._saveSlots[i] != null)
                {
                    if(Reg._saveSlots[i]._initialized == true)
                    {
                        var textPositionX = currentSaveXPos+_loadSlotsWidth/2;
                        var textPositionY = currentSaveYPos+10;
                        var dateText = new FlxText(textPositionX, textPositionY, 0, 
                        "Saved at: \n"+Reg._saveSlots[i]._saveTime.toString(), 10);
                        dateText.color = FlxColor.WHITE;
                        currentSaveDisplay.add(dateText);
                        textPositionY += dateText.height;
                        var cratesText = new FlxText(textPositionX, textPositionY, 0, 
                        "Crates collected: "+Reg._saveSlots[i]._cratesCollected, 10);
                        cratesText.color = FlxColor.WHITE;
                        currentSaveDisplay.add(cratesText);
                        textPositionY += cratesText.height;
                        var moneyText = new FlxText(textPositionX, textPositionY, 0, 
                        "Money: "+Reg._saveSlots[i]._money, 10);
                        moneyText.color = FlxColor.WHITE;
                        currentSaveDisplay.add(moneyText);
                    }
                }
            }
        }

        add(_gameSaveIcons);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        if(FlxG.mouse.justPressed)
        {
            for(i in 0... _gameSaveIcons.length)
            {
                if(FlxG.mouse.overlaps(_gameSaveIcons.members[i]))
                {
                    _currentPlayState.saveToSaveSlot(i);
                    updateSaveSlot(i);
                }
            }
        }
        if(FlxG.keys.anyJustPressed([X, ESCAPE]))
        {
            close();
        }
	}

    public function updateSaveSlot(?slotToUpdate:Int = 0)
    {
        var currentSaveXPos = _loadSlotsX+(slotToUpdate%3)*_loadSlotsWidthBetween;
        var currentSaveYPos = _loadSlotsY+Math.floor(slotToUpdate/3)*_loadSlotsHeightBetween;
        var currentSaveDisplay = new FlxSpriteGroup();
        var currentSaveBackground = new FlxSprite(currentSaveXPos, currentSaveYPos);
        currentSaveBackground.makeGraphic(Std.int(_loadSlotsWidth), Std.int(_loadSlotsHeight), FlxColor.BLACK);
        FlxSpriteUtil.drawRect(currentSaveBackground, 0, 0, currentSaveBackground.width, currentSaveBackground.height, 
        FlxColor.TRANSPARENT, FancyDraw._whiteLine);
        var currentSaveIcon = new FlxSprite();

        currentSaveDisplay.add(currentSaveBackground);
        if(slotToUpdate < Reg._saveSlots.length)
        {
            if(Reg._saveSlots[slotToUpdate] != null)
            {
                if(Reg._saveSlots[slotToUpdate]._initialized == true)
                {
                    var textPositionX = currentSaveXPos+_loadSlotsWidth/2;
                    var textPositionY = currentSaveYPos+10;
                    var dateText = new FlxText(textPositionX, textPositionY, 0, 
                    "Saved at: \n"+Reg._saveSlots[slotToUpdate]._saveTime.toString(), 10);
                    dateText.color = FlxColor.WHITE;
                    currentSaveDisplay.add(dateText);
                    textPositionY += dateText.height;
                    var cratesText = new FlxText(textPositionX, textPositionY, 0, 
                    "Crates collected: "+Reg._saveSlots[slotToUpdate]._cratesCollected, 10);
                    cratesText.color = FlxColor.WHITE;
                    currentSaveDisplay.add(cratesText);
                    textPositionY += cratesText.height;
                    var moneyText = new FlxText(textPositionX, textPositionY, 0, 
                    "Money: "+Reg._saveSlots[slotToUpdate]._money, 10);
                    moneyText.color = FlxColor.WHITE;
                    currentSaveDisplay.add(moneyText);
                }
            }
        }
        _gameSaveIcons.members[slotToUpdate] = currentSaveDisplay;
    }
}
