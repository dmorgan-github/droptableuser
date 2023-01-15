(
func: {|node, prop|

    var view;
    var spec;
    var val;
    var key;
    var num = 64;
    var dur = 16;
    var min = 0, max = 1;
    var durkey;
    var minkey;
    var maxkey;
    var msv;

    val = 0.dup(num);
    if (prop.notNil) {
        prop = prop.asSymbol;
        key = "%_env_vals".format(prop).asSymbol;
        durkey = "%_env_dur".format(prop).asSymbol;
        minkey = "%_env_min".format(prop).asSymbol;
        maxkey = "%_env_max".format(prop).asSymbol;
        spec = node.getSpec[prop];
        if (node.get(key).notNil) {
            val = node.get(key);
        } {
            node.set(key, val)
        };
        if (node.get(durkey).notNil) {
            dur = node.get(durkey);
        };
        if (node.get(minkey).notNil) {
            min = node.get(minkey);
        };
        if (node.get(maxkey).notNil) {
            max = node.get(maxkey);
        };
        if (min.isNil) {
            min = spec.minval;
        };
        if (max.isNil) {
            max = spec.maxval;
        };
    };

    msv = MultiSliderView();

    view = View().layout_(VLayout(

        msv
        .elasticMode_(1)
        .thumbSize_(0)
        .drawLines_(true)
        .size_(64)
        .background_(Color.clear)
        .action_({|ctrl|
            if (prop.notNil) {
                node.set(key, ctrl.value)
            };
        })
        .value_(val),

        HLayout(
            nil,
            HLayout(
                StaticText().string_(prop)
                /*
                    TextField()
                    .minWidth_(50)
                    .maxWidth_(50)
                    .action_({|ctrl|
                        prop = ctrl.value.asSymbol;
                        key = "%_env_vals".format(prop).asSymbol;
                        durkey = "%_env_dur".format(prop).asSymbol;
                        minkey = "%_env_min".format(prop).asSymbol;
                        maxkey = "%_env_max".format(prop).asSymbol;
                        spec = node.getSpec[prop];
                        node.set(key, msv.value); 
                        node.set(prop, Ptrn.env(key, dur).linlin(0, 1, min, max));
                    })
                    .string_(prop)
                */
            ),
            nil,
            HLayout(
                nil,
                StaticText().string_("min"),
                NumberBox()
                .action_({|ctrl|
                    min = ctrl.value;
                    node.set(minkey, min);
                    node.set(prop, Ptrn.env(key, dur).linlin(0, 1, min, max));
                })
                .maxWidth_(30)
                .value_(min)
            ),
            HLayout(
                nil,
                StaticText().string_("max"),
                NumberBox()
                .action_({|ctrl|
                    max = ctrl.value;
                    node.set(maxkey, max);
                    node.set(prop, Ptrn.env(key, dur).linlin(0, 1, min, max));
                })
                .maxWidth_(30)
                .value_(max)
            ),
            HLayout(
                nil,
                StaticText().string_("dur"),
                NumberBox()
                .action_({|ctrl|
                    dur = ctrl.value;
                    node.set(durkey, dur);
                    node.set(prop, Ptrn.env(key, dur).linlin(0, 1, min, max));
                })
                .maxWidth_(30)
                .value_(dur)
            )
        )
    )
    .spacing_(5)
    .margins_(5)
    );

    view
    .background_(Color.clear)
}
)

