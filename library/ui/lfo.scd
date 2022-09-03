//~nodelfos = Order.new
(
func: {|node|

    var nodelfos = node.lfos;// Order.new;
    var height = 19;
    var lfoview;
    var view;
    var lfos;
    var shapes = ['sine', 'tri', 'square', 'ramp+', 'ramp-', 'rand'];

    view = View().layout_(VLayout().margins_(0).spacing_(2));

    lfoview = {|num|

        var lfoinfo;
        var lfo;
        var view, lforangeview;
        var minview, maxview, lfoshape, propview, lfofreqview;
        var deleteview;
        var spec;
        var update;

        deleteview = Button().states_( [ ["x", nil, Color.grey.alpha_(0.5)] ] )
        .maxWidth_(25)
        .action_({|ctrl|
            var prop = nodelfos[num]['prop'];
            node.set(prop, nil);
            propview.value = "";
            nodelfos[num] = ();
        });

        minview = NumberBox()
        .maxWidth_(80)
        .background_(Color.clear)
        .action_({|ctrl| update.(); })
        .minWidth_(50);

        maxview = NumberBox()
        .maxWidth_(80)
        .background_(Color.clear)
        .action_({|ctrl| update.(); })
        .minWidth_(50);

        lfoshape = PopUpMenu()
        .background_(Color.clear)
        .items_(shapes)
        .action_({|ctrl| update.(); });

        propview = TextField()
        .background_(Color.clear)
        .minWidth_(80)
        .action_({|ctrl|

            var prop = ctrl.value.asSymbol;
            var val = node.get(prop);
            spec = node.getSpec(prop);

            if (spec.notNil) {
                nodelfos[num]['prop'] = prop;

                minview.clipLo = spec.minval;
                minview.clipHi = spec.maxval;

                maxview.clipLo = spec.minval;
                maxview.clipHi = spec.maxval;

                if (val.isNumber) {
                    minview.value = val;
                    maxview.value = val;
                };

                update.();
            };
        });

        lfofreqview = LevelSlider(\freq, [0.001, 10, \exp, 0, 0.001].asSpec, Color.rand)
        .minWidth_(80)
        .action_({|ctrl| update.(); });

        if (nodelfos[num].isNil) {
            lfoinfo = ();
            nodelfos.put(num, lfoinfo);
        }{
            lfoinfo = nodelfos[num];
            minview.value = lfoinfo['min'] ?? 0;
            maxview.value = lfoinfo['max'] ?? 0;
            lfoshape.value = if (lfoinfo['shape'].isNil) {0}{ shapes.indexOf(lfoinfo['shape'].asSymbol) };
            lfofreqview.value = lfoinfo['freq'] ?? 0.001;
            propview.value = lfoinfo['prop'] ?? ""
        };

        update = {

            var func;
            var shape = lfoshape.item.asSymbol;
            var prop;

            if (lfo.isNil) {
                lfo = NodeProxy();
                lfo[0] = { SinOsc.ar(\lfofreq.kr(0) )  };
                lfo.filter(1, {|in| in.range(\min.kr(0), \max.kr(1))  });
            };

            lfoinfo[\shape] = shape;
            lfoinfo[\min] = minview.value;
            lfoinfo[\max] = maxview.value;
            lfoinfo[\freq] = lfofreqview.value;

            lfo[0] = {
                switch(shape,
                    \tri, {
                        LFTri.ar(\lfofreq.kr(0))
                    },
                    \square, {
                        LFPulse.ar(\lfofreq.kr(0))
                    },
                    'ramp+', {
                        LFSaw.ar(\lfofreq.kr(0))
                    },
                    'ramp-', {
                        LFSaw.ar(\lfofreq.kr(0).neg)
                    },
                    'rand', {
                        LFNoise2.ar(\lfofreq.kr(0));
                    },
                    { SinOsc.ar(\lfofreq.kr(0)) }
                );
            };
            lfo.set(\min, lfoinfo[\min]);
            lfo.set(\max, lfoinfo[\max]);
            lfo.set(\lfofreq, lfoinfo[\freq]);

            prop = lfoinfo['prop'];
            node.set(prop, lfo);
        };

        lforangeview = HLayout(minview, maxview).margins_(0).spacing_(2);
        view = View().layout_(HLayout().margins_(0).spacing_(2));
        view.layout.add(propview);
        view.layout.add(lfoshape);
        view.layout.add(lfofreqview);
        view.layout.add(lforangeview);
        view.layout.add(deleteview);
        view.maxHeight_(height);
        view;
    };

    8.do({|i|
        view.layout.add(lfoview.(i));
    });

    view.layout.add(nil);
    view

}
)
