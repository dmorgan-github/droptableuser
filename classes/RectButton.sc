/*
~rb = RectButton(bounds:Rect(width:50, height: 50)).string_("y").background_(Color.red).borderColor_(Color.blue).front
~rb.borderSize = 1
~rb.background = Color.black
~rb.borderColor = Color.yellow
*/
RectButton : View {

    var <ctrlText, <ctrlBorder;
    var <value, mouseDownFunc, mouseUpFunc, actionFunc;

    *new {|bounds|
        var res = super.new(bounds:bounds).initRectButton();
        res.ctrlBorder.bounds = bounds;
        ^res
    }

    value_ {|val|
        value = val;    
    }

    font_ {|font|
        ctrlText.font = font   
    }

    action_ {|func|
        actionFunc = func;        
    }

    mouseDownAction_ {|func|
        mouseDownFunc = func
    }

    mouseUpAction_ {|func|
        mouseUpFunc = func;
    }

    bounds_ {|rect|
        this.bounds = rect;
        ctrlBorder.bounds = rect;
    }

    background_ {|color|
        ctrlText.background = color;    
    }

    borderColor_ {|color|
        ctrlBorder.background = color;    
    }

    borderSize_ {|val|
        ctrlBorder.layout.margins = val;
    }

    string_ {|val|
        ctrlText.string = val;    
    }

    textAlign_ {|val|
        ctrlText.align = val;    
    }

    initRectButton {
        ctrlText = StaticText().align_(\center)
        .mouseDownAction_({|ctrl|
            \here.debug("mouseDownAction");
            mouseDownFunc.(this) 
        })
        .mouseUpAction_({|ctrl|
            \here.debug("mouseUpAction");
            mouseUpFunc.(this)
        });

        ctrlBorder = UserView(bounds:Rect(width:50, height:50)).layout_(VLayout(ctrlText).margins_(1));
        this.action = {|ctrl|
            \here.debug("action");
            actionFunc.(ctrl)    
        };
        ^this.layout_(VLayout(ctrlBorder).margins_(0).spacing_(0))
    }

}