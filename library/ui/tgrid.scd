
(
func: {|node|
    var num = 16, view, vals, map;
    var module = Module('device/mixer').();

    vals = Halo.at(\toscgrid, node.key);
    if (vals.isNil) {
        vals = Order.newFromIndices(num.collect({ [nil, nil] }), (0..(num-1)));
        Halo.put(\toscgrid, node.key, vals); 
    };
    map = {|vals|
        vals = vals.flop
        .collect({|v| v.reject(_.isNil) });
        module.grid(node, vals[0], vals[1])
    };
    view = View().layout_(VLayout(
        GridLayout.rows(*num.collect({|i|
                [ 
                    TextField()
                    .action_({|ctrl|
                        vals[i][0] = if (ctrl.value == "") {nil} { ctrl.value.asSymbol };
                    })
                    .keyDownAction_({|ctrl, char, modifiers, unicode, keycode, key|
                        if (key == 16777217 /*tab*/) {
                            var val = ctrl.value;
                            ctrl.valueAction = val;
                        }
                    })
                    .value_(vals[i][0] ? "")
                    .background_(Color.clear),

                    NumberBox()
                    .maxSize_(30)
                    .action_({|ctrl|
                        vals[i][1] = ctrl.value.asInteger;
                        map.(vals.array);
                    })
                    .keyDownAction_({|ctrl, char, modifiers, unicode, keycode, key|
                        if (key == 16777217 /*tab*/) {
                            var val = ctrl.value;
                            ctrl.valueAction = val;
                        }
                    })
                    .value_(vals[i][1] ?? 0)
                    .background_(Color.clear) 
                ]
            })
        ).margins_(2).spacing_(2)
    ));

    view
    .background_(Color.clear)
    .onClose_({
        Halo.put(\toscgrid, node.key, vals)
    });
}
)
