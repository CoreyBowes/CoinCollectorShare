package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import Coin.CoinType;
import haxe.Serializer;
import haxe.Unserializer;
import flixel.util.helpers.FlxRangeBounds;
import FancySpriteUtil.angleDifferenceFromOrigin;
import flixel.tweens.FlxTween;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.FixedScaleAdjustSizeScaleMode;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.FixedScaleMode;

enum SpawnMode
{
    Sequential;
    Random;
}

enum TetherMode
{
    Rigid;
    TetheredOneWay;
    TetheredTwoWays;
}

class PlayState extends FlxState
{
    // Declaring variables.
    var _logTimer:Float = 0;
    var _logInterval:Float = 1;
    var _segments:FlxSpriteGroup;
    var _currentCollectible:FlxSprite;
    var _currentCollectiblesGroup:FlxSpriteGroup;
    var _ship:PlayerShip;
    var _myRand:FlxRandom;
    var _money:Int = 0;
    var _cratesCollected:Int = 0;
    var _moneyText:FlxText;
    var _cratesText:FlxText;
    var _boundSegments:Bool = true;
    var _firstSellPress:Bool = true;
    var _sellPressCounter:Float = 0;
    var _autocondense:Bool = false;
    var _copperSegments:Int = 0;
    var _silverSegments:Int = 0;
    var _goldSegments:Int = 0;
    var _electrumSegments:Int = 0;
    var _minCopperSegments:Int = 0;
    var _minSilverSegments:Int = 0;
    var _minGoldSegments:Int = 0;
    var _minElectrumSegments:Int = 0;
    var _guiYPos:Float = 600;

    var _thrustUpgrade:Upgrade;
    var _bounceUpgrade:Upgrade;
    var _magnetUpgrade:Upgrade;
    var _maxCoinsUpgrade:Upgrade;

    // var _magnetUpgrade._level:Int = 0;
    // var _thrustUpgrade._level:Int = 0;
    // var _bounceUpgrade._level:Int = 0;
    // var _maxCoinsUpgrade._level:Int = 1;
    // var _magnetUpgrade._maxLevel:Int = 5;
    // var _thrustUpgrade._maxLevel:Int = 5;
    // var _bounceUpgrade._maxLevel:Int = 5;
    // var _maxCoinsUpgrade._maxLevel:Int = 3;
    // var _thrustUpgrade._baseCost:Int = 50;
    // var _bounceUpgrade._baseCost:Int = 50;
    // var _maxCoinsUpgrade._baseCost:Int = 50;
    // var _magnetUpgrade._baseCost:Int = 50;
    // var _thrustUpgrade._cost:Int = 50;
    // var _bounceUpgrade._cost:Int = 50;
    // var _maxCoinsUpgrade._cost:Int = 50;
    // var _magnetUpgrade._cost:Int = 50;
    var _upgradeThrustButton:FancyButton = null;
    var _upgradeBounceButton:FancyButton = null;
    var _upgradeMaxCoinsButton:FancyButton = null;
    var _upgradeMagnetButton:FancyButton = null;
    var _upgradeThrustText:FlxText = null;
    var _upgradeBounceText:FlxText = null;
    var _upgradeMaxCoinsText:FlxText = null;
    var _upgradeMagnetText:FlxText = null;
    var _coinSpawnMode:SpawnMode = Random;
    var _tetherLength:Float = 25;
    var _coinTetherMode:TetherMode = TetheredTwoWays;

    public static var _currentState:PlayState = null;

    public function addFadingMessage(msg:String)
    {
        var fadingMessage = new FlxText((Reg._worldXBoundMin+Reg._worldXBoundMax/2), _guiYPos, 0, msg, 12);
        fadingMessage.color = FlxColor.WHITE;
        FlxSpriteUtil.fadeOut(fadingMessage, 3);
        // fadingMessage.velocity.y = -200;
        FlxTween.tween(fadingMessage, {y:fadingMessage.y-60}, 3);
        add(fadingMessage);
    }

    public function addMoney(moneyToAdd:Int)
    {
        _money += moneyToAdd;
        _moneyText.text = "Money: $"+_money;
    }

    public function addCrates(cratesToAdd:Int)
    {
        _cratesCollected += cratesToAdd;
        _cratesText.text = "Crates collected: "+_cratesCollected;
    }

    public function bringWithinRadius(tetheringSprite:FlxSprite, tetheredSprite:FlxSprite, radius:Float)
    {
            var vectorToTetheringSprite = new FlxPoint();
            vectorToTetheringSprite.copyFrom(tetheringSprite.getPosition());
            vectorToTetheringSprite.subtractPoint(tetheredSprite.getPosition());
            var distanceToTetheringSegment:Float = vectorToTetheringSprite.distanceTo(FlxPoint.weak(0, 0));
            if(distanceToTetheringSegment > radius)
            {
                var correctionVector:FlxPoint = new FlxPoint();
                correctionVector.copyFrom(vectorToTetheringSprite);
                correctionVector.scale((distanceToTetheringSegment-radius)/distanceToTetheringSegment);
                var currentPosition:FlxPoint = tetheredSprite.getPosition();
                currentPosition.addPoint(correctionVector);
                tetheredSprite.setPosition(currentPosition.x, currentPosition.y); // Set position of segment to be within tether range. This should work, it always has before.
            }
    }

    public function buyFirework()
    {
        if(_copperSegments >= 1)
        {
            _segments.remove(_segments.members[_segments.length-1], true);
            addMoney(-10);
            _copperSegments--;
            makeFirework();
        }
        else if(_silverSegments >= 1)
        {
            var segmentRemoved = _segments.remove(_segments.members[_segments.length-1], true);
            addMoney(-10);
            _silverSegments--;
            _copperSegments += 4;
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Copper));
            }
            makeFirework();
        }
        else if(_goldSegments >= 1)
        {
            var segmentRemoved = _segments.remove(_segments.members[_segments.length-1], true);
            addMoney(-10);
            _goldSegments--;
            _silverSegments += 4;
            _copperSegments += 4;
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Silver));
            }
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Copper));
            }
            makeFirework();
        }
        else if(_electrumSegments >= 1)
        {
            var segmentRemoved = _segments.remove(_segments.members[_segments.length-1], true);
            addMoney(-10);
            _electrumSegments--;
            _goldSegments += 4;
            _silverSegments += 4;
            _copperSegments += 4;
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Gold));
            }
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Silver));
            }
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Copper));
            }
            makeFirework();
        }
    }

    public function buyLargeFirework()
    {
        if(_silverSegments >= 1)
        {
            var segmentRemoved = _segments.remove(_segments.members[_segments.length-1-_copperSegments], true);
            addMoney(-50);
            _silverSegments--;
            makeLargeFirework();
        }
        else if(_goldSegments >= 1)
        {
            var segmentRemoved = _segments.remove(_segments.members[_segments.length-1-_copperSegments], true);
            addMoney(-50);
            _goldSegments--;
            _silverSegments += 4;
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Silver));
            }
            makeLargeFirework();
        }
        else if(_electrumSegments >= 1)
        {
            var segmentRemoved = _segments.remove(_segments.members[_segments.length-1-_copperSegments], true);
            addMoney(-50);
            _electrumSegments--;
            _goldSegments += 4;
            _silverSegments += 4;
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Gold));
            }
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Silver));
            }
            makeLargeFirework();
        }
    }

    // Deprecated. collectItemInGroup now used.
    public function collectItem(ship:FlxSprite, item:FlxSprite)
    {
        remove(_currentCollectible);
        if(_segments.length <= 0)
        {
            bringWithinRadius(_ship, _currentCollectible, _tetherLength);
        }
        else
        {
            bringWithinRadius(_segments.members[_segments.length-1], _currentCollectible, _tetherLength);
            _currentCollectible.velocity.copyFrom(_segments.members[_segments.length-1].velocity); // Sets the velocity equal to the last segment, so the new segment doesn't suddenly jerk on the line.
        }
        _segments.add(_currentCollectible);
        _currentCollectible = new Coin();
        _currentCollectible.setPosition(150+(_cratesCollected%11)*50, 150+(50*Math.ffloor(_cratesCollected/11))%7);
        add(_currentCollectible);
        addMoney(10);
        addCrates(1);
        _copperSegments++;
    }

    public function collectItemInGroup(ship:FlxSprite, item:FlxSprite)
    {
        _currentCollectiblesGroup.remove(item, true);
        if(_segments.length <= 0)
        {
            bringWithinRadius(_ship, item, _tetherLength);
        }
        else
        {
            bringWithinRadius(_segments.members[_segments.length-1], item, _tetherLength);
            item.velocity.copyFrom(_segments.members[_segments.length-1].velocity); // Sets the velocity equal to the last segment, so the new segment doesn't suddenly jerk on the line.
        }
        spawnCoins();
        addMoney(10);
        addCrates(1);
        _copperSegments++;
        _segments.add(item);
    }

    public function condenseSegments()
    {
        if(_copperSegments >= 5)
        {
            for(i in 0...5)
            {
                _segments.remove(_segments.members[_segments.length-1], true);
            }
            var insertIndex:Int = _electrumSegments+_goldSegments+_silverSegments;
            if(insertIndex > 0)
            {
                _segments.insert(insertIndex, new Coin(_segments.members[insertIndex-1].x, _segments.members[insertIndex-1].y, Silver));
            }
            else
            {
                _segments.insert(insertIndex, new Coin(0, 0, Silver));
            }
            _copperSegments -= 5;
            _silverSegments++;
        }
        else if(_silverSegments >= 5)
        {
            for(i in 0...5)
            {
                _segments.remove(_segments.members[_electrumSegments+_goldSegments], true);
            }
            var insertIndex:Int = _electrumSegments+_goldSegments;
            if(insertIndex > 0)
            {
                _segments.insert(insertIndex, new Coin(_segments.members[insertIndex-1].x, _segments.members[insertIndex-1].y, Gold));
            }
            else
            {
                _segments.insert(insertIndex, new Coin(0, 0, Gold));
            }
            _silverSegments -= 5;
            _goldSegments++;
        }
        else if(_goldSegments >= 5)
        {
            for(i in 0...5)
            {
                _segments.remove(_segments.members[_electrumSegments], true);
            }
            var insertIndex:Int = _electrumSegments;
            if(insertIndex > 0)
            {
                _segments.insert(insertIndex, new Coin(_segments.members[insertIndex-1].x, _segments.members[insertIndex-1].y, Electrum));
            }
            else
            {
                _segments.insert(insertIndex, new Coin(0, 0, Electrum));
            }
            _goldSegments -= 5;
            _electrumSegments++;
        }
    }

	override public function create():Void
	{
        // Degugger display.
        /*
        FlxG.debugger.visible = true;
        FlxG.debugger.setLayout(MICRO);
        // FlxG.debugger.drawDebug = true;
        FlxG.log.redirectTraces = true;
        */

        // #region Region example
        // #endregion

		super.create();

        /* Whenever I set the xml window size different than 640x480 the game runs slowly, currently. Using this code with the 
        cameras doesn't help. */
        // FlxG.scaleMode = new FixedScaleAdjustSizeScaleMode();
        // FlxG.camera.setScale(1, 1);
        // FlxG.cameras.reset();

        if(!Reg._gameInitialized)
        {
            Reg.initializeGame();
        }
        _currentState = this;

        // Initializing variables.
        _myRand = new FlxRandom();
        _segments = new FlxSpriteGroup();
        _currentCollectiblesGroup = new FlxSpriteGroup();
        _currentCollectible = null;
        _ship = new PlayerShip();
        _money = 0;
        _cratesCollected = 0;

        _thrustUpgrade = new Upgrade();
        _bounceUpgrade = new Upgrade();
        _maxCoinsUpgrade = new Upgrade(1, 3, 1);
        _magnetUpgrade = new Upgrade();

        _upgradeThrustButton = new FancyButton(20, _guiYPos+20, "Upgrade Thrust ("+_thrustUpgrade._cost+")", upgradeThrust, -1, 12);
        _upgradeBounceButton = new FancyButton(220, _guiYPos+20, "Upgrade Bounce ("+_bounceUpgrade._cost+")", upgradeBounce, -1, 12);
        _upgradeMaxCoinsButton = new FancyButton(420, _guiYPos+20, "Upgrade Max Coins ("+_maxCoinsUpgrade._cost+")", upgradeMaxCoins, -1, 12);
        _upgradeMagnetButton = new FancyButton(620, _guiYPos+20, "Upgrade Magnet ("+_magnetUpgrade._cost+")", upgradeMagnet, -1, 12);

        _upgradeThrustText = new FlxText(20, _guiYPos+60, 0, "Thrust lvl "+_thrustUpgrade._level+"/"+_thrustUpgrade._maxLevel, 16);
        _upgradeThrustText.color = FlxColor.WHITE;
        _upgradeBounceText = new FlxText(220, _guiYPos+60, 0, "Bounce lvl "+_bounceUpgrade._level+"/"+_bounceUpgrade._maxLevel, 16);
        _upgradeBounceText.color = FlxColor.WHITE;
        _upgradeMaxCoinsText = new FlxText(420, _guiYPos+60, 0, "Max Coins lvl "+_maxCoinsUpgrade._level+"/"+_maxCoinsUpgrade._maxLevel, 16);
        _upgradeMaxCoinsText.color = FlxColor.WHITE;
        _upgradeMagnetText = new FlxText(620, _guiYPos+60, 0, "Magnet lvl "+_magnetUpgrade._level+"/"+_magnetUpgrade._maxLevel, 16);
        _upgradeMagnetText.color = FlxColor.WHITE;

        _moneyText = new FlxText(0, 0, FlxG.width, "Money: $"+_money, 16);
        _moneyText.color = FlxColor.WHITE;
        _cratesText = new FlxText(0, 0, FlxG.width, "Crates collected: "+_cratesCollected, 16);
        _cratesText.color = FlxColor.WHITE;
        _cratesText.alignment = RIGHT;

        //_currentCollectible.setPosition(150, 150);
        spawnCoins();

        add(_segments);
        // add(_currentCollectible);
        add(_currentCollectiblesGroup);
        add(_ship);
        add(_moneyText);
        add(_cratesText);
        add(_upgradeThrustButton);
        add(_upgradeBounceButton);
        add(_upgradeMaxCoinsButton);
        add(_upgradeMagnetButton);
        add(_upgradeThrustText);
        add(_upgradeBounceText);
        add(_upgradeMaxCoinsText);
        add(_upgradeMagnetText);
	}

    public function getSpendableMoney():Int
    {
        return _money;
    }

    public function loadFromSaveSlot(saveGameIndex:Int=0)
    {
        loadGameFromSaveData(Reg._saveSlots[saveGameIndex]);
    }

    /*
    Quickloads the game from a SaveData variable in the saving variable in Reg. See the SaveData class for a full list of 
    what fields are saved.
    */
    public function loadGame()
    {
        if(Reg._gameSaves.data.quicksaveStr != null)
        {
            var quicksaveData:SaveData = Unserializer.run(Reg._gameSaves.data.quicksaveStr);
            loadGameFromSaveData(quicksaveData);
        }
    }

    // Loads a game from a SaveData object. Not currently implemented.
    public function loadGameFromSaveData(saveDataToLoad:SaveData)
    {
        clear();

        create();
        remove(_segments);
        remove(_currentCollectible);
        remove(_currentCollectiblesGroup);
        remove(_ship);
        remove(_moneyText);
        remove(_cratesText);

        // Re-initializing variables.
        _myRand = new FlxRandom();
        _segments = new FlxSpriteGroup();
        _currentCollectiblesGroup = new FlxSpriteGroup();

        _ship = new PlayerShip();
        _ship.x = saveDataToLoad._playerShipPosition.x;
        _ship.y = saveDataToLoad._playerShipPosition.y;
        _ship.angle = saveDataToLoad._playerShipAngle;
        _ship.velocity.x = saveDataToLoad._playerShipVelocity.x;
        _ship.velocity.y = saveDataToLoad._playerShipVelocity.y;
        
        if(saveDataToLoad._currentCollectiblePosition != null)
        {
            _currentCollectible = new Coin();
            _currentCollectible.x = saveDataToLoad._currentCollectiblePosition.x;
            _currentCollectible.y = saveDataToLoad._currentCollectiblePosition.y;
        }
        else
        {
            _currentCollectible = null;
        }

        _money = saveDataToLoad._money;
        _cratesCollected = saveDataToLoad._cratesCollected;
        _copperSegments = saveDataToLoad._copperSegments;
        _silverSegments = saveDataToLoad._silverSegments;
        _goldSegments = saveDataToLoad._goldSegments;
        _electrumSegments = saveDataToLoad._electrumSegments;
        _coinTetherMode = saveDataToLoad._tetherMode;

        for(i in 0...saveDataToLoad._segmentsPositionArray.length)
        {
            var currentSegmentType:CoinType = Copper;
            if(_electrumSegments > i)
            {
                currentSegmentType = Electrum;
            }
            else if(_electrumSegments+_goldSegments > i)
            {
                currentSegmentType = Gold;
            }
            else if(_electrumSegments+_goldSegments+_silverSegments > i)
            {
                currentSegmentType = Silver;
            }
            else
            {
                currentSegmentType = Copper;
            }
            var newSegment = new Coin(saveDataToLoad._segmentsPositionArray[i].x,
            saveDataToLoad._segmentsPositionArray[i].y, currentSegmentType);
            newSegment.velocity.x = saveDataToLoad._segmentsVelocityArray[i].x;
            newSegment.velocity.y = saveDataToLoad._segmentsVelocityArray[i].y;
            _segments.add(newSegment);
        }
        for(i in 0...saveDataToLoad._currentCollectiblesPositionArray.length)
        {
            var collectibleToAdd = new Coin();
            collectibleToAdd.setPosition(saveDataToLoad._currentCollectiblesPositionArray[i].x, 
            saveDataToLoad._currentCollectiblesPositionArray[i].y);
            _currentCollectiblesGroup.add(collectibleToAdd);
        }

        _moneyText = new FlxText(0, 0, FlxG.width, "Money: $"+_money, 16);
        _moneyText.color = FlxColor.WHITE;
        _cratesText = new FlxText(0, 0, FlxG.width, "Crates collected: "+_cratesCollected, 16);
        _cratesText.color = FlxColor.WHITE;
        _cratesText.alignment = RIGHT;

        add(_segments);
        if(_currentCollectible != null)
        {
            add(_currentCollectible);
        }
        add(_ship);
        add(_moneyText);
        add(_cratesText);
    }

    private function logOnTimer(message:String)
    {
        if(_logTimer>_logInterval)
        {
            trace(message);
        }
    }

    public function makeFirework()
    {
        var numFireworkParticles:Int = 25;
        var boughtFirework = new Firework(_ship.getMidpoint().x, _ship.getMidpoint().y, numFireworkParticles, true, this);
        // boughtFirework.speed = new FlxRangeBounds(80, 80, 80, 80);
        // boughtFirework.makeParticles(4, 4, FlxColor.GREEN, 50);
        var particleColors:Array<FlxColor> = new Array();
        particleColors = FlxColor.gradient(FlxColor.ORANGE, FlxColor.YELLOW, numFireworkParticles);
        for(i in 0...numFireworkParticles)
        {
            var p = new FlxParticle();
            // p.makeGraphic(4, 4, particleColors[i]);
            p.makeGraphic(6, 6, FlxColor.fromHSL(60+120*i/numFireworkParticles, 0.9, 0.6), true);
            boughtFirework.add(p);
        }
        add(boughtFirework);
        boughtFirework.start(true, 0, numFireworkParticles);
    }

    public function makeLargeFirework()
    {
        var numFireworkParticles:Int = 40;
        var boughtFirework = new Firework(_ship.getMidpoint().x, _ship.getMidpoint().y, numFireworkParticles, true, this, 1.5, 3.0);
        // boughtFirework.speed = new FlxRangeBounds(80, 80, 80, 80);
        // boughtFirework.makeParticles(4, 4, FlxColor.GREEN, 50);
        var particleColors:Array<FlxColor> = new Array();
        particleColors = FlxColor.gradient(FlxColor.ORANGE, FlxColor.YELLOW, numFireworkParticles);
        for(i in 0...numFireworkParticles)
        {
            var p = new FlxParticle();
            // p.makeGraphic(4, 4, particleColors[i]);
            p.makeGraphic(8, 8, FlxColor.fromHSL(60+120*i/numFireworkParticles, 0.9, 0.6), true);
            boughtFirework.add(p);
        }
        add(boughtFirework);
        boughtFirework.start(true, 0, numFireworkParticles);
    }

    /*
    Quicksaves the game to a SaveData variable in the saving variable in Reg. See the SaveData class for a full list of 
    what fields are saved.
    */
    public function saveGame()
    {
        var quicksaveData = new SaveData();
        saveGameToSaveData(quicksaveData);
        Reg._gameSaves.data.quicksaveStr = Serializer.run(quicksaveData);
        Reg._gameSaves.flush();
    }

    // Saves a game to a SaveData object. Not currently implemented.
    public function saveGameToSaveData(saveDataToSave:SaveData)
    {
        saveDataToSave._initialized = true;
        saveDataToSave._playerShipPosition = new FlxPoint();
        saveDataToSave._playerShipPosition.copyFrom(_ship.getPosition());
        saveDataToSave._playerShipVelocity = new FlxPoint();
        saveDataToSave._playerShipVelocity.copyFrom(_ship.velocity);
        saveDataToSave._playerShipAngle = _ship.angle;
        saveDataToSave._currentCollectiblePosition = new FlxPoint();
        if(_currentCollectible != null)
        {
            saveDataToSave._currentCollectiblePosition.copyFrom(_currentCollectible.getPosition());
        }
        saveDataToSave._segmentsPositionArray = new Array();
        saveDataToSave._segmentsVelocityArray = new Array();
        saveDataToSave._currentCollectiblesPositionArray = new Array();
        for(savingSegment in _segments.members)
        {
            var savePosition = new FlxPoint();
            savePosition.copyFrom(savingSegment.getPosition());
            saveDataToSave._segmentsPositionArray.push(savePosition);
            var saveVelocity = new FlxPoint();
            saveVelocity.copyFrom(savingSegment.velocity);
            saveDataToSave._segmentsVelocityArray.push(saveVelocity);
        }
        for(savingCollectible in _currentCollectiblesGroup.members)
        {
            var savePosition = new FlxPoint();
            savePosition.copyFrom(savingCollectible.getPosition());
            saveDataToSave._currentCollectiblesPositionArray.push(savePosition);
        }
        saveDataToSave._copperSegments = _copperSegments;
        saveDataToSave._silverSegments = _silverSegments;
        saveDataToSave._goldSegments = _goldSegments;
        saveDataToSave._electrumSegments = _electrumSegments;
        saveDataToSave._saveTime = Date.now();
        saveDataToSave._cratesCollected = _cratesCollected;
        saveDataToSave._money = _money;
        saveDataToSave._tetherMode = _coinTetherMode;
    }

    public function saveToSaveSlot(saveGameIndex:Int=0)
    {
        /*
        Why did I have an if statement that runs only if saveGameIndex is less than the number
        of save slots, then inside it have a for statement that only runs if saveGameIndex is 
        greater? I must have made a mistake, let's fix that.
        */
        // if(Reg._saveSlots.length > saveGameIndex)
        if(true)
        {
            for(i in Reg._saveSlots.length...(saveGameIndex+1))
            {
                Reg._saveSlots.push(new SaveData());
            }

            Reg._saveSlots[saveGameIndex] = new SaveData();
            saveGameToSaveData(Reg._saveSlots[saveGameIndex]);
            Reg._gameSaves.data.saveSlotsStr = Serializer.run(Reg._saveSlots);
            Reg._gameSaves.flush();
        }
        else
        {
            trace("Error: Reg saveslots not long enough.");
        }
    }

    public function setThrust(thrustLevel:Int)
    {
        _thrustUpgrade._level = thrustLevel;
        _ship._thrust = PlayerShip._baseThrust + (_thrustUpgrade._level - 1)*20;
    }

    // Spends a copper coin and removes money equal to its' value.
    public function spendCopper()
    {
        if(_copperSegments >= 1)
        {
            _segments.remove(_segments.members[_segments.length-1], true);
            addMoney(-10);
            _copperSegments--;
        }
        else if(_silverSegments >= 1)
        {
            var segmentRemoved = _segments.remove(_segments.members[_segments.length-1], true);
            addMoney(-10);
            _silverSegments--;
            _copperSegments += 4;
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Copper));
            }
        }
        else if(_goldSegments >= 1)
        {
            var segmentRemoved = _segments.remove(_segments.members[_segments.length-1], true);
            addMoney(-10);
            _goldSegments--;
            _silverSegments += 4;
            _copperSegments += 4;
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Silver));
            }
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Copper));
            }
        }
        else if(_electrumSegments >= 1)
        {
            var segmentRemoved = _segments.remove(_segments.members[_segments.length-1], true);
            addMoney(-10);
            _electrumSegments--;
            _goldSegments += 4;
            _silverSegments += 4;
            _copperSegments += 4;
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Gold));
            }
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Silver));
            }
            for(i in 0...4)
            {
                _segments.add(new Coin(segmentRemoved.x, segmentRemoved.y, Copper));
            }
        }
    }

    public function spendMoney(moneyToSpend:Int)
    {
        // addMoney(-1*moneyToSpend);
        for(i in 0...Std.int(moneyToSpend/10))
        {
            spendCopper();
        }
    }
    
    public function spawnCoins()
    {
        while(_currentCollectiblesGroup.length < _maxCoinsUpgrade._level)
        {
            var collectibleToAdd = new Coin();
            switch(_coinSpawnMode)
            {
                case Sequential:
                    collectibleToAdd.setPosition(150+((_cratesCollected+_currentCollectiblesGroup.length)%11)*50, 
                    150+(50*Math.ffloor((_cratesCollected+_currentCollectiblesGroup.length)/11))%7);
                case Random:
                    collectibleToAdd.setPosition(150+(_myRand.int(0, 10)*50), 
                    150+50*_myRand.int(0, 6));
                default:
                    collectibleToAdd.setPosition(150+((_cratesCollected+_currentCollectiblesGroup.length)%11)*50, 
                    150+(50*Math.ffloor((_cratesCollected+_currentCollectiblesGroup.length)/11))%7);
            }
            _currentCollectiblesGroup.add(collectibleToAdd);
        }
    }

    // Changes the velocity of the segments so that they stay within a certain distance of the previous one, as though tethered.
    public function tetherSegments(?elapsed:Float=1/60)
    {
        // Let's make it simple for now.
        var lastSegmentPosition:FlxPoint = _ship.getPosition();
        var lastSegmentVelocity:FlxPoint = _ship.velocity;
        var vectorToLastSegment:FlxPoint = new FlxPoint();

        var firstSegment:Bool = true;

        var lastSegment:FlxSprite = _ship;
        var lastSegmentProjectedPosition:FlxPoint = new FlxPoint();
        lastSegmentProjectedPosition.copyFrom(_ship.getPosition());
        var lastSegmentProjectedChange:FlxPoint = new FlxPoint();
        lastSegmentProjectedChange.copyFrom(_ship.velocity);
        lastSegmentProjectedChange.scale(elapsed);
        for(currentSegment in _segments)
        {
            vectorToLastSegment.copyFrom(lastSegmentPosition);
            vectorToLastSegment.subtractPoint(currentSegment.getPosition());
            var distanceToLast:Float = currentSegment.getPosition().distanceTo(lastSegmentPosition);
            var maxDistance:Float = 25;
            var tetherError:Float = 0;

            var projectedPosition = new FlxPoint();
            projectedPosition.copyFrom(currentSegment.getPosition());
            var projectedChange = new FlxPoint();
            projectedChange.copyFrom(currentSegment.velocity);
            projectedChange.scale(elapsed);
            projectedPosition.addPoint(projectedChange);

            var projectedVectorToLastSegment = new FlxPoint();
            projectedVectorToLastSegment.copyFrom(lastSegmentProjectedPosition);
            projectedVectorToLastSegment.subtractPoint(projectedPosition);
            var projectedDistanceToLast:Float = projectedVectorToLastSegment.distanceTo(FlxPoint.weak(0, 0));
            if(_coinTetherMode == TetheredOneWay)
            {
                if(projectedDistanceToLast > maxDistance+tetherError)
                {
                    var projectionCorrectionVector:FlxPoint = new FlxPoint();
                    projectionCorrectionVector.copyFrom(projectedVectorToLastSegment);
                    projectionCorrectionVector.scale((projectedDistanceToLast-maxDistance)/projectedDistanceToLast);
                    var newPosition:FlxPoint = new FlxPoint();
                    newPosition.copyFrom(projectedPosition);
                    newPosition.addPoint(projectionCorrectionVector);
                    var positionChange = new FlxPoint();
                    positionChange.copyFrom(newPosition);
                    positionChange.subtractPoint(projectedPosition);
                    var velocityChange = new FlxPoint();
                    velocityChange.copyFrom(positionChange);
                    velocityChange.scale(1/elapsed);
                    currentSegment.velocity.addPoint(velocityChange);
                }
            }
            else if(_coinTetherMode == TetheredTwoWays)
            {
                if(firstSegment)
                {
                    // If we're on the first segment (tethered by ship), treat it the same as tethered one way.
                    if(projectedDistanceToLast > maxDistance+tetherError)
                    {
                        var projectionCorrectionVector:FlxPoint = new FlxPoint();
                        projectionCorrectionVector.copyFrom(projectedVectorToLastSegment);
                        projectionCorrectionVector.scale((projectedDistanceToLast-maxDistance)/projectedDistanceToLast);
                        var newPosition:FlxPoint = new FlxPoint();
                        newPosition.copyFrom(projectedPosition);
                        newPosition.addPoint(projectionCorrectionVector);
                        var positionChange = new FlxPoint();
                        positionChange.copyFrom(newPosition);
                        positionChange.subtractPoint(projectedPosition);
                        var velocityChange = new FlxPoint();
                        velocityChange.copyFrom(positionChange);
                        velocityChange.scale(1/elapsed);
                        currentSegment.velocity.addPoint(velocityChange);
                    }
                    firstSegment = false;
                }
                else
                {
                    if(projectedDistanceToLast > maxDistance+tetherError)
                    {
                        var projectionCorrectionVector:FlxPoint = new FlxPoint();
                        projectionCorrectionVector.copyFrom(projectedVectorToLastSegment);
                        projectionCorrectionVector.scale((projectedDistanceToLast-maxDistance)/projectedDistanceToLast);
                        var newPosition:FlxPoint = new FlxPoint();
                        newPosition.copyFrom(projectedPosition);
                        newPosition.addPoint(projectionCorrectionVector);
                        var positionChange = new FlxPoint();
                        positionChange.copyFrom(newPosition);
                        positionChange.subtractPoint(projectedPosition);
                        var velocityChange = new FlxPoint();
                        velocityChange.copyFrom(positionChange);
                        velocityChange.scale(1/elapsed);
                        velocityChange.scale(.5);
                        currentSegment.velocity.addPoint(velocityChange);
                        velocityChange.rotate(FlxPoint.weak(0, 0), 180);
                        lastSegment.velocity.addPoint(velocityChange);
                    }
                }
            }
            else
            {
                if(distanceToLast > maxDistance+tetherError)
                {
                    var correctionVector:FlxPoint = new FlxPoint();
                    correctionVector.copyFrom(vectorToLastSegment);
                    correctionVector.scale((distanceToLast-maxDistance)/distanceToLast);
                    var currentPosition:FlxPoint = currentSegment.getPosition();
                    currentPosition.addPoint(correctionVector);
                    currentSegment.setPosition(currentPosition.x, currentPosition.y); // Set position of segment to be within tether range. This should work, it always has before.

                    correctionVector.scale(elapsed);
                    // currentSegment.velocity.addPoint(correctionVector); // Adjusts the velocity by simply adding the position correction times the change in time. Only really works when tether error is 0.
                    // currentSegment.velocity.addPoint(tetherPull); // This should always be a lesser change than the old system, so this should work.
                    currentSegment.velocity.copyFrom(lastSegmentVelocity); // Simply transfers the momentum of the last segment to the current segment. This should work, it always has before.
                }
            }
            lastSegment = currentSegment;
            lastSegmentPosition = currentSegment.getPosition();
            lastSegmentVelocity = currentSegment.velocity;
            lastSegmentProjectedPosition.copyFrom(currentSegment.getPosition());
            lastSegmentProjectedChange.copyFrom(currentSegment.velocity);
            lastSegmentProjectedChange.scale(elapsed);
            lastSegmentProjectedPosition.addPoint(lastSegmentProjectedChange);
        }
    }

    public function tetherSegmentsPositionOnly()
    {
        var lastSegmentPosition:FlxPoint = _ship.getPosition();
        var lastSegmentVelocity:FlxPoint = _ship.velocity;
        var vectorToLastSegment:FlxPoint = new FlxPoint();

        for(currentSegment in _segments)
        {
            vectorToLastSegment.copyFrom(lastSegmentPosition);
            vectorToLastSegment.subtractPoint(currentSegment.getPosition());
            var distanceToLast:Float = currentSegment.getPosition().distanceTo(lastSegmentPosition);
            var maxDistance:Float = 25;
            var tetherError:Float = 0;
            if(distanceToLast > maxDistance+tetherError)
            {
                var correctionVector:FlxPoint = new FlxPoint();
                correctionVector.copyFrom(vectorToLastSegment);
                correctionVector.scale((distanceToLast-maxDistance)/distanceToLast);
                var currentPosition:FlxPoint = new FlxPoint();
                currentPosition.copyFrom(currentSegment.getPosition());
                currentPosition.addPoint(correctionVector);
                currentSegment.setPosition(currentPosition.x, currentPosition.y); // Set position of segment to be within tether range. This should work, it always has before.

                // currentSegment.velocity.addPoint(correctionVector); // Adjusts the velocity by simply adding the position correction times the change in time. Only really works when tether error is 0.
                // currentSegment.velocity.addPoint(tetherPull); // This should always be a lesser change than the old system, so this should work.
                // currentSegment.velocity.copyFrom(lastSegmentVelocity); // Simply transfers the momentum of the last segment to the current segment. This should work, it always has before.
            }
            lastSegmentPosition = currentSegment.getPosition();
            lastSegmentVelocity = currentSegment.velocity;
        }
    }

	override public function update(elapsed:Float):Void
	{
        _logTimer += elapsed;

        tetherSegments(elapsed);
        var pickupRadius:Float = 25;
        // FlxG.overlap(_ship, _currentCollectible, collectItem);
        // The game area is 800 by 800. So the magnet should be at least 400 in radius at the highest level.
        // var magnetRadius = 30*_magnetUpgrade._level;
        var magnetRadius = 30*Math.pow(2, _magnetUpgrade._level);
        if(_currentCollectible != null)
        {
            if(_ship.getMidpoint().distanceTo(_currentCollectible.getMidpoint()) <= pickupRadius)
            {
                collectItem(_ship, _currentCollectible);
            }
            else if(_ship.getMidpoint().distanceTo(_currentCollectible.getMidpoint()) <= magnetRadius)
            {
                var magnetForce = magnetRadius - _ship.getMidpoint().distanceTo(_currentCollectible.getMidpoint());
                var newVelocity = new FlxPoint(0, -1*magnetForce);
                newVelocity.rotate(FlxPoint.get(0, 0), _currentCollectible.getMidpoint().angleBetween(_ship.getMidpoint()));
                _currentCollectible.velocity.copyFrom(newVelocity);
            }
        }

        for(pickupItem in _currentCollectiblesGroup)
        {
            if(_ship.getMidpoint().distanceTo(pickupItem.getMidpoint()) <= pickupRadius)
            {
                collectItemInGroup(_ship, pickupItem);
            }
            else if(_ship.getMidpoint().distanceTo(pickupItem.getMidpoint()) <= magnetRadius)
            {
                var magnetForce = magnetRadius - _ship.getMidpoint().distanceTo(pickupItem.getMidpoint());
                var newVelocity = new FlxPoint(0, -1*magnetForce);
                newVelocity.rotate(FlxPoint.get(0, 0), pickupItem.getMidpoint().angleBetween(_ship.getMidpoint()));
                pickupItem.velocity.copyFrom(newVelocity);
            }
        }

        var firstRepeatInterval:Float = 0.5;
        var repeatInterval = 0.1;

        if(FlxG.keys.anyPressed(Reg._fireworkInput))
        {
            // Spend the money we've collected. Buys a firework.
            if(_sellPressCounter == 0)
            {
                buyFirework();
            }
            else if(_firstSellPress)
            {
                if(_sellPressCounter>firstRepeatInterval)
                {
                    _sellPressCounter -= firstRepeatInterval;
                    buyFirework();
                    _firstSellPress = false;
                }
            }
            else if(_sellPressCounter>repeatInterval)
            {
                _sellPressCounter -= repeatInterval;
                buyFirework();
            }
            _sellPressCounter += elapsed;
        }
        else if(FlxG.keys.anyPressed(Reg._bigFireworkInput))
        {
            // Spend the money we've collected. Buys a firework.
            if(_sellPressCounter == 0)
            {
                buyLargeFirework();
            }
            else if(_firstSellPress)
            {
                if(_sellPressCounter>firstRepeatInterval)
                {
                    _sellPressCounter -= firstRepeatInterval;
                    buyLargeFirework();
                    _firstSellPress = false;
                }
            }
            else if(_sellPressCounter>repeatInterval)
            {
                _sellPressCounter -= repeatInterval;
                buyLargeFirework();
            }
            _sellPressCounter += elapsed;
        }
        else
        {
            _firstSellPress = true;
            _sellPressCounter = 0;
        }

        if(Reg._loadingGameFromSaveSlot)
        {
            loadFromSaveSlot(Reg._saveSlotLoading);
            Reg._loadingGameFromSaveSlot = false;
        }

        if(FlxG.keys.anyJustPressed(Reg._boundSegmentsInput))
        {
            _boundSegments = !_boundSegments;
            if(_boundSegments)
            {
                addFadingMessage("Segments bounded.");
                tetherSegmentsPositionOnly();
            }
            else
            {
                addFadingMessage("Segments unbounded.");
            }
        }
        if(FlxG.keys.anyJustPressed(Reg._quicksaveInput))
        {
            saveGame();
            addFadingMessage("Game saved.");
        }
        if(FlxG.keys.anyJustPressed(Reg._quickloadInput) || Reg._loadingGame)
        {
            loadGame();
            Reg._loadingGame = false;
            addFadingMessage("Game loaded.");
        }
        if(FlxG.keys.anyJustPressed(Reg._autocondenseInput))
        {
            _autocondense = !_autocondense;
            if(_autocondense)
            {
                addFadingMessage("Auto-condense segments ON.");
            }
            else
            {
                addFadingMessage("Auto-condense segments OFF.");
            }
        }
        if(FlxG.keys.anyJustPressed(Reg._condenseInput) || _autocondense)
        {
            condenseSegments();
        }   
        if(FlxG.keys.anyJustPressed(Reg._exitInput))
        {
            FlxG.switchState(new MainMenuState());
        }
        if(FlxG.keys.anyJustPressed(Reg._saveGameInput))
        {
            var newSubState = new SaveSubstate();
            newSubState._currentPlayState = this;
            openSubState(newSubState);
        }
        if(FlxG.keys.anyJustPressed(Reg._toggleTetherModeInput))
        {
            if(_coinTetherMode == Rigid)
            {
                _coinTetherMode = TetheredOneWay;
                addFadingMessage("Tether mode: One Way");
            }
            else if(_coinTetherMode == TetheredOneWay)
            {
                _coinTetherMode = TetheredTwoWays;
                addFadingMessage("Tether mode: Two Ways");
            }
            else if(_coinTetherMode == TetheredTwoWays)
            {
                _coinTetherMode = Rigid;
                addFadingMessage("Tether mode: Rigid");
            }
        }

        FancySpriteUtil.boundSpriteToGameBounds(_ship, true, _bounceUpgrade._level/_bounceUpgrade._maxLevel);
        if(_boundSegments)
        {
            for(currentSegment in _segments)
            {
                FancySpriteUtil.boundSpriteToGameBounds(currentSegment);
            }
        }

        if(_logTimer>_logInterval)
        {
            _logTimer-=_logInterval;
        }
		super.update(elapsed);
	}

    public function upgradeMaxCoins()
    {
        if((_maxCoinsUpgrade._cost<=getSpendableMoney()) && (_maxCoinsUpgrade._level<_maxCoinsUpgrade._maxLevel) )
        {
            spendMoney(_maxCoinsUpgrade._cost);
            _maxCoinsUpgrade._level++;
            _maxCoinsUpgrade._cost = _maxCoinsUpgrade._baseCost*Std.int(Math.pow(2, (_maxCoinsUpgrade._level-1) ));
            _upgradeMaxCoinsText.text = "Max Coins lvl "+_maxCoinsUpgrade._level+"/"+_maxCoinsUpgrade._maxLevel;
            if(_maxCoinsUpgrade._level==_maxCoinsUpgrade._maxLevel)
            {
                _upgradeMaxCoinsButton.label.text = "Upgrade Max Coins (Max LVL)";
            }
            else
            {
                _upgradeMaxCoinsButton.label.text = "Upgrade Max Coins ("+_maxCoinsUpgrade._cost+")";
            }
            spawnCoins();
        }

    }

    public function upgradeBounce()
    {
        // Need to implement bounce.
        if((_bounceUpgrade._cost<=getSpendableMoney()) && (_bounceUpgrade._level<_bounceUpgrade._maxLevel) )
        {
            spendMoney(_bounceUpgrade._cost);
            _bounceUpgrade._level++;
            _bounceUpgrade._cost = _bounceUpgrade._baseCost*Std.int(Math.pow(2, (_bounceUpgrade._level) ));
            _upgradeBounceText.text = "Bounce lvl "+_bounceUpgrade._level+"/"+_bounceUpgrade._maxLevel;
            if(_bounceUpgrade._level==_bounceUpgrade._maxLevel)
            {
                _upgradeBounceButton.label.text = "Upgrade Bounce (Max LVL)";
            }
            else
            {
                _upgradeBounceButton.label.text = "Upgrade Bounce ("+_bounceUpgrade._cost+")";
            }
        }
    }

    public function upgradeThrust()
    {
        if((_thrustUpgrade._cost<=getSpendableMoney()) && (_thrustUpgrade._level<_thrustUpgrade._maxLevel) )
        {
            spendMoney(_bounceUpgrade._cost);
            setThrust(_thrustUpgrade._level+1);
            _thrustUpgrade._cost = _thrustUpgrade._baseCost*Std.int(Math.pow(2, (_thrustUpgrade._level-1) ));
            _upgradeThrustText.text = "Thrust lvl "+_thrustUpgrade._level+"/"+_thrustUpgrade._maxLevel;
            if(_thrustUpgrade._level==_thrustUpgrade._maxLevel)
            {
                _upgradeThrustButton.label.text = "Upgrade Thrust (Max LVL)";
            }
            else
            {
                _upgradeThrustButton.label.text = "Upgrade Thrust ("+_thrustUpgrade._cost+")";
            }
        }
    }

    public function upgradeMagnet()
    {
        // Need to implement magnet;
        if((_magnetUpgrade._cost<=getSpendableMoney()) && (_magnetUpgrade._level<_magnetUpgrade._maxLevel) )
        {
            spendMoney(_magnetUpgrade._cost);
            _magnetUpgrade._level++;
            _magnetUpgrade._cost = _magnetUpgrade._baseCost*Std.int(Math.pow(2, (_magnetUpgrade._level-1) ));
            _upgradeMagnetText.text = "Magnet lvl "+_magnetUpgrade._level+"/"+_magnetUpgrade._maxLevel;
            if(_magnetUpgrade._level==_magnetUpgrade._maxLevel)
            {
                _upgradeMagnetButton.label.text = "Upgrade Magnet (Max LVL)";
            }
            else
            {
                _upgradeMagnetButton.label.text = "Upgrade Magnet ("+_magnetUpgrade._cost+")";
            }
        }
    }
}
