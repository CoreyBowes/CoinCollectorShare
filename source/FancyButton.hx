package;

import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class FancyButton extends FlxButton
{
    public var _isSelected = false;
    
    public function centerLabel()
    {
        // Does some stuff that FlxButton normally only does on creation. Necessary when resizing.
        label.offset.set(-5, 0);
        // label.setPosition(x+width/2-label.width/2+30, y+height/2-label.height/2+30);
        // label.setFormat(null, 12, 0x333333, "center");
    }

    /*
    Calls the FlxButton constructor using the same default arguments.
    */
	public function new(?X:Float = 0, ?Y:Float = 0, ?Label:String, ?OnDown:Void->Void, ?Width:Int = -1, ?textSize:Int=0)
	{
		super(X, Y, Label, OnDown);
        if(textSize>0)
        {
            setTextSize(textSize);
        }
		
        /*
        // Only makes sense for pure text buttons. Will probably reuse this code.
		if (Width > 0)
        {
			width = Width;
        }
		else
        {
            if(Label!=null)
            {
			    width = Label.length * 7;
            }
            else
            {
                width = 30;
            }
        }
        */
		
		// label.color = FlxColor.BLACK;
	}

    public function setTextSize(newSize:Int=8)
    {
        label.fieldWidth = 0;
        label.setFormat(null, newSize, 0x333333, "center");
        // trace("Label width: "+label.width);
        // trace("Label height: "+label.height);
        resizeButton(Std.int(label.width+10), Std.int(label.height+10));
    }

    public function updateWidth()
    {
        width = text.length * 7;
		makeGraphic(Std.int(width), Std.int(height), 0);
    }

    static public function makeWoodenButton(?x:Float=0, ?y:Float=0, ?text:String="", ?OnDown:Void->Void, ?Width:Int = -1):FancyButton
    {
        var returnButton:FancyButton = new FancyButton(x, y, text, OnDown, Width);
        // returnButton.makeGraphic(Std.int(returnButton.width), Std.int(returnButton.height), FlxColor.BROWN);
        returnButton.color = FlxColor.BROWN;
        returnButton.label.color = FlxColor.BLACK;
        return returnButton;
    }
	
    public function resizeButton(newWidth:Int, newHeight:Int)
    {
        setGraphicSize(newWidth, newHeight);
        updateHitbox();
        centerLabel();
    }

	/**
	 * Override set_status to change how highlight / normal state looks.
	 */
     /*
	override function set_status(Value:Int):Int
	{
		if (label != null)
		{
			if (Value == FlxButton.HIGHLIGHT)
			{
                // Highlighted: White text, black border
				#if !mobile // "highlight" doesn't make sense on mobile
				label.color = FlxColor.WHITE;
				label.borderStyle = OUTLINE_FAST;
				label.borderColor = FlxColor.BLACK;
				#end
			}
			else 
			{
                // Not highlighted: Black text, white border
				label.color = FlxColor.BLACK;
				label.borderStyle = OUTLINE_FAST;
				label.borderColor = FlxColor.WHITE;
                if(_isSelected)
                {
                    setSelectionStatus(_isSelected);
                }
			}
		}
		return status = Value;
	}
    */

    public function setSelectionStatus(isSelected:Bool)
    {
        _isSelected = isSelected;
		if (_isSelected)
		{
            // If selected: White text, black border, same as if highlighted. Overrides normal highlight appearance.
			#if !mobile // "highlight" doesn't make sense on mobile
			label.color = FlxColor.WHITE;
			label.borderStyle = OUTLINE_FAST;
			label.borderColor = FlxColor.BLACK;
			#end
		}
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
