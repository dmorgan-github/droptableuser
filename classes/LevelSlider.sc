LevelSlider : View {

    var currentval;
    var li, nb, valueView, nbView, labelView, slider, stack;
    var spec, precision = 0.001;

    *new {|label, spec, color|
        ^super.new().initNiceSlider(label, spec, color);
    }

    value_ {|val|
        currentval = val;
        valueView.string = val.trunc(precision);
        li.value = spec.unmap(currentval);
        nb.value = currentval;
    }

    value {
        ^currentval
    }

    valueAction_ {|anInt|
		this.value_(anInt);
		action.value(this);
	}

    style_ {|val|
        li.style = val
    }

    initNiceSlider {|argLabel, argSpec, argColor|

        var color = argColor ?? {Color.rand};
        var sliderView = View();

        spec = argSpec;
        li = LevelIndicator()
        .style_(\continuous)
        .meterColor_(color.alpha_(0.5))
        .warningColor_(color.alpha_(0.5))
        .criticalColor_(color.alpha_(0.5))
        .background_(color.alpha_(0.2));

        nb = NumberBox();
        valueView = StaticText();

        nbView = View().layout_(
            HLayout(
                nb
                .minDecimals_(3)
                .clipLo_(spec.minval)
                .clipHi_(spec.maxval)
                .action_({|ctrl|
                    var val = ctrl.value;
                    li.value = spec.unmap(val);
                    valueView.string_(val);
                    currentval = val;
                    action.value(this);
                    stack.index = 0;
                })
            )
            .margins_(3).spacing_(0)
        );

        labelView = StaticText().string_("%: ".format(argLabel));

        slider = StackLayout(
            View().layout_(HLayout(labelView, valueView, nil).margins_(3).spacing_(0)),
            li,
            nil
        )
        .mode_(\stackAll)
        .margins_(0)
        .spacing_(0);

        stack = StackLayout(
            sliderView
            .layout_(slider)
            .mouseMoveAction_({|ctrl, x, y, mod|
                //var val = x.linlin(0, ctrl.bounds.width, 0, 1);
                var val = x.linlin(0, li.bounds.width, 0, 1);
                var mappedVal = spec.map(val);
                if (mod == 0) {
                    li.value = val;
                    valueView.string_(mappedVal.trunc(precision));
                    nb.value = mappedVal;
                    currentval = mappedVal;
                    action.value(this);
                };
                true;
            })
            .mouseDownAction_({|ctrl, x, y, mod, num, count|
                var val = spec.default;
                if (count == 2) {
                    li.value = spec.unmap(val);
                    valueView.string_(val.trunc(precision));
                    nb.value = val;
                    currentval = val;
                    action.value(this);
                } {
                    if (mod == 0) {
                        //var val = x.linlin(0, ctrl.bounds.width, 0, 1);
                        var val = x.linlin(0, li.bounds.width, 0, 1);
                        var mappedVal = spec.map(val);
                        li.value = val;
                        valueView.string_(mappedVal.trunc(precision));
                        nb.value = mappedVal;
                        currentval = mappedVal;
                        action.value(this);
                        true;
                    };
                };
            }),
            nbView
        )
        .mode_(\stackOne)
        .margins_(0)
        .spacing_(0);

        ^this.layout_(
            stack
            .margins_(0)
            .spacing_(0)
        )
        .mouseDownAction_({|ctrl, x, y, mod, num, count|
            if (mod == 262144) {
                nbView.resizeTo(sliderView.sizeHint.width, sliderView.sizeHint.height);
                stack.index = 1;
            };
            true;
        });
	}
}