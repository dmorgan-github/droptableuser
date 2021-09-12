(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);

    var sig = DynKlank.ar(`[
        [
            \f1.kr(82.406889228217),
            \f2.kr(164.81377845643),
            \f3.kr(195.99771799087),
            \f4.kr(493.88330125612),
            \f5.kr(659.25511382574),
            \f6.kr(1318.5102276515)
        ] * \f.ar(1).lag(0.01),

        [
            \f1amp.kr(0.39),
            \f2amp.kr(0.17),
            \f3amp.kr(0.26),
            \f4amp.kr(0.25),
            \f5amp.kr(0.25),
            \f6amp.kr(0.78)
        ] * \a.ar(0.1).lag(0.01),

        [
            \f1ring.kr(0.5),
            \f2ring.kr(0.24),
            \f3ring.kr(0.3),
            \f4ring.kr(0.51),
            \f5ring.kr(0.49),
            \f6ring.kr(0.53)
        ] * \r.ar(0.5).lag(0.01)
    ], in);

    Limiter.ar(sig, 0.7);
},
specs: [
    f1: ControlSpec(20, 16000, \lin, 0, 82.406889228217),
    f2: ControlSpec(20, 16000, \lin, 0, 164.81377845643),
    f3: ControlSpec(20, 16000, \lin, 0, 195.99771799087),
    f4: ControlSpec(20, 16000, \lin, 0, 493.88330125612),
    f5: ControlSpec(20, 16000, \lin, 0, 659.25511382574),
    f6: ControlSpec(20, 16000, \lin, 0, 1318.5102276515),
    f1ring: ControlSpec(0, 1, \lin, 0, 0.5),
    f2ring: ControlSpec(0, 1, \lin, 0, 0.24),
    f3ring: ControlSpec(0, 1, \lin, 0, 0.51),
    f4ring: ControlSpec(0, 1, \lin, 0, 0.5),
    f5ring: ControlSpec(0, 1, \lin, 0, 0.49),
    f6ring: ControlSpec(0, 1, \lin, 0, 0.53),
    f1amp: ControlSpec(0, 1, \lin, 0, 0.39),
    f2mp: ControlSpec(0, 1, \lin, 0, 0.17),
    f3amp: ControlSpec(0, 1, \lin, 0, 0.26),
    f4amp: ControlSpec(0, 1, \lin, 0, 0.25),
    f5amp: ControlSpec(0, 1, \lin, 0, 0.25),
    f6amp: ControlSpec(0, 1, \lin, 0, 0.78),
    f: ControlSpec(0, 4, \lin, 0, 1),
    a: ControlSpec(0, 4, \lin, 0, 0.1),
    r: ControlSpec(0, 4, \lin, 0, 0.5),
    input: [0, 10, \lin, 0, 1]
],
ui: {|node|
    var view = View().layout_(
        GridLayout.rows(
            [nil] ++ 6.collect({|i|
                StaticText().string_(i+1).align_(\center)
            }) ++ [nil],
            [StaticText().string_("f ")] ++ 6.collect({|i|
                var num = i+1;
                var key = ('f' ++ num).asSymbol;
                var val = node.get(key);
                var spec = node.getSpec(key);
                var default = spec.default;
                var tf, sl, knob = Knob();

                tf = TextField()
                .action_({|ctrl|
                    var val = ctrl.value.asNumberIfPossible;
                    if (val.isNumber){
                        var unmapped = spec.unmap(val);
                        knob.valueAction = unmapped;
                        knob.toolTip_(val.trunc(0.01));
                    } {
                        var cps = ctrl.value.namecps;
                        var unmapped = spec.unmap(cps);
                        knob.valueAction = unmapped;
                        knob.toolTip_(cps.trunc(0.01));
                    };
                    sl.index = 0;
                })
                .maxHeight_(20)
                .align_(\bottom)
                .value_(val.trunc(0.01));

                sl = StackLayout(
                    knob.action_({|ctrl|
                        var val = spec.map(ctrl.value);
                        node.set(key, val);
                        tf.value = val.trunc(0.01);
                        ctrl.toolTip_(val.trunc(0.01));
                    })
                    .mouseDownAction_({|ctrl, x, y, mod, num, count|
                        if (count == 2) {
                            ctrl.value = spec.unmap(default);
                            ctrl.toolTip_(default.trunc(0.01));
                            tf.value = default.trunc(0.01);
                        } {
                            if (mod == 262144) {
                                sl.index = 1;
                            };
                        }
                    })
                    .value_(spec.unmap(val))
                    .toolTip_(val.trunc(0.01))
                    .mode_(\vert),
                    tf
                )
                .mode_(\stackOne);
                sl
            })
            ++ [
                {
                    var spec = node.getSpec(\f);
                    var val = node.get(\f);
                    Knob()
                    .action_({|ctrl|
                        var val = spec.map(ctrl.value);
                        node.set(\f, val)
                    })
                    .mode_(\vert)
                    .value_(spec.unmap(val))
                }.()
            ],

            [StaticText().string_("r ")] ++ 6.collect({|i|
                var num = i+1;
                var key = ('f' ++ num ++ 'ring').asSymbol;
                var val = node.get(key);
                Knob().action_({|ctrl|
                    node.set(key, ctrl.value);
                    ctrl.toolTip_(ctrl.value.trunc(0.01));
                })
                .toolTip_(val)
                .value_(val)
                .mode_(\vert)
            })
            ++ [
                {
                    var spec = node.getSpec(\r);
                    var val = node.get(\r);
                    Knob()
                    .action_({|ctrl|
                        var val = spec.map(ctrl.value);
                        node.set(\r, val)
                    })
                    .mode_(\vert)
                    .value_(spec.unmap(val))
                }.()
            ],
            [StaticText().string_("a ")] ++ 6.collect({|i|
                var num = i+1;
                var key = ('f' ++ num ++ 'amp').asSymbol;
                var val = node.get(key);
                Knob().action_({|ctrl|
                    node.set(key, ctrl.value);
                    ctrl.toolTip_(ctrl.value.trunc(0.01));
                })
                .toolTip_(val)
                .value_(val)
                .mode_(\vert)
            })
            ++ [
                {
                    var spec = node.getSpec(\a);
                    var val = node.get(\a);
                    Knob()
                    .action_({|ctrl|
                        var val = spec.map(ctrl.value);
                        node.set(\a, val)
                    })
                    .mode_(\vert)
                    .value_(spec.unmap(val))
                }.()
            ]
        )
        .margins_(1)
        .spacing_(1)
    );
    view;
}
)