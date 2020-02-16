package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

enum CoinType
{
    Copper;
    Silver;
    Gold;
    Electrum;
}

class Coin extends FlxSprite
{
	public var _thrust:Float = 0;
    public var _radius:Int = 10;
    public var _typeOfCoin:CoinType = Copper;
	
	public function new(?x:Float=0, ?y:Float=0, ?typeOfCoin:CoinType)
	{
		super(x, y);
        if(typeOfCoin == null)
        {
            _typeOfCoin = Copper;
        }
        else
        {
            _typeOfCoin = typeOfCoin;
        }
        _radius = 5;
        drawColor();
	}

    public function changeType(newType:CoinType)
    {
        _typeOfCoin = newType;
        drawColor();
    }

    public function drawColor()
    {
        makeGraphic(_radius*2, _radius*2, FlxColor.TRANSPARENT, true);
        var newColor:FlxColor = FlxColor.WHITE;
        switch(_typeOfCoin)
        {
            case Copper:
                newColor = FlxColor.BROWN;
            case Silver:
                newColor = FlxColor.GRAY;
            case Gold:
                newColor = FlxColor.YELLOW;
            case Electrum:
                newColor = FlxColor.BLUE;
        }
        FlxSpriteUtil.drawCircle(this, _radius, _radius, _radius, newColor);
    }
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}