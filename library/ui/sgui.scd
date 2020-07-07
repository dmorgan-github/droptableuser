/*
stethescope in custom ui
(
w = Window.new("scope in app", Rect(20, 20, 600, 700));
i = View().layout_(VLayout());
b = Button().states_([["left stuff", Color.grey, Color.white]]);
w.layout = HLayout(b, i);
c = Stethoscope.new(s, view:i);
w.onClose = { c.free };
w.front;
)
*/

(
Fdef(\sgui, {arg synth;

	var specs = Halo.at(synth, \spec);
	var key = synth.key;
	var server = Server.default;
	var decay = 60;
	var rate = 30;
	var bus = synth.node.bus.index;
	var addAction = \addToTail;
	var target = synth.node.group;

	var decayrate = {arg value;
		value.neg.dbamp ** server.sampleRate.reciprocal;
	};

	var osckey = "/%levels".format(key).asSymbol;

	var watcher = SynthDef((key ++ '_amps').asSymbol, {arg decay=0.99994, rate=20;
		var in = In.ar(bus, 2);
		var pf = PeakFollower.ar(in, decay);
		var imp = Impulse.kr(rate);
		SendReply.kr(imp, osckey, [pf, pf.lag(0, 3)].flatten, 1000.rand);
	}).play(target, addAction:addAction);

	var levelView = {

		var lileft = LevelIndicator()
		.warning_(-2.dbamp)
		.critical_(0.dbamp)
		.drawsPeak_(true)
		.warningColor_(Color.yellow)
		.criticalColor_(Color.red)
		.style_(\continuous);

		var liright = LevelIndicator()
		.warning_(-2.dbamp)
		.critical_(0.dbamp)
		.drawsPeak_(true)
		.warningColor_(Color.yellow)
		.criticalColor_(Color.red)
		.style_(\continuous);

		var view = View().layout_(VLayout().spacing_(1).margins_(0));
		var osc = OSCdef((key ++ 'oscdef').asSymbol, {arg msg;
			{
				lileft.value = msg[3].ampdb.linlin(-40, 0, 0, 1);
				liright.value = msg[4].ampdb.linlin(-40, 0, 0, 1);
				lileft.peakLevel = msg[5].ampdb.linlin(-40, 0, 0, 1);
				liright.peakLevel = msg[6].ampdb.linlin(-40, 0, 0, 1);
			}.defer;
		}, osckey, server.addr)
		.permanent_(true);

		view.layout.add(lileft);
		view.layout.add(liright);
		view.onClose_({
			osc.debug(\free);
			osc.permanent_(false);
			osc.free;
		})
		.minHeight_(15)
		.maxHeight_(15)
	};

	var freqScopeView = {
		var node = synth.node;
		var view = View()
		.layout_(VLayout().spacing_(0).margins_(0));

		var fsv = FreqScopeView()
		.active_(true)
		.freqMode_(1)
		.inBus_(node.bus.index);

		view.layout.add(fsv);
		view.onClose_({
			fsv.debug(\close);
			fsv.kill;
		});
		view;
	};

	var ctrlView = {arg key, spec, color, synth;

		var controlSpec = spec;
		var myval = synth.at(key);
		var stack, view;
		var font = Font(size:10);

		if (myval.isNumber) {

			var li = LevelIndicator().value_(controlSpec.unmap(myval));
			var labelView = StaticText().string_(key ++ ": ").font_(font).stringColor_(Color.white);
			var st = StaticText().string_(myval).font_(font).stringColor_(Color.white);
			var nb = NumberBox()
			.font_(font)
			.value_(myval)
			.background_(Color.white)
			.minDecimals_(3)
			.clipLo_(controlSpec.minval)
			.clipHi_(controlSpec.maxval);

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
						st.string_(mappedVal);
						nb.value = mappedVal;
						synth.set(key, mappedVal);
						//this.prSendMsg(key, mappedVal);
					};
				})
				.mouseDownAction_({arg ctrl, x, y, mod, num, count;
					var val = controlSpec.default;

					if (count == 2) {
						li.value = controlSpec.unmap(val);
						st.string_(val);
						nb.value = val;
						synth.set(key, val);
						//this.prSendMsg(key, val);
					} {
						if (mod == 0) {
							var val = x.linlin(0, ctrl.bounds.width, 0, 1);
							var mappedVal = controlSpec.map(val);
							li.value = val;
							st.string_(mappedVal);
							nb.value = mappedVal;
							synth.set(key, mappedVal);
							//this.prSendMsg(key, mappedVal);
						};
					};
				}),
				nb
				.action_({arg ctrl;
					var val = ctrl.value;
					li.value = controlSpec.unmap(val);
					st.string_(val);
					synth.set(key, val);
					//this.prSendMsg(key, val);
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
					}
				}).fixedHeight_(25),
			).margins_(0).spacing_(1));
		};
		view;
	};

	var scrollView = ScrollView()
	.name_(key).postln;

	var view = View()
	.layout_(VLayout().margins_(0.5).spacing_(0.5))
	.palette_(QPalette.dark);

	view.layout.add(freqScopeView.());
	view.layout.add(levelView.());

	{
		// bit of a hack since the specs are configured
		// in a dictionary which doesn't retain order
		// so, we can overload the units prop of a controlspec
		// as a way to gruop related controls together
		var groups = ();
		var specgroups;
		specs.do({arg val; groups[val.asSpec.units.asSymbol] = 1});
		specgroups = groups.keys.asSortedList.collect({arg group;
			var returnval = List.new;
			specs.keysValuesDo({arg k, v;
				if (v.units == group.asString) {
					returnval.add(k -> v);
				}
			});
			returnval.quickSort({arg a, b; a.key < b.key})
		});

		specgroups.do({arg val;
			val.do({arg assoc;
				var k = assoc.key;
				var v = assoc.value;
				var ctrl = ctrlView.(k, v.asSpec, Color.rand, synth);
				view.layout.add(ctrl);
			});
		});

	}.();

	view.layout.add(nil);
	view.onClose_({
		[watcher].debug(\free);
		watcher.free;
	});
	scrollView.canvas = view.background_(Color.clear);
	scrollView.postln;
})
)
