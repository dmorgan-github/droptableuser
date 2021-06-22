(
var foo = Require(App.librarydir ++ "ui/common.scd");
var numKnobs = 3 * 16;
var scrollView = ScrollView().minWidth_(400).name_("Twister");
var view = View().layout_(VLayout());
var list = List.new;
var map = W.current.knobMap;
W.current.keysValuesDo({|k, v|
    if (v.isKindOf(S)) {
        v.synthdef.controls.do({|c|
            var obj;
            var spec = [0, 1].asSpec;
            if (Spec.specs[c.name].notNil ) {
                spec = Spec.specs[c.name]
            };
            obj = (
                label: "%:%".format(k, c.name),
                node: v,
                prop: c.name,
                spec: spec
            );
            list.add(obj);
        })
    };
    if (v.isKindOf(D)) {
        v.controlNames.do({|c|
            var obj;
            var spec = [0, 1].asSpec;
            if (Spec.specs[c.name].notNil ) {
                spec = Spec.specs[c.name]
            };
            obj = (
                label: "%: %".format(k, c.name),
                node: v,
                prop: c.name,
                spec: spec
            );
            list.add(obj);
        })
    }
});
numKnobs.do({|i|

    var minnb;
    var maxnb;
    var valnb;
    var slider;
    var obj;
    var selected = 0;
    var warp;
    var hlayout;
    var spec = [0, 1].asSpec;
    var enabled = false;
    var val = 0;
    var func = {|src, what, val|
        slider.value = val;
        valnb.value = spec.map(val);
    };
    var tooltip = "";

    if (map[i].notNil) {
        obj = map[i];
        selected = list.selectIndices({|val| val.label == obj.label});
        selected = selected.first + 1;
        spec = obj[\spec];
        enabled = true;
        val = Twister.knobs(i).asMap.get(\val);
        Twister.knobs(i).addDependant(func);
        tooltip = obj[\label]
    };

    minnb = NumberBox().value_(spec.minval).minWidth_(30).enabled_(enabled)
    .action_({|ctrl|
        obj.spec.minval = ctrl.value;
        spec = obj.spec;
        Twister.knobs(i).cc(spec);
    });
    maxnb = NumberBox().value_(spec.maxval).minWidth_(30).enabled_(enabled)
    .action_({|ctrl|
        obj.spec.maxval = ctrl.value;
        spec = obj.spec;
        Twister.knobs(i).cc(spec);
    });
    valnb = NumberBox().value_(val).minWidth_(30).enabled_(enabled);
    slider = Slider().enabled_(enabled)
    .value_(spec.unmap(val))
    .orientation_(\horizontal)
    .minWidth_(51)
    .maxHeight_(20)
    .thumbSize_(10)
    //.shift_scale_(0.1)
    .step_(0.01)
    .action_({|ctrl|
        var val = ctrl.value.linlin(0, 1, 0, 127);
        Twister.knobs(i).ccMapFunc.(val);
        valnb.value_(spec.map(ctrl.value));
    });
    warp = PopUpMenu().items_(["lin", "exp"]).enabled_(enabled).action_({|ctrl|

        var val = ctrl.item.asSymbol;
        if (val == \exp) {
            if (spec.minval > 0 and: {spec.maxval > 0}) {
                obj.spec.warp = ctrl.item.asSymbol;
                spec = obj.spec;
                Twister.knobs(i).cc(spec);
            } {
                "exp warp not valid with zeros".warn;
            }
        } {
            obj.spec.warp = ctrl.item.asSymbol;
            spec = obj.spec;
            Twister.knobs(i).cc(spec);
        }
    })
    .value_(if (spec.warp.class == ExponentialWarp) {1}{0});

    hlayout = HLayout(
        StaticText().string_(i).minWidth_(13),
        PopUpMenu()
        .items_( [""] ++ list.collect(_.label))
        .value_(selected)
        .toolTip_(tooltip)
        .action_({|ctrl|

            if (obj.notNil) {
                // remove existing mapping
                obj.node.set(obj.prop, nil);
            };

            if (ctrl.value == 0) {
                minnb.value = 0;
                maxnb.value = 1;
                slider.value = 0;
                valnb.value = 0;
                ctrl.toolTip = "";

                minnb.enabled = false;
                maxnb.enabled = false;
                slider.enabled = false;
                valnb.enabled = false;
                warp.enabled = false;
            }{
                var num = ctrl.value-1;
                var new = list[num];

                minnb.value = spec.minval;
                maxnb.value = spec.maxval;
                slider.value = spec.unmap(spec.default);
                valnb.value = spec.default;
                warp.value = if (spec.warp.class == ExponentialWarp) {1}{0};
                minnb.enabled = true;
                maxnb.enabled = true;
                slider.enabled = true;
                valnb.enabled = true;
                warp.enabled = true;

                ctrl.toolTip = new[\label];
                Twister.knobs(i).cc(spec).label_(new[\label]);
                Twister.knobs(i).addDependant(func);
                new.node.set(new.prop, Twister.knobs(i).asMap);
                map.put(i, new);
                obj = new;
            }
        })
        .minWidth_(80)
        .onClose_({
            Twister.knobs(i).removeDependant(func);
        }),
        slider,
        valnb,
        minnb,
        maxnb,
        warp
    );
    view.layout.add(hlayout);
});
scrollView.canvas = view;
scrollView.front;
)