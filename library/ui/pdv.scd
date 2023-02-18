(
func: {|node, prop|

    var val, tv;
    var view = View().layout_(VLayout().spacing_(0).margins_(0));
    var pdvkey;

    if (prop.isNil) {
        prop = \degree;
    };

    prop = prop.asSymbol.postln;
    pdvkey = "%_pdv_vals".format(prop).asSymbol;
    val = node.get(pdvkey);

    tv = TextView()
    .background_(Color.clear)
    .keyDownAction_({|ctrl, char, modifiers, unicode, keycode, key|

        //[char, modifiers, unicode, keycode, key].postln;
        if (modifiers == 262144) {
            switch(keycode,
                40, { // k
                    var code = ctrl.string.stripWhiteSpace;
                    node.set(pdvkey, code);
                    node.set(prop, pdv(code))
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
