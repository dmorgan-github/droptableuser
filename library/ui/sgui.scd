var log;

(
func: {|node, index|

    var height = 19;
    var skipId = UniqueID.next.asSymbol;
    var keys;
    var status = StaticText().font_(Font("Courier New", 9)).background_(Color.black.alpha_(0.3));
    var color = node.color ? Color.rand;
    var fxnode = if (node.respondsTo(\node)) { node.node }{ node };
    var watcher, fxwatcher;
    var windowname = if (index.notNil) {
        "%/%".format(node.key, fxnode.fxchain[index].name);
    }{
        node.key
    };
    var getGroups, getKeys, getSpec, getView;
    var scroll = ScrollView();
    var fxbuttonsview = View().layout_(VLayout().margins_(1).spacing_(1));
    var updateButtons, moveDown, moveUp, swap;
    var view = View(bounds:275@350)
    .layout_(VLayout().margins_(2).spacing_(2))
    .name_(windowname);
    var sliders = [];
    var fxmenu = Ui('fxmenu');
    var presets = Ui('presets');

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
                            if (v.isNumber) {
                                {v2.value = v}.defer(0);
                            } {
                                "sgui not number".debug(v)
                            }
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

    getView = {

        var view, groups;
        var mysliders;
        groups = getGroups.();
        view = View().layout_(VLayout().margins_(0).spacing_(0));

        if (node.get(\buf).notNil and: {index.isNil}) {
            var ui = Ui('buf').view(node);
            view.layout.add( ui.maxHeight_(100) )
        };

        groups.do({|assoc|

            var group = assoc.key;
            var mykeys = assoc.value;
            var custom;

            view.layout.add(
                StaticText()
                .string_(group)
                .stringColor_(Color.black)
                .mouseUpAction_({|ctrl|
                    if (group == \aeg) {
                        Ui(group).view(node).minSize_(Size(400, 200)).front
                    }
                })
            );

            if (group == \aeg) {
                custom = Ui(group).view(node);
                view.layout.add(custom.maxHeight_(135));
            }{

                mysliders = mykeys.collect({|key, i|
                    var spec = getSpec.(key);
                    var val = node.get(key);
                    if (val.isNil) {
                        val = spec.default;
                    };
                    [key, LevelSlider(key, spec:spec, color:color)
                        .maxHeight_(20)
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

            }
        });

        if (index.isNil) {

            var vol = (node.get(\vol) ?? {1}).linlin(0, 2, 0, 1);
            var spread = (node.get(\spread) ?? {1});
            var pan = (node.get(\center) ?? {0}).linlin(-1, 1, 0, 1);

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
                            log.("spread: %".format(ctrl.value));
                        })
                        .maxSize_(Size(30,30))
                        .value_(spread),
                        StaticText().string_("spread").align_(\center)
                    ),
                    nil,
                    VLayout(
                        Knob().action_({|ctrl|
                            var val = ctrl.value.linlin(0, 1, -1, 1);
                            node.set(\center, val);
                            log.("center: %".format(val));
                        })
                        .maxSize_(Size(30,30))
                        .value_(pan),
                        StaticText().string_("center").align_(\center)
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
                            Button().states_([  ["↓", nil, Color.clear]  ]).action_({
                                moveDown.(index);
                            })
                            .maxWidth_(50),
                            Button().states_([  ["↑", nil, Color.clear]  ]).action_({
                                moveUp.(index);
                            })
                            .maxWidth_(50),


                            // TODO: this is a bit hacky and should be refactored
                            Button().states_( [ [obj.name, nil, Color.clear] ] ).action_({|ctrl|
                                if (obj.type == 'vst') {
                                    obj['ctrl'].editor
                                }{
                                    var ctrl = obj['ctrl'];
                                    if (ctrl.view.notNil) {
                                        var key = 'ui/' ++ ctrl.view;
                                        if (Module.exists(key)) {
                                            Ui(ctrl.view).gui(fxnode, index);
                                        } {
                                            "custom view does not exists: %".format(key).warn;
                                            Ui('sgui').gui(fxnode, index)
                                        }
                                    }{
                                        Ui('sgui').gui(fxnode, index)
                                    }

                                }
                            })
                            .mouseDownAction_({|ctrl, x, y, mod, num, count|
                                if (obj.type == 'vst') {
                                    // ctrl key
                                    if (mod == 262144) {
                                        Ui('sgui').gui(fxnode, index)
                                    };
                                    // alt key
                                    if (mod == 524288) {
                                        obj['ctrl'].gui
                                    }
                                }
                            })
                            //.focusColor_(Color.red)

                            ,
                            Button().states_([  [nil, nil, Color.clear]  ]).action_({
                                node.fx(index, nil)
                            })
                            .maxWidth_(50)
                            .icon_(Image.new(App.librarydir ++ "images/noun_Delete_1982479.png")),
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

                    fxmenu.view(fxnode),

                    Button()
                    .states_( [ [nil, nil, Color.clear] ] )
                    .toolTip_("record")
                    .maxWidth_(35)
                    .action_({|ctrl|
                        fxnode.rec(5)
                    })
                    .icon_( Image.new(App.librarydir ++ "images/noun_Record_1939983.png")  ),

                    presets.view(node),

                    Button()
                    .maxWidth_(35)
                    .states_( [ [nil, nil, Color.clear] ] )
                    .toolTip_("save")
                    .action_({
                        node.print
                    })
                    .icon_(Image.new(App.librarydir ++ "images/noun_print_2120752.png"))

                ),
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
}
)
