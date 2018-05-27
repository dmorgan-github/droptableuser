(
view: {arg name, envir;

	var node = NodeProxy.audio.quant_(1.0);
	var buf = Buffer.sendCollection(s, Env.perc.discretize(1024), 1);

	var height = 20;
	var view = View().layout_(VLayout().margins_(2).spacing_(2)).onClose_({
		node.stop;
		node.clear;
		buf.free;
	});
	var status = StaticText().string_("");

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

	view.layout.add(StaticText().string_(name));
	view.layout.add(
		HLayout(

			View().minWidth_(50),

			Slider()
			.orientation_(\horizontal)
			.thumbSize_(10)
			.fixedSize_(50@height)
			.value_(1.linlin(0.1, 8, 0, 1))
			.action_({arg ctrl;
				var val = ctrl.value.linlin(0, 1, 0.1, 8);
				node.fadeTime = val;
				status.string_("fadetime: " ++ val.asString);
			}),

			Button()
			.fixedSize_(30@height)
			.states_([ ["play"], ["stop"] ])
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
			.string_("doc")
			.mouseDownAction_({arg ctrl; node.document; })
		)
	);

	node.fadeTime = 1;
	node[0] = {
		var freq = \freq.kr(432).lag(0.1);
		var rate = \rate.kr(1).lag(0.1);
		var buf = \env.kr(0).lag(0.1);
		var sig = SinOsc.ar(freq);
		var phase = Env([0,0, BufFrames.kr(buf)],[0,1], \lin).ar(gate: Impulse.ar(rate.reciprocal), timeScale: rate);
		var env = BufRd.ar(1, buf, phase, 0);
		sig!2 * env * AmpCompA.kr(freq) * \amp.kr(0.1);
	};

	node.set(\env, buf);
	node.set(\rate, 1);
	node.set(\freq, 432);

	envir[name] = node;
	view.layout.add(main.());
	view.layout.add(status);

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
}

)



