(
func: {|node, prop|

    var view;
    var val;
    var key;
    var num = 16;
    var min = 0, max = 1;
    var minkey;
    var maxkey;
    var numkey;
    var msv;

    val = 0.dup(num);
    if (prop.notNil) {

        prop = prop.asSymbol;
        key = "%_step_vals".format(prop).asSymbol;
        minkey = "%_step_min".format(prop).asSymbol;
        maxkey = "%_step_max".format(prop).asSymbol;
        numkey = "%_step_num".format(prop).asSymbol;

        if (node.get(key).notNil) {
            val = node.get(key);
        } {
            node.set(key, val)
        };

        if (node.get(minkey).notNil) {
            min = node.get(minkey);
        };
        if (node.get(maxkey).notNil) {
            max = node.get(maxkey);
        };
        if (node.get(numkey).notNil) {
            num = node.get(numkey);
        };
        node.set(prop, Ptrn.wrapAt(Pkey(key), Pseries(0, 1)).linlin(0, 1, min, max).round);

    };
 
    msv = MultiSliderView();

    view = View().layout_(VLayout(

        msv
        .isFilled_(true)
        .elasticMode_(1)
        //.thumbSize_(3)
        .drawLines_(false)
        .size_(num)
        .background_(Color.clear)
        .action_({|ctrl|
            node.set(key, ctrl.value);
        })
        .value_(val),

        HLayout(
            nil,
            HLayout(
                StaticText().string_(prop)
            ),
            nil,
            HLayout(
                nil,
                StaticText().string_("min"),
                NumberBox()
                .action_({|ctrl|
                    min = ctrl.value;
                    node.set(minkey, min);
                    node.set(prop, Ptrn.wrapAt(Pkey(key), Pseries(0, 1)).linlin(0, 1, min, max).round );
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
                    node.set(prop, Ptrn.wrapAt(Pkey(key), Pseries(0, 1)).linlin(0, 1, min, max).round );
                })
                .maxWidth_(30)
                .value_(max)
            ),
            HLayout(
                nil,
                StaticText().string_("num"),
                NumberBox()
                .action_({|ctrl|
                    num = ctrl.value.asInteger;
                    node.set(numkey, num);
                    val = val[..(num-1)];
                    msv.valueAction_(val)
                })
                .maxWidth_(30)
                .value_(num)
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

