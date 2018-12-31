(
{
    var noise = WhiteNoise.ar.range(-0.2, 0.4);
    var integrate = Wrap.ar(Integrator.ar(noise), -1, 1);
    var phasor = Phasor.ar(Impulse.kr(0), noise, -1);
    [noise, integrate, phasor]
}.plot(0.001)
)

(
{
    var noise = WhiteNoise.ar.range(-0.2, 0.4);
    var integrate = Wrap.ar(Integrator.ar(noise), -1, 1);
    var phasor = Phasor.ar(Impulse.ar(0), noise, -1);
    [noise, integrate, phasor]
}.plot(0.001)
)


(
var row = {

var steps = 8;
var maxSteps = 8;

var buttons = List.new(maxSteps);
var gridButton = {arg num;

	var myView = View().layout_(HLayout().margins_(1).spacing_(0));
	myView.layout.add(
		Button()
		.maxWidth_(20)
		.maxHeight_(20)
		.states_([ [nil, nil, Color.grey], [nil, nil, Color.white] ] )
		.action_({arg ctrl;
			if (ctrl.value == 0) {
				//obj.onCellDisabled(ctrl, row, col);
			} {
				//obj.onCellEnabled(ctrl, row, col, degree);
			}
		})
	);
	buttons.add(myView);
	myView;
};

var view = View().layout_(HLayout()).background_(Color.rand);
var stepsView = View().layout_(HLayout());
var ctrls = View().layout_(HLayout(
	NumberBox().minWidth_(25).value_(1),
	PopUpMenu(),
	MultiSliderView()
	.minWidth_(70)
	.maxHeight_(20)
	.thumbSize_(8)
	.size_(maxSteps)
	.value_(Array.fill(maxSteps, 1)),
	Slider().orientation_(\horizontal).minWidth_(50).maxHeight_(20).action_({arg ctrl;
		var num = ctrl.value.linlin(0,1, 0,maxSteps).round(1);
		steps = num;

		(0..maxSteps-1).do({arg i;
			var button = buttons[i];
			if ((i+1) <= steps) {
				button.enabled_(true);
			} {
				button.enabled_(false);
				button.children[0].value_(0);
			}
		});
	}).value_(1),
	Knob().maxWidth_(25).value_(1),
));

steps.do({arg i;
	stepsView.layout.add(gridButton.(0, i));
});

view.layout.add(ctrls);
view.layout.add(stepsView);
	view;
};

var numrows = 4;
var view = View().layout_(VLayout());

numrows.do({arg i;
	view.layout.add(row.());
});
view.front;
)
