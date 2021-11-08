/*
EzKnob {

    var knobView, labelView, nbView, view, ctrlSpec;

    *new {arg label="", spec=[0,1,\lin,0,0].asSpec;
        ^super.new.init(label, spec);
    }

    init {arg argLabel, argSpec;
        ctrlSpec = argSpec;
        view = View().layout_(VLayout(
            labelView = StaticText().string_(argLabel).align_(\center),
            knobView = Knob().mode_(\vert).action_({arg ctrl;
                nbView.value = ctrlSpec.map(ctrl.value);
            }),
            nbView = NumberBox().action_({arg ctrl;
                knobView.valueAction_(ctrlSpec.unmap(ctrl.value));
            })
        ).margins_(1).spacing_(1));
        ^this
    }

    spec_ {arg val;
        ctrlSpec = val;
        ^this;
    }

    action_ {arg func;
        knobView.action = {arg ctrl;
            func.(ctrl, ctrlSpec);
            nbView.value = ctrlSpec.map(ctrl.value);
        };
        ^this;
    }

    label_ {arg val;
        labelView.string = val;
        ^this;
    }

    value_ {arg val;
        knobView.value = ctrlSpec.unmap(val);
        nbView.value = val;
        ^this;
    }

    format_ {arg cb;
        cb.(knobView, labelView, nbView);
        ^this;
    }

    toView {
        ^view;
    }
}
*/