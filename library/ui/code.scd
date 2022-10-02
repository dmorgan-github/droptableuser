(
func: {|node|
    var view = View().layout_(VLayout());
    var tv = TextView()
    .background_(Color.clear)
    .keyDownAction_({|ctrl, char, modifiers, unicode, keycode, key|

        //[char, modifiers, unicode, keycode, key].postln;

        if (modifiers == 262144) {
            switch(keycode,
                40, { // k
                    var code = ctrl.string;
                    var obj = code.interpret;
                    ~s2.perform(\source_, obj)
                }
            )
        }
    })
    //.palette_(QPalette.dark)
    .hasVerticalScroller_(true)
    ;

    tv.syntaxColorize;
    view.layout.add(tv);
    view;
}
)