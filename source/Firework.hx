package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxMath;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Zaphod Beeblebrox (change this)
 */
class Firework extends FlxEmitter
{
	var _thrust:Float = 0;
    var _particleSpeed:Float = 80;
    var _leaveTrails:Bool = false;
    var _trailsDuration:Float = 0.75;
    var _trailsInterval:Float = 0.1;
    var _trailsTimer:Float = 0;
    var _parentGroup:FlxGroup = null;
    var _particleLifespan:Float = 1.5;

	public function new(X:Float = 0, Y:Float = 0, Size:Int = 0, ?leaveTrails:Bool = false, ?parentGroup:FlxGroup = null, ?trailsDuration:Float = 0.75, ?particleLifespan:Float = 1.5)
	{
        super(X, Y, Size);
        _leaveTrails = leaveTrails;
        _parentGroup = parentGroup;
        _trailsDuration = trailsDuration;
        _particleLifespan = particleLifespan;
	}

    override public function explode():Void
    {
        super.explode();
        for(p in members)
        {
            if(p.velocity.distanceTo(FlxPoint.weak(0, 0)) != 0)
            {
                var velocityScale:Float = _particleSpeed/p.velocity.distanceTo(FlxPoint.weak(0, 0));
                p.velocity.scale(velocityScale);
                p.lifespan = _particleLifespan;
            }
        }
    }

    override public function start(Explode:Bool = true, Frequency:Float = 0.1, Quantity:Int = 0):Firework
    {
        super.start(Explode, Frequency, Quantity);
        return this;
    }
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        if(_leaveTrails && (_parentGroup != null))
        {
            _trailsTimer += elapsed;
            if(_trailsTimer >= _trailsInterval)
            {
                _trailsTimer -= _trailsInterval;
                for(p in members)
                {
                    if(p.alive)
                    {
                        var afterimage:FlxSprite = FancySpriteUtil.copyFadingParticleFromSprite(p);
                        afterimage.velocity.set(0, 0);
                        FlxSpriteUtil.fadeOut(afterimage, _trailsDuration);
                        _parentGroup.add(afterimage);
                    }
                }
            }
        }
	}
}