package;

import flixel.math.FlxPoint;

/**
 * ...
 * @author CharType
 */
class Upgrade
{
    public var _level:Int = 0;
    public var _baseLevel = 1;
    public var _maxLevel:Int = 5;
    public var _cost:Int = 50;
    public var _baseCost:Int = 50;
    public var _costMultiplier:Float = 2;

    public function new(?level=0, ?maxLevel=5, ?baseLevel=1, ?baseCost=50, ?costMultiplier=2)
    {
        _level=level;
        _maxLevel=maxLevel;
        _baseLevel=baseLevel;
        _baseCost=baseCost;
        _costMultiplier=costMultiplier;
        if(_level<_baseLevel)
        {
            _cost = _baseCost;
        }
        else
        {
            _cost = _baseCost*Std.int(Math.pow(2, (_baseLevel-1) ));
        }
    }

    public function levelUp()
    {
        _level++;
        if(_level<_baseLevel)
        {
            _cost = _baseCost;
        }
        else
        {
            _cost = _baseCost*Std.int(Math.pow(2, (_baseLevel-1) ));
        }
    }
}