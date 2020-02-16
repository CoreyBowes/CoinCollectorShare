package;

import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import Coin.CoinType;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxMath;

/**
 * ...
 * @author CharType
 */
class FancySpriteUtil
{
    static public function angleDifferenceFromOrigin(pointOne:FlxPoint, pointTwo:FlxPoint):Float
    {
        var angleToPointOne:Float = FlxPoint.weak(0,0).angleBetween(pointOne);
        var angleToPointTwo:Float = FlxPoint.weak(0,0).angleBetween(pointTwo);
        var angleBetween:Float = Math.abs(angleToPointTwo - angleToPointOne);
        if(angleBetween > 180)
        {
            angleBetween = 360-angleBetween;
        }
        return angleBetween;
    }

    static public function boundSpriteToGameBounds(spriteToBound:FlxSprite, bounceSprite:Bool=false, bounceMultiplier:Float=1)
    {
        var velocityMultiplier:Float = bounceMultiplier;
        if(!bounceSprite)
        {
            velocityMultiplier = 0;
        }
        if(!FlxMath.inBounds(spriteToBound.x, 0, Reg._worldXBoundMax-spriteToBound.width))
        {
            if(spriteToBound.x>Reg._worldXBoundMax-spriteToBound.width)
            {
                spriteToBound.velocity.x = Math.abs(spriteToBound.velocity.x)*velocityMultiplier*-1;
            }
            else
            {
                spriteToBound.velocity.x = Math.abs(spriteToBound.velocity.x)*velocityMultiplier;
            }
            spriteToBound.x = FlxMath.bound(spriteToBound.x, 0, Reg._worldXBoundMax-spriteToBound.width);
        }
        if(!FlxMath.inBounds(spriteToBound.y, 0, Reg._worldYBoundMax-spriteToBound.height))
        {
            if(spriteToBound.y>Reg._worldYBoundMax-spriteToBound.height)
            {
                spriteToBound.velocity.y = Math.abs(spriteToBound.velocity.y)*velocityMultiplier*-1;
            }
            else
            {
                spriteToBound.velocity.y = Math.abs(spriteToBound.velocity.y)*velocityMultiplier;
            }
            spriteToBound.y = FlxMath.bound(spriteToBound.y, 0, Reg._worldYBoundMax-spriteToBound.height);
        }
    }

    static public function copySprite(spriteToCopy:FlxSprite):FlxSprite
    {
        var returnSprite = spriteToCopy.clone();
        returnSprite.angle = spriteToCopy.angle;
        returnSprite.angularAcceleration = spriteToCopy.angularAcceleration;
        returnSprite.angularDrag = spriteToCopy.angularDrag;
        returnSprite.angularVelocity = spriteToCopy.angularVelocity;
        returnSprite.x = spriteToCopy.x;
        returnSprite.y = spriteToCopy.y;
        returnSprite.velocity.copyFrom(spriteToCopy.velocity);
        returnSprite.acceleration.copyFrom(spriteToCopy.acceleration);
        returnSprite.drag.copyFrom(spriteToCopy.drag);
        return returnSprite;
    }

    static public function copySpriteGroup(spriteGroupToCopy:FlxSpriteGroup):FlxSpriteGroup
    {
        var returnGroup = new FlxSpriteGroup();
        for(spriteToCopy in spriteGroupToCopy.members)
        {
            if(spriteToCopy != null)
            {
                returnGroup.add(copySprite(spriteToCopy));
            }
        }
        return returnGroup;
    }

    static public function copyShip(spriteToCopy:PlayerShip):PlayerShip
    {
        var returnSprite = new PlayerShip();
        returnSprite.loadGraphicFromSprite(spriteToCopy);
        returnSprite.angle = spriteToCopy.angle;
        returnSprite.angularAcceleration = spriteToCopy.angularAcceleration;
        returnSprite.angularDrag = spriteToCopy.angularDrag;
        returnSprite.angularVelocity = spriteToCopy.angularVelocity;
        returnSprite.x = spriteToCopy.x;
        returnSprite.y = spriteToCopy.y;
        returnSprite.velocity.copyFrom(spriteToCopy.velocity);
        returnSprite.acceleration.copyFrom(spriteToCopy.acceleration);
        returnSprite.drag.copyFrom(spriteToCopy.drag);
        return returnSprite;
    }

    static public function copyCoinFromSprite(spriteToCopy:FlxSprite, newCoinType:CoinType):Coin
    {
        var returnSprite:Coin = new Coin(0, 0, newCoinType);
        returnSprite.angle = spriteToCopy.angle;
        returnSprite.angularAcceleration = spriteToCopy.angularAcceleration;
        returnSprite.angularDrag = spriteToCopy.angularDrag;
        returnSprite.angularVelocity = spriteToCopy.angularVelocity;
        returnSprite.x = spriteToCopy.x;
        returnSprite.y = spriteToCopy.y;
        returnSprite.velocity.copyFrom(spriteToCopy.velocity);
        returnSprite.acceleration.copyFrom(spriteToCopy.acceleration);
        returnSprite.drag.copyFrom(spriteToCopy.drag);
        return returnSprite;
    }

    static public function copyFadingParticleFromSprite(spriteToCopy:FlxSprite):FlxSprite
    {
        var returnSprite = new FadingParticle();
        returnSprite.loadGraphicFromSprite(spriteToCopy);
        // returnSprite.makeGraphic(6, 6, FlxColor.RED);
        returnSprite.angle = spriteToCopy.angle;
        returnSprite.angularAcceleration = spriteToCopy.angularAcceleration;
        returnSprite.angularDrag = spriteToCopy.angularDrag;
        returnSprite.angularVelocity = spriteToCopy.angularVelocity;
        returnSprite.x = spriteToCopy.x;
        returnSprite.y = spriteToCopy.y;
        returnSprite.velocity.copyFrom(spriteToCopy.velocity);
        returnSprite.acceleration.copyFrom(spriteToCopy.acceleration);
        returnSprite.drag.copyFrom(spriteToCopy.drag);
        return returnSprite;
    }

    static public function normalizePoint(point:FlxPoint)
    {
        point.scale(1/point.distanceTo(FlxPoint.weak(0,0)));
    }
}
