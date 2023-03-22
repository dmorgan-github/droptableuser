(
func: {|node, index|

    var sliders = ();
    var height = 20;
    var color = node.color ? Color.rand;
    var fxnode = if (node.respondsTo(\node)) { node.node }{ node };
    var scroll;
    var getSpec, getKeys, getGroups, getView;
    var nodewatcher;

    scroll = ScrollView().hasBorder_(false).autohidesScrollers_(true);

    getSpec = {|key|
        var specs = node.getSpec;
        var spec = if (specs.isNil) {nil} { specs[key] };
        if (spec.isNil) {
            spec = [0, 1, \lin, 0, 0].asSpec;
        };
        spec
    };

    getKeys = {

        var keys;
        keys = {

            if (index.notNil) {
                fxnode.objects[index].controlNames.collect({|cn| cn.name})
            } {
                var wtf;
                var except = List.new;
                var controlKeys;

                if (node.isKindOf(InstrProxy)){
                    var names = fxnode.controlNames.collect({|cn| cn.name.asSymbol });
                    except.addAll(names);
                };

                try({
                    //except.debug("except....");
                    node.controlKeys(except:except);
                }, {|err|
                    "node.controlKeys (use bufnum): %".format(err).postln;
                    err.throw;
                })
            };
        }.value;

        keys = keys
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
                //\amp,
                \spread,
                //\vol,
                \bend,
                \vel
            ].includes(key)
            or: {
                key.asString.beginsWith("wet")
            }
        }).asArray
    };

    getGroups = {

        var dict, keys;
        var returnVal = List.new;

        dict = ();
        keys = getKeys.();

        keys.do({|key|
            var spec, unit, list;
            spec = getSpec.(key);
            unit = spec.units.asSymbol;
            list = dict[unit];
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

        groups.do({|assoc|

            var group = assoc.key;
            var mykeys = assoc.value;

            view.layout.add(
                StaticText()
                .string_(group.asString.toUpper)
                .stringColor_(Color.white)
                .background_(Color.clear)
            );

            mysliders = mykeys.collect({|key, i|
                var spec = getSpec.(key);
                var val = node.get(key);
                if (val.isNil) {
                    val = spec.default;
                };
                [key, LevelSlider(key, spec:spec, color:color)
                    .maxHeight_(height)
                    .action_({|ctrl|
                        var val = node.get(key);
                        if (val != ctrl.value) {
                            node.set(key, ctrl.value);
                        }
                    })
                    .value_(val)
                ]
            }).flatten;

            mysliders.pairsDo({|key, slider|
                sliders[key] = slider;
                view.layout.add(slider);
            });
        });

        view.layout.add(nil);
        view
    };

    try({
        scroll.canvas = getView.();
    }, {|err|
        "% getView".format(err).error;
    });

    nodewatcher = {|obj, what, vals|
        if (what == \set) {
            vals.pairsDo({|k, v|
                if (v.isNumber) {
                    var slider = sliders[k];
                    if (slider.notNil and: {slider.value != v}) {
                        {
                            slider.value = v;
                        }.defer
                    };
                }
            })
        }
    };

    node.addDependant(nodewatcher);
    scroll
    .background_(Color.black)
    .onClose_({
        node.removeDependant(nodewatcher);
    })
}
)
