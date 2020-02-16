package;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;

enum ButtonType
{
    Wooden;
    Gray;
    Text;
    Gold;
}

enum Layout
{
    Horizontal;
    Vertical;
}

class Menu extends FlxSpriteGroup
{
    public var _isVertical:Bool = true;
    public var _buttonOffset:Float = 100;
    public var _verticalOffset = 30;
    public var _horizontalOffset = 100;
    public var _buttonType:ButtonType = Gray;
    public var _buttonTextSize:Int = 0;
    public var _buttonWidth:Int = 0;
    public var _buttonHeight:Int = 0;
    public var _buttonHorizontalSpacing:Int = 20;
    public var _buttonVerticalSpacing:Int = 20;

    override public function new(?X:Float=0, ?Y:Float=0, ?maxSize:Int=0, ?verticalMenu:Bool=true, ?menuButtonsOffset:Float=0,
    ?menuButtonsType:ButtonType)
    {
        super(X, Y, maxSize);
        _isVertical = verticalMenu;
        if(_isVertical)
        {
            _buttonOffset = _verticalOffset;
        }
        else
        {
            _buttonOffset = _horizontalOffset;
        }

        if(menuButtonsType!=null)
        {
            _buttonType=menuButtonsType;
        }
    }

    public function arrangeButtons()
    {
        for(i in 0...members.length)
        {
            if(_isVertical)
            {
                members[i].setPosition(0+x, _verticalOffset*i+y);
            }
            else
            {
                members[i].setPosition(_horizontalOffset*i+x, 0+y);
            }
        }
    }

    public function addButton(?buttonText:String, ?OnDown:Void->Void)
    {
        var buttonToAdd:FancyButton = new FancyButton();
        switch(_buttonType)
        {
            case Gray:
                buttonToAdd = new FancyButton(0, 0, buttonText, OnDown);
            case Wooden:
                buttonToAdd = FancyButton.makeWoodenButton(0, 0, buttonText, OnDown);
            default:
                buttonToAdd = new FancyButton(0, 0, buttonText, OnDown);
        }
        if(_buttonTextSize > 0)
        {
            buttonToAdd.setTextSize(_buttonTextSize);
            buttonToAdd.updateHitbox();
        }
        else if(_buttonWidth > 0)
        {
            buttonToAdd.resizeButton(_buttonWidth, _buttonHeight);
            buttonToAdd.updateHitbox();
        }
        add(buttonToAdd);
        arrangeButtons();
    }

	public function setButtonSize(?buttonWidth:Int=50, ?buttonHeight:Int=20):Void
	{
		_buttonWidth = buttonWidth;
        _buttonHeight = buttonHeight;
        _horizontalOffset = _buttonWidth+_buttonHorizontalSpacing;
        _verticalOffset = _buttonHeight+_buttonVerticalSpacing;
	}

	public function setButtonTextSize(?newTextSize:Int=8):Void
	{
		_buttonTextSize = newTextSize;
        var testButton:FancyButton = new FancyButton(0, 0, "Test Text");
        testButton.setTextSize(_buttonTextSize);
        _horizontalOffset = Std.int(testButton.width)+_buttonHorizontalSpacing;
        _verticalOffset = Std.int(testButton.height)+_buttonVerticalSpacing;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}