ControlSpec.specs[\osc1f1] = ControlSpec(1, 8, \lin, 1);
ControlSpec.specs[\osc1f2] = ControlSpec(1, 8, \lin, 1);

ControlSpec.specs[\osc2f1] = ControlSpec(1, 8, \lin, 1);
ControlSpec.specs[\osc2f2] = ControlSpec(1, 8, \lin, 1);

ControlSpec.specs[\osc3f1] = ControlSpec(1, 8, \lin, 1);
ControlSpec.specs[\osc3f2] = ControlSpec(1, 8, \lin, 1);

ControlSpec.specs[\osc1fcurve] = ControlSpec(-20, 20, \lin, 0.1);
ControlSpec.specs[\osc2fcurve] = ControlSpec(-20, 20, \lin, 0.1);
ControlSpec.specs[\osc3fcurve] = ControlSpec(-20, 20, \lin, 0.1);
ControlSpec.specs[\osc4fcurve] = ControlSpec(-20, 20, \lin, 0.1);


(

var controls = SynthDescLib.at(\m2).controls
.select({arg ctrl; (ctrl.name != \trig) and: (ctrl.name != \out)  });

var cv;
var w = Window.new("control", Rect(128, 64, 340, 460));
w.front;

cv = ScrollView(w, w.view.bounds)
	.autohidesScrollers_(true)
	.hasVerticalScroller_(true)
	.hasHorizontalScroller_(true);

cv.decorator_(FlowLayout(cv.bounds));

controls.do({arg ctrl;

	//[0.001, 2000, \exp, 0.1, 220, "hz"].asSpec;
	var spec = ControlSpec.specs[ctrl.name.asSymbol] ? ControlSpec.new;

	currentEnvironment[ctrl.name.asSymbol] = ctrl.defaultValue;

	EZSlider.new(cv, Rect(10, 10, 300, 15), ctrl.name.asString, controlSpec: spec, initVal: ctrl.defaultValue)
	.action_({arg slider;
		currentEnvironment[ctrl.name.asSymbol] = slider.value;
	});

	cv.decorator.nextLine;

	( "\\" ++ ctrl.name.asSymbol ++ ", Pfunc({~" ++ ctrl.name ++ " ? " + ctrl.defaultValue + "}),").postln;
})

)