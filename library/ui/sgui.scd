(
var log;
var vsts = {
    if (~vstlist.isNil) {
        // get the unique list of plugins
        // prefering vst3 if vst2 version also exists
        var plugins = ();
        var list = V
        .ls
        .reject({arg val;
            var plugin = VSTPlugin.plugins[val.asSymbol];
            plugin.isNil
            or: {
                VSTPlugin.plugins[val.asSymbol].category.contains("Instrument")
            }
            or: {
                VSTPlugin.plugins[val.asSymbol].category.contains("Synth")
            }
        });

        list.do({|name|
            var noext;
            name = name.asString;
            noext = name.split($.)[0].asSymbol;
            if (plugins[noext].isNil) {
                plugins.put(noext, 0);
            };
            if (name.endsWith("vst3")) {
                plugins[noext] = 1
            };
        });

        ~vstlist = plugins.keys
        .collect({|item| if (plugins[item] == 1) { "%.vst3".format(item).asSymbol }{item} })
        .asArray
        .sort;
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

var scope = {|node|

    var view = View().layout_(VLayout().margins_(0).spacing_(0));
    //.maxHeight_(10);

    var scope = Stethoscope.new(s, view:view).style_(1)
    .index_(node.bus.index)
    .numChannels_(2).yZoom_(10).xZoom_(10);
    //win.onClose = { scope.free;  };
    4.do({
        view.children[0].children[0].remove
    });
    //view.children[0].children[0].waveColors_([color, color.complementary]);
    view.children[0].children[2].remove;
    view.children[0].children[1].remove;
    //view.maxHeight = 20;
    view.children[0].children[0].background = QtGUI.palette.window;
    //view.maxWidth = 80;
    view.onClose = { scope.free };
    view.mouseUpAction = {
        node.scope
    };
    view;
};

var getPresetsView = {|node|

    var morphbeats = 20;

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
        })
        .states_([ [nil, nil, color_init ], [nil, nil, color_active ] ])
    });

    HLayout(
        GridLayout.rows(
            buttons[0..6].collect(_.fixedSize_(10)),
            buttons[7..13].collect(_.fixedSize_(10))
        ).margins_(0).spacing_(0),

        NumberBox()
        .action_({|ctrl|
            morphbeats = ctrl.value;
        })
        .toolTip_("morph time")
        .value_(morphbeats)
    ).margins_(0).spacing_(0)
};

Fdef(\sgui, {|node, index|

    var height = 19;
    var skipId = UniqueID.next.asSymbol;
    var keys;
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
    var getGroups, getKeys, getSpec, fxmenu, getView;
    var scroll = ScrollView();
    var fxbuttonsview = View().layout_(VLayout().margins_(1).spacing_(1));
    var updateButtons, moveDown, moveUp, swap;
    var view = View(bounds:275@350)
    .layout_(VLayout().margins_(2).spacing_(2))
    .name_(windowname);
    var sliders = [];

    getSpec = {|key|
        var specs = node.getSpec;
        var spec = if (specs.isNil) {nil} { specs[key] };
        if (spec.isNil) {
            spec = [0, 1, \lin, 0, 0].asSpec;
        };
        spec
    };

    watcher = {|obj, what, vals|
        if (what == \set) {
            vals.pairsDo({|k, v|
                sliders.pairsDo({|k2, v2|
                    if (k2 == k) {
                        if (v2.value != v) {
                            //[v2.value, v].debug(\watcher);
                            v2.value = v;
                        }
                    }
                })
            })
        };
    };

    getKeys = {

        var keys;

        keys = {

            if (index.notNil) {
                node.objects[index].controlNames.collect({|cn| cn.name})
            } {
                var wtf;
                var except = List.new;
                var controlKeys;

                fxnode.objects.doRange({|obj, index, i|
                    if (index >= 100 and: {index < 1000}) {
                        var names = obj.controlNames.collect({|cn| cn.name});
                        except.addAll(names);
                    }
                });

                try({
                    node.controlKeys(except:except);
                }, {|err|
                    "node.controlKeys (use bufnum): %".format(err).postln;
                    err.throw;
                })
            };
        }.value;

        keys
        .select({|key|
            node.get(key).isNumber
        })
        .reject({|key|
            [\gate,
                \trig,
                \out,
                \in,
                \bufposreplyid,
                \wet1000,
                \wet1010,
                \fadeTime,
                \envbuf,
                //\buf,
                \pan,
                \amp,
                \spread,
                \vol,
                \bend,
                \vel
            ].includes(key)
            //or: {
            //    key.asString.beginsWith("wet")
            //}
        }).asArray
    };

    getGroups = {

        var dict, keys;
        var returnVal = List.new;

        dict = ();
        keys = getKeys.();

        keys.do({|key|
            var spec = getSpec.(key);
            var unit = spec.units.asSymbol;
            var list = dict[unit];
            if (list.isNil) {
                list = List.new;
                dict.put(unit, list);
            };
            list.add(key);
        });

        dict.keysDo({|key|
            dict[key] = dict[key].sort({|a, b|
                var specA = getSpec.(a);
                var specB = getSpec.(b);
                var sorta = if (specA.respondsTo('sort')) {
                    specA.sort
                }{
                    a
                };
                var sortb = if (specB.respondsTo('sort')) {
                    specB.sort
                }{
                    b
                };

                sorta < sortb;
            })
        });

        dict.keys.asArray.sort.do({|key|
            returnVal.add(key -> dict[key]);
        });

        returnVal;
    };

    fxmenu = {
        var paths = browse.(path);
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

    getView = {

        var view, groups;
        var mysliders;
        groups = getGroups.();
        view = View().layout_(VLayout().margins_(2).spacing_(2));

        if (node.get(\buf).notNil and: {index.isNil}) {
            view.layout.add( U(\buf, node).maxHeight_(100))
        };

        groups.do({|assoc|

            var group = assoc.key;
            var mykeys = assoc.value;

            view.layout.add(
                StaticText().string_(group).stringColor_(Color.black)
            );

            mysliders = mykeys.collect({|key, i|
                var spec = getSpec.(key);
                var val = node.get(key);
                if (val.isNil) {
                    val = spec.default;
                };
                [key, LevelSlider(key, spec:spec, color:color).maxHeight_(20)
                    .action_({|ctrl|
                        var val = node.get(key);
                        if (val != ctrl.value) {
                            //[val, ctrl.value].debug(\action);
                            node.set(key, ctrl.value);
                        }
                    })
                    .value_(val)
                ]
            }).flatten;

            mysliders.pairsDo({|key, slider|
                view.layout.add(slider);
            });

            sliders = sliders ++ mysliders;
        });

        if (index.isNil) {

            var vol = (node.get(\vol) ?? {1}).linlin(0, 2, 0, 1);
            var spread = (node.get(\spread) ?? {1});
            var pan = (node.get(\pan) ?? {0}).linlin(-1, 1, 0, 1);

            view.layout.add(
                HLayout(
                    nil,
                    VLayout(
                        Knob().action_({|ctrl|
                            var val = ctrl.value.linlin(0, 1, 0, 2);
                            node.set(\vol, val);
                            log.("vol: %".format(val));
                        })
                        .maxSize_(Size(30,30))
                        .value_(vol),
                        StaticText().string_("vol").align_(\center)
                    ),
                    nil,
                    VLayout(
                        Knob().action_({|ctrl|
                            node.set(\spread, ctrl.value);
                            log.("width: %".format(ctrl.value));
                        })
                        .maxSize_(Size(30,30))
                        .value_(spread),
                        StaticText().string_("width").align_(\center)
                    ),
                    nil,
                    VLayout(
                        Knob().action_({|ctrl|
                            var val = ctrl.value.linlin(0, 1, -1, 1);
                            node.set(\pan, val);
                            log.("pan: %".format(val));
                        })
                        .maxSize_(Size(30,30))
                        .value_(pan),
                        StaticText().string_("pan").align_(\center)
                    ),
                    nil
                )
            );
        };

        view.layout.add(nil);
        view
    };

    swap = {|node, index2, index1|

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

    moveUp = {|index|

        var num = fxnode.objects.indices.indexOf(index);
        var index2 = fxnode.objects.indices[num-1];

        if (index2.notNil) {
            swap.(fxnode, index, index2);
        } {
            "can't move node".warn;
        }
    };
    moveDown = {|index|

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
                        //.margins_(1)
                        //.spacing_(1)
                    );
                });
            };
        };
    };

    try({
        scroll.canvas = getView.();
    }, {|err|
        "% getView".format(err).error;
    });

    if (index.isNil){

        view.layout.add(
            VLayout(
                HLayout(

                    fxmenu.(),

                    Button()
                    .states_( [ ["0"] ] )
                    .toolTip_("record")
                    .maxWidth_(35)
                    .action_({|ctrl|
                        fxnode.rec(5)
                    }),

                    /*
                    NumberBox()
                    .action_({|ctrl|
                        fxnode.fadeTime = ctrl.value;
                    })
                    .toolTip_("fade time")
                    .value_(fxnode.fadeTime),
                    */

                    /*
                    NumberBox()
                    .action_({|ctrl|
                        fxnode.monitor.out = ctrl.value;
                    })
                    .toolTip_("out bus")
                    .value_(fxnode.monitor.out),
                    */

                    getPresetsView.(node),

                    Button()
                    .maxWidth_(35)
                    .states_( [ ["s"] ] )
                    .toolTip_("save")
                    .action_({
                        node.print
                    })
                ),

                //scope.(fxnode).maxHeight_(50),
            )
        );
    };

    view.layout.add(scroll);
    view.layout.add(fxbuttonsview);
    view.layout.add(status);

    if (index.isNil) {
        updateButtons.();
        fxwatcher = {|obj, what|
            if (what == \source or: {what == \reorder}) {
                // there is a lag between when the source
                // gets added and the node is ready on the
                // server
                var wait = if (what == \reorder) {0.1}{1};
                {
                    updateButtons.();
                }.defer(wait)
            }
        };
        fxnode.addDependant(fxwatcher);
    };

    /*
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
    */

    node.addDependant(watcher);

    log = {|msg|
        status.string = msg;
    };

    view.onClose_({
        node.removeDependant(watcher);
        fxnode.removeDependant(fxwatcher);
        //SkipJack.stop(skipId)
    });
});
)
