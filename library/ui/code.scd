(
func: {|node|
    var val, tv;
    var view = View().layout_(VLayout().spacing_(0).margins_(0));

    val = node.get(\pdv);
    tv = TextView()
    .background_(Color.clear)
    .keyDownAction_({|ctrl, char, modifiers, unicode, keycode, key|

        //[char, modifiers, unicode, keycode, key].postln;

        if (modifiers == 262144) {
            switch(keycode,
                40, { // k
                    var code = ctrl.string;
                    //var obj = code.interpret;
                    //node.perform(\source_, obj)
                    node.set(\pdv, code);
                    node.source = Pbind(\degree, pdv(code))
                }
            )
        }
    })
    //.palette_(QPalette.dark)
    .hasVerticalScroller_(true)
    .string_(val)
    ;

    tv.syntaxColorize;
    view.layout.add(tv);
    view;
}
)