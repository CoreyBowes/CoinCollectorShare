// Code that I'm no longer using, but I want to save in case I need again. Mostly testing and debugging.
/**
 * ...
 * @author CharType
 */
/*
        trace("Saving game.");
        trace("Saving the collectible at: "+_currentCollectible.x+", "+_currentCollectible.y);
        trace("Save complete.");
        trace("Saved ship at: "+Reg._autosaveShip.x+", "+Reg._autosaveShip.y);
        trace("Saved collectible at: "+Reg._autosaveCurrentCollectible.x+", "+Reg._autosaveCurrentCollectible.y);
        trace("Saved segments: "+Reg._autosaveSegments.length);
        trace("Loading save.");
        trace("Loading ship at: "+Reg._autosaveShip.x+", "+Reg._autosaveShip.y);
        trace("Collectible loaded.");
        trace("Width of ship: "+_gameSaves.data.autosaveShip.width);
        trace("Saved ship at: "+Reg._gameSaves.data.autosaveShip.x);
        trace("Segments array length: "+_gameSaves.data.autosaveSegmentsArray.length);
        trace("State cleared. Current members: "+length);
        trace("C/S/G/E: "+_copperSegments+", "+_silverSegments+", "+_goldSegments+", "+_electrumSegments);
            trace("Current segment type: "+currentSegmentType);
                // Adjust segment's velocity so that it stays at least parallel to tethering segment's absolute position. Fixed to use correct angle.
                var velocityCorrectionVector:FlxPoint = new FlxPoint(0, 0);
                if(Math.sin((angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)-90)*Math.PI/180)>1)
                {
                    trace("Correction vector sine greater than 1.");
                    trace("Correction vector sine: "+Math.sin((angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)-90)*Math.PI/180));
                    trace("Correction vector angle: "+(angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)-90));
                }
                else if(Math.sin((angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)-90)*Math.PI/180)<0)
                {
                    trace("Correction vector sine less than 0.");
                    trace("Correction vector sine: "+Math.sin((angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)-90)*Math.PI/180));
                    trace("Correction vector angle: "+(angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)-90));
                }
                else
                {
                    velocityCorrectionVector.copyFrom(vectorToLastSegment);
                    FancySpriteUtil.normalizePoint(velocityCorrectionVector);
                    velocityCorrectionVector.scale( currentSegment.velocity.distanceTo(FlxPoint.weak(0, 0)) * Math.sin((angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)-90)*Math.PI/180) );
                }
                logOnTimer("Correction vector sine: "+Math.sin((angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)-90)*Math.PI/180));
                logOnTimer("Correction vector angle: "+(angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)-90));
                
                // Adds velocity component for transferring the velocity of the last segment parallel with the tether. Fixed to use correct angle.
                var transferredVelocity:FlxPoint = new FlxPoint(0, 0);
                transferredVelocity.copyFrom(vectorToLastSegment);
                FancySpriteUtil.normalizePoint(transferredVelocity);
                var velocityTransferMagnitude = lastSegmentVelocity.distanceTo(FlxPoint.weak(0, 0))*Math.cos(angleDifferenceFromOrigin(vectorToLastSegment, lastSegmentVelocity)*Math.PI/180);
                var velocityFollowingComponent = currentSegment.velocity.distanceTo(FlxPoint.weak(0, 0))*Math.cos(angleDifferenceFromOrigin(vectorToLastSegment, currentSegment.velocity)*Math.PI/180);
                if(velocityTransferMagnitude > velocityFollowingComponent)
                {
                    transferredVelocity.scale(velocityTransferMagnitude - velocityFollowingComponent);
                    velocityCorrectionVector.addPoint(transferredVelocity);
                }
                currentSegment.velocity.addPoint(velocityCorrectionVector);
                if( currentSegment.velocity.distanceTo(FlxPoint.weak(0, 0))>lastSegmentVelocity.distanceTo(FlxPoint.weak(0, 0)) )
                {
                    // trace("Velocity greater than straight copy.");
                }

                var velocityDifference:FlxPoint = new FlxPoint();
                velocityDifference.copyFrom(lastSegmentVelocity);
                velocityDifference.subtractPoint(currentSegment.velocity);
                var tetherPull:FlxPoint = new FlxPoint();
                tetherPull.copyFrom(vectorToLastSegment);
                FancySpriteUtil.normalizePoint(tetherPull);
                if(Math.cos(angleDifferenceFromOrigin(velocityDifference, vectorToLastSegment))>1)
                {
                    // trace("Cos greater than 1.");
                }
                else if(Math.cos(angleDifferenceFromOrigin(velocityDifference, vectorToLastSegment))<0)
                {
                    // trace("Cos less than 0.");
                }
                tetherPull.scale(velocityDifference.distanceTo(FlxPoint.weak(0,0))*Math.cos(angleDifferenceFromOrigin(velocityDifference, vectorToLastSegment)));
                        if(velocityChange.distanceTo(FlxPoint.weak(0,0)) > 100)
                        {
                            trace("High change. Transferring "+FlxMath.roundDecimal(velocityChange.distanceTo(FlxPoint.weak(0,0)), 3)
                            +"."+"Transferring point: at "+FlxMath.roundDecimal(currentSegment.x, 3)+","+
                            FlxMath.roundDecimal(currentSegment.y, 3)+" with velocity "+FlxMath.roundDecimal(currentSegment.velocity.x, 3)
                            +","+FlxMath.roundDecimal(currentSegment.velocity.y, 3));
                            trace("Transferring to point: at "+FlxMath.roundDecimal(lastSegment.x, 3)+","
                            +FlxMath.roundDecimal(lastSegment.y, 3)+" with velocity "+FlxMath.roundDecimal(lastSegment.velocity.x, 3)+
                            ","+FlxMath.roundDecimal(lastSegment.velocity.y, 3));
                        }
        clear();

        create();
        remove(_segments);
        remove(_currentCollectible);
        remove(_ship);
        remove(_moneyText);
        remove(_cratesText);

        // Re-initializing variables.
        _myRand = new FlxRandom();

        // #region Loading sprites into Reg variables.
        // For some reason, passing save data properties into a function as FlxSprite's gives us an error, 
        // but we can still access the FlxSprite's properties just fine. So, we're copying the properties into 
        // Reg static variables first.
        Reg._autosaveSegments = new FlxSpriteGroup();
        for(i in 0...Reg._gameSaves.data.autosaveSegmentsArray.length)
        {
            var newSegment = new Coin();
            newSegment.x = Reg._gameSaves.data.autosaveSegmentsArray[i].x;
            newSegment.y = Reg._gameSaves.data.autosaveSegmentsArray[i].y;
            newSegment.velocity.x = Reg._gameSaves.data.autosaveSegmentsArray[i].velocity.x;
            newSegment.velocity.y = Reg._gameSaves.data.autosaveSegmentsArray[i].velocity.y;
            Reg._autosaveSegments.add(newSegment);
        }
        Reg._autosaveCurrentCollectible = new Coin();
        Reg._autosaveCurrentCollectible.x = Reg._gameSaves.data.autosaveCurrentCollectible.x;
        Reg._autosaveCurrentCollectible.y = Reg._gameSaves.data.autosaveCurrentCollectible.y;
        _currentCollectible = FancySpriteUtil.copySprite(Reg._autosaveCurrentCollectible);

        Reg._autosaveShip = new PlayerShip();
        Reg._autosaveShip.x = Reg._gameSaves.data.autosaveShip.x;
        Reg._autosaveShip.y = Reg._gameSaves.data.autosaveShip.y;
        Reg._autosaveShip.angularVelocity = Reg._gameSaves.data.autosaveShip.angularVelocity;
        Reg._autosaveShip.angle = Reg._gameSaves.data.autosaveShip.angle;
        Reg._autosaveShip.velocity.x = Reg._gameSaves.data.autosaveShip.velocity.x;
        Reg._autosaveShip.velocity.y = Reg._gameSaves.data.autosaveShip.velocity.y;
        Reg._autosaveShip.acceleration.x = Reg._gameSaves.data.autosaveShip.acceleration.x;
        Reg._autosaveShip.acceleration.y = Reg._gameSaves.data.autosaveShip.acceleration.y;
        // #endregion

        _segments = new FlxSpriteGroup();
        _ship = FancySpriteUtil.copyShip(Reg._autosaveShip);
        _money = Reg._gameSaves.data.autosaveMoney;
        _cratesCollected = Reg._gameSaves.data.autosaveCratesCollected;
        _copperSegments = Reg._gameSaves.data.autosaveCopperSegments;
        _silverSegments = Reg._gameSaves.data.autosaveSilverSegments;
        _goldSegments = Reg._gameSaves.data.autosaveGoldSegments;
        _electrumSegments = Reg._gameSaves.data.autosaveElectrumSegments;

        for(i in 0...Reg._autosaveSegments.members.length)
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
            _segments.add(FancySpriteUtil.copyCoinFromSprite(Reg._autosaveSegments.members[i], currentSegmentType));
        }

        _moneyText = new FlxText(0, 0, FlxG.width, "Money: $"+_money, 16);
        _moneyText.color = FlxColor.WHITE;
        _cratesText = new FlxText(0, 0, FlxG.width, "Crates collected: "+_cratesCollected, 16);
        _cratesText.color = FlxColor.WHITE;
        _cratesText.alignment = RIGHT;

        add(_segments);
        add(_currentCollectible);
        add(_ship);
        add(_moneyText);
        add(_cratesText);
        Reg._gameSaves.data.autosaveCurrentCollectible = FancySpriteUtil.copySprite(_currentCollectible);
        Reg._gameSaves.data.autosaveShip = FancySpriteUtil.copyShip(_ship);

        Reg._gameSaves.data.autosaveSegments = FancySpriteUtil.copySpriteGroup(_segments);
        Reg._gameSaves.data.autosaveSegmentsArray = new Array();
        for(copySegment in _segments)
        {
            Reg._gameSaves.data.autosaveSegmentsArray.push(FancySpriteUtil.copySprite(copySegment));
        }

        Reg._gameSaves.data.autosaveMoney = _money;
        Reg._gameSaves.data.autosaveCratesCollected = _cratesCollected;
        Reg._gameSaves.data.autosaveCopperSegments = _copperSegments;
        Reg._gameSaves.data.autosaveSilverSegments = _silverSegments;
        Reg._gameSaves.data.autosaveGoldSegments = _goldSegments;
        Reg._gameSaves.data.autosaveElectrumSegments = _electrumSegments;
        Reg._gameSaves.flush();
        // Reg.loadFromSave();
*/