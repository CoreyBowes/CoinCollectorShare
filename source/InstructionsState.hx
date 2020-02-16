package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class InstructionsState extends FlxState
{
	override public function create():Void
	{
		super.create();
        var instructionsString:String = "";
        instructionsString += "Move your ship using Asteroids controls. (A/D or left/right arrows to rotate, W or up arrow to use thrust.) ";
        instructionsString += "Move around and collect coins. You can convert your coins into other colorful coins, or spend them on fireworks"+
        " or upgrades. Five copper coins make a sliver, 5 sliver coins make a gold, and five gold coins make an electrum. There is no way to "+
        "die and no set objective, so play however you like.\n\n";
        instructionsString += "Controls\n";
        instructionsString += keyArrayToString(Reg._quicksaveInput)+": Quicksave the game.\n";
        instructionsString += keyArrayToString(Reg._saveGameInput)+": Save game to a save slot.\n";
        instructionsString += keyArrayToString(Reg._quickloadInput)+": Load your game.\n";
        instructionsString += keyArrayToString(Reg._condenseInput)+": Condense segments.\n";
        instructionsString += keyArrayToString(Reg._autocondenseInput)+": Turn autocondense segments on/off.\n";
        instructionsString += keyArrayToString(Reg._toggleTetherModeInput)+": Change tether mode of coins.\n";
        instructionsString += keyArrayToString(Reg._fireworkInput)+": Buy and set off a firework ($10).\n";
        instructionsString += keyArrayToString(Reg._bigFireworkInput)+": Buy and set off a big firework ($50).\n";
        instructionsString += keyArrayToString(Reg._boundSegmentsInput)+": Bound/unbound tethered coins to the game bounds.\n";
        instructionsString += keyArrayToString(Reg._exitInput)+": Exit to previous screen.\n";
        var instructionsText:FlxText = new FlxText(0, 40, FlxG.width, instructionsString, 16);
        instructionsText.alignment = CENTER;
        instructionsText.color = FlxColor.WHITE;
        add(instructionsText);
	}

    static public function getControlsString():String
    {
        var controlsString = "";
        controlsString += "Controls\n";
        controlsString += keyArrayToString(Reg._quicksaveInput)+": Quicksave the game.\n";
        controlsString += keyArrayToString(Reg._saveGameInput)+": Save game to a save slot.\n";
        controlsString += keyArrayToString(Reg._quickloadInput)+": Load your game.\n";
        controlsString += keyArrayToString(Reg._condenseInput)+": Condense segments.\n";
        controlsString += keyArrayToString(Reg._autocondenseInput)+": Turn autocondense segments on/off.\n";
        controlsString += keyArrayToString(Reg._toggleTetherModeInput)+": Change tether mode of coins.\n";
        controlsString += keyArrayToString(Reg._fireworkInput)+": Buy and set off a firework ($10).\n";
        controlsString += keyArrayToString(Reg._bigFireworkInput)+": Buy and set off a big firework ($50).\n";
        controlsString += keyArrayToString(Reg._boundSegmentsInput)+": Bound/unbound tethered coins to the game bounds.\n";
        controlsString += keyArrayToString(Reg._exitInput)+": Exit to previous screen.\n";
        return controlsString;
    }

    static public function keyArrayToString(keyArray:Array<FlxKey>)
    {
        var returnString:String = "";
        for(i in 0...keyArray.length)
        {
            returnString += keyArray[i];
            if(i < keyArray.length-1)
            {
                returnString += ", ";
            }
        }
        return returnString;
    }

    override public function update(elapsed:Float)
    {
        if(FlxG.keys.anyJustPressed(Reg._exitInput))
        {
            FlxG.switchState(new MainMenuState());
        }
        super.update(elapsed);
    }
}
