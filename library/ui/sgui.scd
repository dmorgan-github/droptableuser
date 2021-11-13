(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\sgui, {|node, index|

    var height = 19;
    var skipId = UniqueID.next.asSymbol;
    var keys;
    var connections;
    var morphbeats = 20;
    var status = StaticText().font_(Font("Courier New", 9)).background_(Color.black.alpha_(0.3));
    var color = node.color ? Color.rand;

    var getSpec = {|key|
        var specs = node.getSpec;
        var spec = if (specs.isNil) {nil} { specs[key] };
        if (spec.isNil) {
            spec = [0, 1, \lin, 0, 0].asSpec;
        };
        spec
    };

    var getKeys = {

        var keys = {
            if (index.notNil) {
                node.objects[index].controlNames.collect({|cn| cn.name})
            } {
                if (node.respondsTo(\controlKeys)) {
                    node.controlKeys;
                }{
                    node.envir.keys;
                }
            }
        }.value;

        keys
        .select({|key|
            node.get(key).isNumber
        })
        .reject({|key|
            [\gate, \trig, \out, \in, \bufposreplyid, \wet1000, \fadeTime].includes(key)
        }).asArray
        .sort({|a, b|

            var specA = getSpec.(a);
            var specB = getSpec.(b);
            "%%".format(specA.units, a) < "%%".format(specB.units, b)
        })
    };

    var log = {|msg|
        status.string = msg;
    };

    var prevcolor, prevunit;

    var getView = {

        var controls, sliders, numbers, ctrls, view;
        keys = getKeys.();
        controls = keys.collect({|key|

            try({
                var val = node.get(key);
                var spec = getSpec.(key);
                if (val.isNil) {
                    val = spec.default;
                };
                NumericControlValue(val, spec:spec)
            }, {|error|
                error.postln;
                error.throw;
            })
        });

        sliders = keys.collect({|key, i|
            Slider()
            .maxHeight_(height)
            .value_(controls[i].input)
            .orientation_(\horizontal)
            .thumbSize_(10)
            .mouseDownAction_({arg ctrl, x, y, mod, num, count;
                var spec = controls[i].spec;
                var val = spec.default;
                if (count == 2) {
                    controls[i].value = val;
                    false;
                }
            })
        });

        numbers = keys.collect({|key, i|
            var hi = controls[i].spec.maxval;
            var lo = controls[i].spec.minval;
            NumberBox().clipHi_(hi).clipLo_(lo)
            .decimals_(3)
            .maxHeight_(height)
            .maxWidth_(80)
        });

        ctrls = keys.collect({|key, i|

            var new;
            var spec = getSpec.(key);
            var unit = if (spec.notNil) { spec.units } {""};
            var color = if (unit != prevunit) {
                prevcolor = Color.rand.alpha_(0.35);
                prevunit = unit;
                new = true;
                prevcolor;
            }{
                new = false;
                prevcolor;
            };

            View().layout_(
                VLayout(
                    if (new) {
                        var st = StaticText().string_(prevunit).stringColor_(Color.black);
                        if (prevunit == "aeg") {
                            var func = {
                                var atk = node.get(\atk);
                                var atkcurve = node.get(\atkcurve);
                                var dec = node.get(\dec);
                                var deccurve = node.get(\deccurve);
                                var rel = node.get(\rel);
                                var relcurve = node.get(\relcurve);
                                var suslevel = node.get(\suslevel);
                                Env.adsr(atk, dec, suslevel, rel,
                                        curve:[atkcurve, deccurve, relcurve]).plot
                            };
                            st.mouseUpAction_({|ctrl|
                                func.()
                            })
                        };
                        if (prevunit == "buf") {
                            st.mouseUpAction_({
                                if (key == \buf) {
                                    U(\buf, node)
                                }
                            })
                        };
                        st;
                    }{
                        nil
                    },
                    HLayout(

                        StackLayout(
                            sliders[i].background_(Color.clear),
                            StaticText()
                            .string_(" " ++ key)
                            .toolTip_(key)
                        )
                        .mode_(\stackAll),

                        numbers[i],
                        Button()
                        .states_([ ["x", nil, nil],["x", nil, nil] ])
                        .action_({|ctrl|
                            node.set(key, nil)
                        })
                        .maxWidth_(12)
                        .maxHeight_(12)
                    ).margins_(0).spacing_(2)
                ).margins_(0).spacing_(0)
            ).background_(color);//.margins_(0).spacing_(0);
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
                        if (v.isNumber) {
                            controls[index].value = v;
                        }
                    }
                })
            });
        };

        view.layout.add(nil);
        view
    };

    var scope = {|srcNode|

        var node = {
            if (srcNode.respondsTo(\node)) {
                srcNode.node;
            }{
                srcNode
            }
        }.value;

        var view = View().layout_(VLayout().margins_(0).spacing_(0))
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
        view.onClose = { scope.free };
        view.mouseUpAction = {
            node.scope
        };
        view;
    };

    var view = View(bounds:275@200).layout_(VLayout().margins_(2).spacing_(2)).name_(node.key);

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
    var playbutton = Button();
    var watcher = {|obj, what|
        if (what == \stop) {
            {
                playbutton.value = 0;
            }.defer
        }
    };
    node.addDependant(watcher);

    scroll.canvas = getView.();

    if (node.respondsTo(\node)) {
        view.layout.add(
            Button().states_([ ["fx"] ]).action_({|ctrl|
                node.node.view.front
            })
        )
    };

    view.layout.add(
        //VLayout(
            HLayout(
                playbutton.states_([ [">"], [ "[]" ] ]).action_({|ctrl|
                    if (ctrl.value == 1) {
                        node.play
                    }{
                        node.stop
                    }
                })
                .maxWidth_(20)
                .value_(node.isPlaying),

                scope.(node),

                NumberBox().maxWidth_(25).action_({|ctrl|
                    morphbeats = ctrl.value;
                })
                .value_(morphbeats),

                GridLayout.rows(
                    buttons[0..6],
                    buttons[7..13]
                ).margins_(0).spacing_(0),

            ),
           //status
        //)
    );

    view.layout.add(scroll);
    if (node.respondsTo(\vstctrls)){
        var ctrls = node.vstctrls;
        var layout = VLayout();
        ctrls.do({|obj, i|
            layout.add(
                Button().states_( [ ["vst %".format(i)] ] ).action_({|ctrl|
                    obj.editor
                })
            );
        });
        view.layout.add(layout);
    };
    view.layout.add(status);

    SkipJack({
        var prev = keys.size;
        var new = getKeys.().size;
        if (prev != new) {
            {
                connections.free;
                scroll.canvas = getView.();
            }.defer
        }
    }, name: skipId);

    view.onClose_({
        connections.free;
        node.removeDependant(watcher);
        SkipJack.stop(skipId)
    });

});
)
