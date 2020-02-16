// Specifies an object for holding save data.

package;

import flixel.math.FlxPoint;
import PlayState.TetherMode;

/**
 * ...
 * @author CharType
 */
class SaveData
{
    public var _playerShipPosition:FlxPoint;
    public var _playerShipVelocity:FlxPoint;
    public var _playerShipAcceleration:FlxPoint;
    public var _playerShipAngle:Float;

    public var _currentCollectiblePosition:FlxPoint;
    public var _currentCollectiblesPositionArray:Array<FlxPoint>;
    public var _segmentsPositionArray:Array<FlxPoint>;
    public var _segmentsVelocityArray:Array<FlxPoint>;
    
    public var _saveTime:Date;
    public var _money:Int = 0;
    public var _cratesCollected:Int = 0;
    public var _initialized:Bool = false;
    public var _copperSegments:Int = 0;
    public var _silverSegments:Int = 0;
    public var _goldSegments:Int = 0;
    public var _electrumSegments:Int = 0;
    public var _magnetLevel:Int = 0;
    public var _bounceLevel:Int = 0;
    public var _maxCoins:Int = 0;
    public var _thrustLevel:Int = 0;
    public var _tetherMode:TetherMode = TetheredTwoWays;

    public function new()
    {

    }
}