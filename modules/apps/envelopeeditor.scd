
~env = Env.perc.discretize(1024).plot
~buf = Buffer.sendCollection(s, env, 1);

~node = NodeProxy.audio;
~node[0] = {

	var freq = \freq.kr(432).lag(0.1);
	var rate = \rate.kr(1).lag(0.1);
	var buf = \env.kr(0);

	var sig = SinOsc.ar(freq);
	//var phase = Env([0,0, BufFrames.ir(buf)],[0,1], \lin).ar(gate: Impulse.ar(rate.reciprocal), timeScale: rate);
	var phase = Phasor.ar(Impulse.ar(1), BufRateScale.kr(buf), 0, BufFrames.kr(buf) );
	var env = BufRd.ar(1, buf, phase, 0);
	sig!2 * env;
};

~buf.setn(0, env );
node.set(\env, buf);
node.set(\rate, 1);
node.set(\freq, 432);




//var env = Env.perc.discretize;
//var buf = Buffer.sendCollection(s, env, 1);
//var node = NodeProxy.audio;
(

(
view: {arg name, envir;

	var node = (); //NodeProxy.audio.quant_(1.0);
	var buf = (); //Buffer.sendCollection(s, Env.perc.discretize(1024), 1)

	var font = Font("Courrier New", 10);
	var height = 20;
	var view = View().layout_(VLayout().margins_(2).spacing_(2)).onClose_({
		node.stop;
		node.clear;
		buf.free;
	});
	var status = StaticText().font_(font).string_("");

	var main = {

		var view = View().layout_(VLayout().margins_(2).spacing_(2));

		view.layout.add(Slider()
			.orientation_(\horizontal)
			.action_({arg ctrl;
				var val = ctrl.value.linexp(0,1, 20, 20000);
				node.set(\freq, val);
			})
			.maxHeight_(height)
			.value_(432.explin(20, 20000, 0, 1))
		);

		view.layout.add(

			HLayout(

				EnvelopeView()
				.fixedSize_(200@100)
				.keyDownAction_({arg view, char, modifiers, unicode, keycode, key;

					if (key == 16777219) {

						var xVals = view.value[0];
						var yVals = view.value[1];
						var remove = view.selection;

						remove.reverseDo({arg index;
							xVals.removeAt(index);
							yVals.removeAt(index);
						});

						view.valueAction_([xVals, yVals]);
					};
				})
				.mouseDownAction_({arg view, x, y, modifiers, buttonNumber, clickCount;

					var width = view.bounds.width;
					var height = view.bounds.height;

					if (clickCount == 2) {

						var vals;
						var xVals, yVals;
						var nearest, index;
						var newX, newY;

						x = x.linlin(0, width, 0, 1);
						y = y.linlin(0, height, 0, 1);
						vals = view.value;

						xVals = vals[0];
						yVals = vals[1];

						nearest = x.nearestInList(xVals);
						index = xVals.indexOf(nearest);
						if (x > nearest) {
							index = index + 1;
						};
						newX = xVals.insert(index, x);
						newY = yVals.insert(index, 1-y);

						view.valueAction_([newX, newY]);
					}
				})
				.drawLines_(true)
				.selectionColor_(Color.red)
				.drawRects_(true)
				.resize_(5)
				.step_(0.05)
				.thumbSize_(10)
				.keepHorizontalOrder_(true)
				.value_([[0.0, 0.1, 1.0],[0.0,1.0,0.0]])
				.action_({arg ctrl;
					buf.setn(0, ctrl.asEnv.discretize(1024) );
				}),

				Slider().action_({arg ctrl;
					var val = ctrl.value.linlin(0,1, 0.1, 10);
					node.set(\rate, val);
				})
				.maxWidth_(20)
				.value_(1.linlin(0.1, 10, 0, 1))
			);
		);

		view;
	};

	view.layout.add(StaticText().string_(name).font_(font));
	view.layout.add(
		HLayout(

			View().minWidth_(50),

			Button()
			.fixedSize_(30@height)
			.states_([ ["play"], ["stop"] ])
			.font_(font)
			.string_("play")
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					node.play;
				} {
					node.stop;
				}
			}),

			Button()
			.fixedSize_(30@height)
			.font_(font)
			.string_("doc")
			.mouseDownAction_({arg ctrl; node.document; })
		)
	);

	view.layout.add(main.());
	view.layout.add(status);
	view;
}

)[\view].(\bobo, currentEnvironment).front;


)

/*
node[0] = {

	var freq = \freq.kr(432).lag(0.1);
	var rate = \rate.kr(1).lag(0.1);
	var buf = \env.kr(0).lag(0.1);
	var sig = SinOsc.ar(freq);
	var phase = Env([0,0, BufFrames.kr(buf)],[0,1], \lin).ar(gate: Impulse.ar(rate.reciprocal), timeScale: rate);
	//var phase = Phasor.ar(Impulse.kr(1), 1, 0, 1 );
	var env = BufRd.ar(1, buf, phase, 0);
	sig!2 * env;
};

buf.setn(0, env );
node.set(\env, buf);
node.set(\rate, 1);
node.set(\freq, 432);

view.front;
node.play;
*/




