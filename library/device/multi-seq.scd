/////////////////////////////////////////////
// sequencer engine
(
Pdef(\seq,
    Plazy({
        var num = 0;
        Plazy({|evt|
            var dur = evt.seq.ifnil([1]).asArray.wrapAt(num);
            var reps = evt.repeats.ifnil([1]).asArray.wrapAt(num).max(1);
            var deg = evt.degree.ifnil([0]).asArray.wrapAt(num);
            var prob = evt.prob.ifnil([1]).asArray.wrapAt(num);
            num = num + 1;
            Pbind(
                \dur, Pn(dur/reps, reps).max(0.125),
                \degree, deg,
                \bar, Pfunc({
                    if (prob.coin) {1}{\}
                }),
                \foo, Pfunc({|ev|
                    var seqid = ev[\seqid];
                    if (seqid.notNil) {
                        {
                            Evt.trigger(seqid.asSymbol, num-1)
                        }.defer()
                    };
                    1
                })
            )
        }).repeat
    })
);

/////////////////////////////////////////////
// sequencer ui
Fdef(\sequi, {|source, props|

    var view = View();
    var listener, updater, ctrls;

    var sliders = props.collect({|prop|
        MultiSliderView().showIndex_(true);
    });

    var specs = props.collect({|prop|
        source.getSpec(prop);
    });

    var vals = props.collect({|prop, i|
        specs[i].unmap(source.get(prop));
    });

    var seqid = source.get(\seqid);

    listener = {|obj, op, pairs|

        if (op == \set) {
            var dict = pairs.asDict;
            dict.keysValuesDo({|k, v|
                if (props.includes(k)) {
                    var index = props.indexOf(k);
                    var spec = specs[index];
                    var vals = spec.unmap(v);
                    var slider = sliders[index];
                    slider.size_(vals.size);
                    slider.value_(vals)
                }
            })
        }
    };

    updater = {|view, prop, val|
        var spec = source.getSpec(prop);
        if (spec.notNil) {
            var v = spec.map(val);
            source.set(prop, v);
        };
    };

    ctrls = props.collect({|prop, i|
        var slider = sliders[i];
        var val = vals[i];
        var size = val.size;
        slider
        .size_(size)
        .elasticMode_(1)
        .strokeColor_(Color.rand)
        .fillColor_(Color.rand)
        .action_({|ctrl|
            var val = ctrl.value;
            view.changed(prop, val);
        })
        .value_(val)
    });

    if (seqid.notNil) {
        Evt.on(seqid.asSymbol, \a, {|data|
            ctrls.do({|ctrl|
                ctrl.index = data.mod(ctrl.value.size);
            })
        });
    };

    view.layout_(VLayout(*ctrls.collect({|ctrl, i|
        VLayout(
            StaticText().string_(props[i]),
            ctrl
        )
    })))
    .minWidth_(300).minHeight_(150);

    view.addDependant(updater);
    source.addDependant(listener);

    view.onClose_({
        \onClose.debug(\view);
        source.removeDependant(listener);
        Evt.off(\num, \a);
    })
    .name_(seqid)
    .front;
})
)
