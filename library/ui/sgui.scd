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
    var path = App.librarydir ++ "fx/";
    var fxnode = if (node.respondsTo(\node)) { node.node }{ node };
    var watcher, fxwatcher;
    var windowname = if (index.notNil) {
        "%/%".format(node.key, fxnode.fxchain[index].name);
    }{
        node.key
    };

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
                var except = List.new;
                var controlKeys;
                fxnode.objects.doRange({|obj, index, i|
                    if (index >= 100 and: {index < 1000}) {
                        var names = obj.controlNames.collect({|cn| cn.name});
                        except.addAll(names);
                    }
                });
                node.controlKeys(except:except);
            };
        }.value;

        keys
        .select({|key|
            node.get(key).isNumber
        })
        .reject({|key|
            [\gate, \trig, \out, \in, \bufposreplyid, \wet1000, \fadeTime, \envbuf].includes(key)
        }).asArray
        .sort({|a, b|

            var specA = getSpec.(a);
            var specB = getSpec.(b);
            "%%".format(specA.units, a) < "%%".format(specB.units, b)
        })
    };

    var vsts = {
        if (~vstlist.isNil) {
            ~vstlist = V
            .ls
            .reject({arg val;
                val.asString.endsWith(".vst3") or: val.asString.contains("/");
            });
            ~vstlist = ~vstlist.sort;
        };
        ~vstlist
    };

    var browse = {arg path, files=List.new;
        var folder = PathName.new(path);
        if (folder.isFolder) {
            var folders = folder.folders;
            files = files.addAll(folder.files);
            folders.do({arg folder;
                browse.(folder.fullPath, files);
            });
        };
        files;
    };

    var paths = browse.(path);

    var st = {
        StaticText().string_("...")
        .setContextMenuActions(
            *(
                paths.collect({arg path;
                    var name = path.folderName ++ '/' ++ path.fileNameWithoutExtension;
                    MenuAction( name, {arg action, what, value;

                        var id = action.string.asSymbol;
                        var maxindex;

                        maxindex = fxnode.objects.indices
                        .reject({|val| val < 100 or: {val >= 1000} }).maxItem ?? {100};

                        fxnode.fx(maxindex + 10, id);
                    });
                })
                ++ vsts.().collect({arg vst;
                    MenuAction(vst, {arg action;

                        var id = "vst/%".format(action.string).asSymbol;
                        var maxindex;

                        maxindex = fxnode.objects.indices
                        .reject({|val| val < 100 or: {val >= 1000} }).maxItem ?? {100};

                        fxnode.fx(maxindex + 10, id);
                    })
                })
            )
        );
    };

    var log = {|msg|
        status.string = msg;
    };

    var prevcolor = color.complementary, prevunit;

    var getEnv = {|type|

        switch(type,
            \adsr, {
                Env.adsr(
                    attackTime: node.get(\atk),
                    decayTime: node.get(\dec),
                    sustainLevel: node.get(\suslevel),
                    releaseTime: node.get(\rel),
                    curve: [node.get(\atkcurve), node.get(\deccurve), node.get(\relcurve)]
                )
            },
            \perc, {
                Env.perc(
                    attackTime: node.get(\atk),
                    releaseTime: node.get(\rel),
                    curve: [node.get(\atkcurve), node.get(\relcurve)]
                )
            },
            {Env.perc}
        );
    };

    var envView = {

        var view = nil;

        if (node.metadata.notNil) {
            var type = node.metadata[\env];

            if (type.notNil) {
                view = EnvelopeView()
                .maxHeight_(100)
                .drawLines_(true)
                .selectionColor_(Color.blue)
                .action_({})
                .thumbSize_(10)
                .editable_(false);

                view.setEnv(getEnv.(type));
            }
        };

        view

    }.();

    var updateEnv = {
        if (envView.notNil) {
            var type = node.metadata[\env];
            {
                envView.setEnv(getEnv.(type));
            }.defer
        }
    };

    var getView = {

        var getEnv;
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
            //Slider(bounds:Rect(height:height))
            NiceSlider(key, spec:controls[i].spec, color:color).maxHeight_(25)
            //.maxHeight_(height)
            .value_(controls[i].input)
            //.orientation_(\horizontal)
            //.thumbSize_(10)
            //.mouseDownAction_({arg ctrl, x, y, mod, num, count;
            //    var spec = controls[i].spec;
            //    var val = spec.default;
            //    if (count == 2) {
            //        controls[i].value = val;
            //        false;
            //    }
            //})
            //.mouseWheelAction_({
            //    false
            //})
        });

        /*
        numbers = keys.collect({|key, i|
            var hi = controls[i].spec.maxval;
            var lo = controls[i].spec.minval;
            NumberBox(bounds:Rect(height:height))
            .clipHi_(hi)
            .clipLo_(lo)
            .decimals_(3)
            .maxHeight_(height)
            .maxWidth_(80)
            .mouseWheelAction_({
                false
            })
        });
        */

        ctrls = keys.collect({|key, i|

            var new;
            var spec = getSpec.(key);
            var unit = if (spec.notNil) { spec.units } {""};
            if (unit != prevunit) {
                prevcolor = color;//.alpha_(1);//Color.rand.alpha_(0.35);
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


                        //StackLayout(
                            sliders[i]//.background_(Color.clear),
                        //    StaticText()
                        //    .string_(" " ++ key)
                        //    .toolTip_(key)
                        //)
                        //.mode_(\stackAll),

                        //numbers[i],

                    ).margins_(0).spacing_(2)
                ).margins_(0).spacing_(0)
            );//.background_(color);//.margins_(0).spacing_(0);
        });

        view = View()
        .layout_(VLayout(envView, *ctrls).margins_(2).spacing_(2))
        //.background_(color.alpha_(0.4))
        ;

        connections = ConnectionList.make {
            controls.connectEach(\input, sliders, _.valueSlot);
            //controls.connectEach(\value, numbers, _.valueSlot);
            sliders.connectEach(\value, controls, _.inputSlot);
            //numbers.connectEach(\value, controls, _.valueSlot);

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

    var scope = {

        var node = fxnode;

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

    var view = View(bounds:275@200)
    .layout_(VLayout().margins_(2).spacing_(2))
    .name_(windowname);

    var buttons = 14.collect({|i|
        var color_active = Color.white.alpha_(0.9);
        var color_saved = Color.green.alpha_(0.9);
        var color_empty = Color.gray;
        var issaved = P.getPreset(node, i).notNil;
        var color_init = if (issaved) {color_saved}{color_empty};
        Button()
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
    var fxbuttonsview = View().layout_(VLayout());
    var updateButtons;

    var swap = {|node, index2, index1|

        var fx1 = node.fxchain[index1];
        var fx2 = node.fxchain[index2];

        var obj1 = node.objects[index1];
        var obj2 = node.objects[index2];

        var synth1 = Synth.basicNew(obj1.synthDef.name, Server.default, obj1.nodeID);
        var synth2 = Synth.basicNew(obj2.synthDef.name, Server.default, obj2.nodeID);

        synth2.moveBefore(synth1);

        node.objects[index1] = obj2;
        node.objects[index2] = obj1;

        node.fxchain[index1] = fx2;
        node.fxchain[index2] = fx1;

        node.changed(\reorder)
    };

    //~swap.(~modal.node, 140, 110)
    //~idx1 = ~modal.node.objects.indices.indexOf(90)
    //~idx2 = ~modal.node.objects.indices[~idx1-1]
    //~idx3 = ~modal.node.objects.indices[~idx1+1]
    //~swap.(~modal.node, 140, 150)


    var moveUp = {|index|

        var num = fxnode.objects.indices.indexOf(index);
        var index2 = fxnode.objects.indices[num-1];

        if (index2.notNil) {
            swap.(fxnode, index, index2);
        } {
            "can't move node".warn;
        }
    };
    var moveDown = {|index|

        var num = fxnode.objects.indices.indexOf(index);
        var index2 = fxnode.objects.indices[num+1];

        if (index2.notNil) {
            swap.(fxnode, index2, index);
        } {
            "can't move node".warn;
        }
    };

    updateButtons = {

        if (index.isNil) {

            var ctrls = fxnode.fxchain;

            fxbuttonsview.children.do({|child|
                child.remove
            });

            if (ctrls.indices.size > 0) {

                ctrls.doRange({|obj, index, i|

                    fxbuttonsview.layout.add(
                        HLayout(
                            Button().states_([  ["↓"]  ]).action_({
                                moveDown.(index);
                            })
                            .maxWidth_(50),
                            Button().states_([  ["↑"]  ]).action_({
                                moveUp.(index);
                            })
                            .maxWidth_(50),
                            Button().states_( [ [obj.name] ] ).action_({|ctrl|
                                if (obj.type == 'vst') {
                                    obj['ctrl'].editor
                                }{
                                    U(\sgui, fxnode, index).front
                                }
                            })
                            .mouseDownAction_({|ctrl, x, y, mod, num, count|
                                if (obj.type == 'vst') {
                                    // ctrl key
                                    if (mod == 262144) {
                                        U(\sgui, fxnode, index).front
                                    };
                                    // alt key
                                    if (mod == 524288) {
                                        obj['ctrl'].gui
                                    }
                                }
                            }),
                            Button().states_([  ["x"]  ]).action_({
                                node.fx(index, nil)
                            })
                            .maxWidth_(50),
                        )
                    );
                });
            };
        };
    };

    scroll.canvas = getView.();

    if (index.isNil){

        view.layout.add(
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

                scope.(),

                NumberBox().maxWidth_(25).action_({|ctrl|
                    morphbeats = ctrl.value;
                })
                .value_(morphbeats),

                GridLayout.rows(
                    buttons[0..6].collect(_.fixedSize_(10)),
                    buttons[7..13].collect(_.fixedSize_(10))
                ).margins_(0).spacing_(0),
            )
        );

        view.layout.add(st.());
    };
    view.layout.add(scroll);
    view.layout.add(fxbuttonsview);
    view.layout.add(status);

    watcher = {|obj, what|
        //if (what == \stop) {
        //    {
        //        playbutton.value = 0;
        //    }.defer
        //}
    };
    node.addDependant(watcher);
    node.addDependant(updateEnv);

    if (index.isNil) {
        updateButtons.();
        fxwatcher = {|obj, what|
            if (what == \source or: {what == \reorder}) {
                var wait = if (what == \reorder) {0.1}{1};
                {
                    updateButtons.();
                }.defer(wait)
            }
        };
        fxnode.addDependant(fxwatcher);
    };

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
        node.removeDependant(updateEnv);
        fxnode.removeDependant(fxwatcher);
        SkipJack.stop(skipId)
        //Tdef(skipId).stop;
        //Tdef(skipId).clear
    });

});
)
