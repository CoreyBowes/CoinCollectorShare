package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;

class MainMenuState extends FlxState
{
    // Declaring variables.

	override public function create():Void
	{
        // Degugger display.
        /*
        FlxG.debugger.visible = true;
        FlxG.debugger.setLayout(MICRO);
        // FlxG.debugger.drawDebug = true;
        FlxG.log.redirectTraces = true;
        */

		super.create();
        if(!Reg._gameInitialized)
        {
            Reg.initializeGame();
            if(true)
            {
                Reg.updateSaves();
            }
        }
        var mainMenu:Menu = new Menu();
        // mainMenu.setButtonSize(100, 40);
        mainMenu.setButtonTextSize(16);
        mainMenu.addButton("Start Game", startGame);
        mainMenu.addButton("Continue Game", loadGameFromAutosave);
        mainMenu.addButton("Load Game", goToSaves);
        mainMenu.addButton("Instructions", goToInstructions);
        mainMenu.setPosition(FlxG.width/2-mainMenu.width/2, FlxG.height/2-mainMenu.height/2);
        mainMenu.arrangeButtons();

        add(mainMenu);
	}

    public function startGame()
    {
        FlxG.switchState(new PlayState());
    }

    public function loadGameFromAutosave()
    {
        Reg.loadGameFromAutosave();
    }

    public function goToInstructions()
    {
        FlxG.switchState(new InstructionsState());
    }

    public function goToOptions()
    {
        // FlxG.switchState(new LoadScreenState());
    }

    public function goToSaves()
    {
        FlxG.switchState(new LoadScreenState());
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
