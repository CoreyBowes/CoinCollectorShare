package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxMath;

/**
 * ...
 * @author Zaphod
 */
class PlayerShip extends FlxSprite
{
	static public var _baseThrust:Float = 90;
	public var _thrust:Float = 90;
	
	public function new()
	{
		super(Math.floor(FlxG.width / 2 - 8), Math.floor(FlxG.height / 2 - 8));
		
		#if flash
		loadRotatedGraphic("assets/images/ship.png", 32, -1, false, true);
		#else
		loadGraphic("assets/images/ship.png");
		#end
		
		width *= 0.75;
		height *= 0.75;
		centerOffsets();
	}
	
	override public function update(elapsed:Float):Void
	{
		angularVelocity = 0;
		
		if (FlxG.keys.anyPressed([A, LEFT]))
		{
			angularVelocity -= 240;
		}
		
		if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			angularVelocity += 240;
		}
		
		acceleration.set();
		
		if (FlxG.keys.anyPressed([W, UP]))
		{
			acceleration.set(_thrust, 0);
			acceleration.rotate(FlxPoint.weak(0, 0), angle);
		}
		
		super.update(elapsed);
	}
}