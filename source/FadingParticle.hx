package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxMath;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Zaphod Beeblebrox (change this)
 */
class FadingParticle extends FlxSprite
{
	public function new()
	{
        super();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        if(alpha <= 0)
        {
            kill();
            PlayState._currentState.remove(this, true);
        }
	}
}