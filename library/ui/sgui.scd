(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\sgui, {|node|

    var height = 19;
    var skipId = UniqueID.next.asSymbol;
    var keys;
    var connections;
    var morphbeats = 20;
    var status = StaticText().font_(Font("Courier New", 9)).background_(Color.black.alpha_(0.3));
    var color = node.color ? Color.rand;

    var getSpec = {|key|
        var specs = node.getSpec;
        var spec = specs[key];
        if (spec.isNil) {
            spec = [0, 1, \lin, 0, 0].asSpec;
        };
        spec
    };

    var getKeys = {
        node.envir.keys
        .select({|key|
            node.get(key).isNumber
        })
        .reject({|key|
            [\gate, \trig, \out, \in, \bufposreplyid].includes(key)
        }).asArray
        .sort({|a, b|

            var specA = getSpec.(a);
            var specB = getSpec.(b);
            "%%".format(specA.units, a) < "%%".format(specB.units, b)
           //a < b
        })
    };

    var log = {|msg|
        status.string = msg;
    };

    var getView = {

        var controls, sliders, numbers, ctrls, view;

        keys = getKeys.();

        controls = keys.collect({|key|
            var val = node.get(key);
            var spec = getSpec.(key);
            if (val.isNil) {
                val = spec.default;
            };
            NumericControlValue(val, spec:spec)
        });

        sliders = keys.collect({|key, i|
            Slider()
            .maxHeight_(height)
            .value_(controls[i].input)
            .orientation_(\horizontal)
            .thumbSize_(10)
        });

        numbers = keys.collect({|key, i|
            var hi = controls[i].spec.maxval;
            var lo = controls[i].spec.minval;
            NumberBox().clipHi_(hi).clipLo_(lo)
            .maxHeight_(height)
            .maxWidth_(80)
        });

        ctrls = keys.collect({|key, i|
            HLayout(
                StaticText()
                .mouseDownAction_({
                    if (key == \buf) {
                        U(\buf, node)
                    }
                })
                .fixedWidth_(50)
                .string_(key)
                .toolTip_(key),
                sliders[i],
                numbers[i]
            )
        });

        view = View()
        .layout_(VLayout(*ctrls).margins_(5).spacing_(2))
        .background_(color.alpha_(0.4));

        connections = ConnectionList.make {
            controls.connectEach(\input, sliders, _.valueSlot);
            controls.connectEach(\value, numbers, _.valueSlot);
            sliders.connectEach(\value, controls, _.inputSlot);
            numbers.connectEach(\value, controls, _.valueSlot);

            controls.do({|ctrl, i|
                ctrl.connectTo({|ctrl, slot, mapped, val|
                    var key = keys[i];
                    node.set(key, mapped);
                })
            });

            node.signal(\set).connectTo({|obj, operation, val|
                val.pairsDo({|k, v|
                    var index = keys.indexOf(k);
                    if (index.notNil) {
                        controls[index].value = v;
                    }
                })
            });
        };

        view.layout.add(nil);
        view
    };

    var scope = {|srcNode|

        var node = srcNode;
        var view = View().layout_(VLayout().margins_(0).spacing_(0))
        //.palette_(QPalette.dark)
        .maxHeight_(10);
        var scope = Stethoscope.new(s, view:view).style_(1)
        .index_(node.bus.index)
        .numChannels_(2).yZoom_(2).xZoom_(2);
        //win.onClose = { scope.free;  };
        4.do({
            view.children[0].children[0].remove
        });
        view.children[0].children[0].waveColors_([Color.rand, Color.rand]);
        view.children[0].children[2].remove;
        view.children[0].children[1].remove;
        view.maxHeight = 20;
        view.children[0].children[0].background = Color.new255(77, 77, 77);
        view.maxWidth = 80;
        view.onClose = { \freescope.postln; scope.free };
        view.mouseUpAction = {
            node.scope
        };
        view;
    };

    var view = View(bounds:220@200).layout_(VLayout().margins_(2).spacing_(2)).name_(node.key);
    var buttons = 14.collect({|i|
        var color_active = Color.white.alpha_(0.9);
        var color_saved = Color.green.alpha_(0.9);
        var color_empty = Color.gray;
        var issaved = P.getPreset(node, i).notNil;
        var color_init = if (issaved) {color_saved}{color_empty};
        Button()
        .fixedSize_(10)
        .action_({|ctrl|
            buttons.do({|btn, j|
                if (i != j) {
                    if (btn.value == 1) {
                        btn.states = [ [nil, nil, color_saved ], [nil, nil, color_active ] ]
                    };
                    btn.value = 0;
                }
            });

            if (ctrl.value == 1) {
                var preset = P.getPreset(node, i);
                if (preset.isNil) {
                    log.("% preset %".format(\save, i));
                    P.addCurrent(node, i);
                } {
                    log.("% preset %".format(\morph, i));
                    P.morph(node, i, beats:morphbeats);
                };
            }{
                // button stays on
                ctrl.value = 1
            }
        })
        .mouseDownAction_({|ctrl, x, y, mod, num, count|
            // 262144 ctrl delete
            // 131072 shift overwrite
            // 524288 option
            if (mod == 262144) {
                log.("% preset %".format(\remove, i));
                P.remove(node, i);
                ctrl.states = [ [nil, nil, color_empty ], [nil, nil, color_active ] ];
            };
            if (mod == 131072) {
                log.("% preset %".format(\overwrite, i));
                P.addCurrent(node, i);
            };
            //[mod, num].postln;
        })
        .states_([ [nil, nil, color_init ], [nil, nil, color_active ] ])
    });

    var scroll = ScrollView();
    scroll.canvas = getView.();

    view.layout.add(scroll);
    view.layout.add(
        VLayout(
            HLayout(
                Button().states_([ [">"], [ "[]" ] ]).action_({|ctrl|
                    if (ctrl.value == 1) {
                        node.play
                    }{
                        node.stop
                    }
                })
                .maxWidth_(20)
                .value_(node.isPlaying),

                scope.(node.node),

                NumberBox().maxWidth_(25).action_({|ctrl|
                    morphbeats = ctrl.value;
                })
                .value_(morphbeats),

                GridLayout.rows(
                    buttons[0..6],
                    buttons[7..13]
                ).margins_(0).spacing_(0),

            ),
           status
        )
    );

    SkipJack({
        var prev = keys.size;
        var new = getKeys.().size;
        if (prev != new) {
            connections.free;
            scroll.canvas = getView.();
        }
    }, name: skipId);

    view.onClose_({
        connections.free;
        SkipJack.stop(skipId)
    })
    .front;
});
)
