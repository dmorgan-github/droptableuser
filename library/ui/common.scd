(
Fdef(\baseview, {arg view, title, w, h;

	var mousey, mousex;
	var width = w ? view.sizeHint.width;
	var height = h ? view.sizeHint.height;
	var top = Window.screenBounds.height * 0.5;
	var left = Window.screenBounds.width * 0.3;
	var win = Window.new(title, bounds:Rect(left, top, width, height), border:false);
	var status = StaticText().string_("").background_(Color.black.alpha_(0.1));

	var viewListener = {arg view, key, value;
		var msg = "";
		if (key == \prop) {
			status.string = value[\val]
		}
	};

	var outerview = View().layout_(
		VLayout(
			View().layout_(
				HLayout(
					StaticText().string_(title),
					nil,
					Button().states_([ ["x", Color.white, nil] ])
					.action_({ win.close })
					.maxWidth_(15)
					.maxHeight_(15)
				).margins_(1).spacing_(0)
			).background_(Color.black.alpha_(0.1)),
			view,
			status;
		).margins_(1).spacing_(1)
	)
	.mouseDownAction_({arg ctrl, x, y;
		mousey = ctrl.sizeHint.height - y;
		mousex = x;
	})
	.mouseMoveAction_({arg ctrl, x, y;
		var height = ctrl.sizeHint.height;
		var top = ctrl.sizeHint.height - y;
		var left = win.bounds.left + x - mousex;
		var width = ctrl.sizeHint.width;
		top = win.bounds.top + (top - mousey);
		win.bounds = Rect(left, top, width, height);
		true;
	});

	view.addDependant(viewListener);
	win.layout = VLayout(outerview).margins_(0).spacing_(0);
	win.asView.palette_(QPalette.dark).onClose_({
		view.removeDependant(viewListener);
	});
});

Fdef(\ctrlview, {arg key, spec, color, val, cb;

	var controlSpec = spec;
	var myval = val ?? controlSpec.default;

	var stack, view;
	var font = Font(size:8);
	var label = if (key.asString.size > 0) {key ++ ": "}{""};
	var labelView = StaticText().string_(label)
	.font_(font)
	.stringColor_(Color.white)
	.toolTip_(label);

	var li, st, nb;
	var getValue = {}, setValue = {};

	if (myval.isNumber) {

		li = LevelIndicator().value_(controlSpec.unmap(myval));
		st = StaticText().string_(myval.trunc(0.001)).font_(font).stringColor_(Color.white);
		nb = NumberBox()
		.font_(font)
		.value_(myval)
		.background_(Color.white)
		.minDecimals_(3)
		.clipLo_(controlSpec.minval)
		.clipHi_(controlSpec.maxval);

		setValue = {|self, val|
			var unmap = controlSpec.unmap(val);
			li.value = unmap;
			st.string_(val.trunc(0.001));
			nb.value = val;
			myval = val;
		};

		getValue = {|self|
			myval;
		};

		stack = StackLayout(
			View()
			.layout_(
				StackLayout(
					View().layout_(HLayout(labelView, st, nil).margins_(1).spacing_(1)),
					li
					.style_(\continuous)
					.meterColor_(color.alpha_(0.5))
					.warningColor_(color.alpha_(0.5))
					.criticalColor_(color.alpha_(0.5))
					.background_(color.alpha_(0.2))
				)
				.mode_(\stackAll)
				.margins_(0)
				.spacing_(0)
			)
			.mouseMoveAction_({arg ctrl, x, y, mod;
				var val = x.linlin(0, ctrl.bounds.width, 0, 1);
				var mappedVal = controlSpec.map(val);
				if (mod == 0) {
					li.value = val;
					st.string_(mappedVal.trunc(0.001));
					nb.value = mappedVal;
					myval = mappedVal;
					cb.(key, mappedVal);
				};
				true;
			})
			.mouseDownAction_({arg ctrl, x, y, mod, num, count;
				var val = controlSpec.default;
				if (count == 2) {
					li.value = controlSpec.unmap(val);
					st.string_(val.trunc(0.001));
					nb.value = val;
					myval = val;
					cb.(key, val);
				} {
					if (mod == 0) {
						var val = x.linlin(0, ctrl.bounds.width, 0, 1);
						var mappedVal = controlSpec.map(val);
						li.value = val;
						st.string_(mappedVal.trunc(0.001));
						nb.value = mappedVal;
						myval = mappedVal;
						cb.(key, mappedVal);
						true;
					};
				};
			}),
			nb
			.action_({arg ctrl;
				var val = ctrl.value;
				li.value = controlSpec.unmap(val);
				st.string_(val);
				myval = val;
				cb.(key, val);
				stack.index = 0;
			}),
		).mode_(\stackOne)
		.margins_(0)
		.spacing_(0);

		view = View().layout_(HLayout(
			View()
			.layout_(stack)
			.mouseDownAction_({arg ctrl, x, y, mod, num, count;
				if (mod == 262144) {
					stack.index = 1;
				};
				true;
			}).fixedHeight_(25)
		).margins_(0).spacing_(1))
	} {
		var text = label + myval.asCompileString;
		var st = StaticText().string_(text).font_(font).stringColor_(Color.white);
		view = View().layout_(HLayout( st ).margins_(1).spacing_(1) ).fixedHeight_(25);
	};

	(
		getValue: getValue,
		setValue: setValue,
		asView: view
	);
});

Fdef(\playview, {arg node;

	var levelkey;
	var view;
	var font = Font(size:8);
	var slider = Slider();
	var levelView, setAmps, skipjack;
	var uv, preAmp = 0, postAmp = 0;
	var height = 20;

	view = View().layout_(
		HLayout(
			Button().states_([
				[">"],
				["[]"]
			]).action_({arg ctrl;
				if (ctrl.value == 1) {
					node.play(fadeTime:node.fadeTime);
				} {
					node.stop(fadeTime:node.fadeTime);
				}
			})
			.value_(node.isMonitoring.asInteger)
			.maxHeight_(height)
			.maxWidth_(25),

			slider
			.orientation_(\horizontal)
			.thumbSize_(7)
			.action_({arg ctrl;
				var msg;
				node.vol = ctrl.value;
				msg = "vol:" + node.vol.trunc(0.001);
				view.changed(\prop, (key:\vol, val:msg));
			})
			.value_(node.vol)
			.fixedSize_(Size(75, height))
			//.minWidth_(50)
			//.maxWidth_(75)
			.toolTip_("vol"),

			NumberBox()
			.action_({arg ctrl;
				var msg;
				node.fadeTime = ctrl.value;
				msg = "fadetime:" + node.fadeTime.trunc(0.001);
				view.changed(\prop, (key:\fadetime, val:msg));
			})
			.font_(font)
			.normalColor_(Color.white)
			.decimals_(2)
			.maxWidth_(35)
			.maxHeight_(height)
			.value_(node.fadeTime)
			.toolTip_("fade time"),

			NumberBox()
			.action_({arg ctrl;
				var msg;
				msg = "channel:" + ctrl.value;
				view.changed(\prop, (key:\channel, val:msg));
			})
			.font_(font)
			.normalColor_(Color.white)
			.decimals_(0)
			.maxWidth_(25)
			.maxHeight_(height)
			.value_(0)
			.toolTip_("channel"),

		).spacing_(1).margins_(1)
	);

	levelView = {|parent, bounds|

		var preCol = Color.yellow(1.0, 0.4);
		var postCol = Color.green(0.7, 0.4);
		var preSatCol = Color.red(1, 0.4);
		var satCol = Color.red(1, 0.6);

		uv = UserView(parent, bounds);
		uv.background_(Color(1,1,1,0));
		uv.acceptsMouse_(false);

		// horizontal for now:
		uv.drawFunc = { |uv|
			var bounds = uv.bounds;
			var maxwid = bounds.width - 4;
			var height = bounds.height - 4;
			var satPreLeft, satLeft;

			if (preAmp > 0) {
				Pen.color_(preCol);
				Pen.addRect(Rect(2,2, preAmp * maxwid, height));
				Pen.fill;
				if (preAmp > 1.0) {
					Pen.color_(preSatCol);
					satPreLeft = (1 - (preAmp - 1).clip(0, 1)) * maxwid;
					Pen.addRect(Rect( satPreLeft, 2, maxwid, height));
					Pen.fill;
				};
			};

			if (postAmp > 0) {
				Pen.color_(postCol);
				Pen.addRect(Rect(2,2, postAmp * maxwid, height));
				Pen.fill;
				if (postAmp > 1.0) {
					Pen.color_(satCol);
					satLeft = (1 - (postAmp - 1).clip(0, 1)) * maxwid;
					Pen.addRect(Rect( satLeft, 2, maxwid, height));
					Pen.fill;
				};
			};
		};
	};

	setAmps = {|pre = 0, post = 0|
		preAmp = pre.sqrt;
		postAmp = post.sqrt;
		uv.refresh;
	};

	levelView.(slider, slider.bounds.left_(0).top_(0).width_(75).height_(height));
	levelkey = (node.key ++ 'amp').asSymbol;

	Ndef(levelkey, {
		var decay = 0.99994;
		var inArray = InFeedback.ar(node.bus.index, node.bus.numChannels).asArray;
		var amps = A2K.kr(PeakFollower.ar(inArray, decay: decay));
		var max = 0;
		amps.do {|amp| max = max(max, amp)	};
		max;
	});

	OSCdef(node.key, {|msg|
		var vols = msg.copyToEnd(3);
		var preVol = vols[0];
		var postVol = if (node.monitor.isPlaying, node.vol, 0) * preVol;
		defer {
			setAmps.(preVol, postVol);
		};

	}, '/c_setn', Ndef(levelkey).server.addr, nil, [Ndef(levelkey).bus.index]);

	skipjack = SkipJack({
		Ndef(levelkey).server.listSendMsg(Ndef(levelkey).bus.getnMsg(1));
	}, 0.03, false, 'ProxyMeter');

	view.onClose_({
		[node.key, \playview, \release].postln;
		skipjack.stop;
		OSCdef(node.key).free;
		Ndef(levelkey).free;
	})
});

Fdef(\presetsview, {|node, cb|
	var num = 10;
	var size = 12;
	var grid, view;
	var buttons;
	buttons = num.collect({|i|
		Button()
		.states_([ [nil, nil, Color.clear.alpha_(1.5) ], [nil, nil, Color.red.alpha_(0.5) ] ])
		.action_({|ctrl|
			buttons.do({|btn, j|
				if (i != j) {
					if (btn.value == 1) {
						btn.states = [ [nil, nil, Color.green.alpha_(0.5) ], [nil, nil, Color.red.alpha_(0.5) ] ]
					};
					btn.value = 0;
				}
			});
			if (ctrl.value == 1) {
				cb.(i);
			}
		})
	});
	grid = GridLayout.rows(
		buttons//[0..7],
		//buttons[8..15]
	).margins_(0).spacing_(0);
	view = View().layout_(grid);
	view;
})
)