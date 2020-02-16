package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(800, 800, MainMenuState, 1, 60, 60, true));
        // addChild(new FlxGame(0, 0, MainMenuState, 1, 60, 60, true));
        // TODO: Need to re-add splash screen before release.
	}
}
