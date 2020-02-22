
Sui {

	classvar <all;

	var <key, <specs, <ip, <port, <server, <synth, <>handler;

	*new {arg key, specs, synth, ip="127.0.0.1", port=57120;

		var res = all[key];
		if (res.isNil) {
			res = super.new.prInit(key, specs, synth, ip, port);
			all.put(key, res);
		};
		^res;
	}

	prInit {arg inKey, inSpecs, insynth, inIp, inPort;
		key = inKey;
		specs = inSpecs;
		ip = inIp;
		port = inPort;
		synth = insynth;
		handler = {};
		server = NetAddr(ip, port);
		^this;
	}

	view {
		var scrollView = ScrollView()
		.name_(key);
		var view = View()
		.layout_(VLayout().margins_(0.5).spacing_(0.5))
		.palette_(QPalette.dark);

		var envview;
		var cutoffres = Slider2D().minHeight_(125);
		var cutoffspec = synth.getSpec(\cutoff);
		var resspec = synth.getSpec(\res);
		cutoffres.setXY(cutoffspec.unmap(synth.getVal(\cutoff)), resspec.unmap(synth.getVal(\res)));

		view.layout.add(cutoffres.action_({arg ctrl;
			var cutoff = ctrl.x;
			var res = ctrl.y;
			var cutoffspec = specs.detect({arg assoc; assoc.key == \cutoff}).value;
			var resspec = specs.detect({arg assoc; assoc.key == \res}).value;
			cutoff = cutoffspec.map(cutoff);
			res = resspec.map(res);
			synth.set(\cutoff, cutoff, \res, res)
		}));

		envview = {arg envkeys;
			var suslevelkey = envkeys[\suslevel];
			var atkkey = envkeys[\atk];
			var deckey = envkeys[\dec];
			var relkey = envkeys[\rel];
			var atkcurvekey = envkeys[\atkcurve];
			var deccurvekey = envkeys[\deccurve];
			var relcurvekey = envkeys[\relcurve];
			var tskey = envkeys[\tskey];

			var tsspec = synth.getSpec(tskey);
			var atkspec = synth.getSpec(atkkey);
			var decspec = synth.getSpec(deckey);
			var relspec = synth.getSpec(relkey);
			var atkcurvespec = synth.getSpec(atkcurvekey);
			var deccurvespec = synth.getSpec(deccurvekey);
			var relcurvespec = synth.getSpec(relcurvekey);

			var view;
			var envview = EnvelopeView()
			.minHeight_(80)
			.value_([
				[
					0,
					synth.getVal(atkkey),
					synth.getVal(deckey),
					0.5,
					synth.getVal(relkey)
				].integrate,
				[0, 1, synth.getVal(suslevelkey), synth.getVal(suslevelkey), 0]
			])
			.curves_([synth.getVal(atkcurvekey), synth.getVal(deccurvekey), 0, synth.getVal(relcurvekey)]);

			var atkcurveview, deccurveview, relcurveview;
			atkcurveview = Knob().mode_(\vert).action_({arg ctrl;
				var atkcurve = atkcurvespec.map(ctrl.value);
				var deccurve = deccurvespec.map(deccurveview.value);
				var relcurve = relcurvespec.map(relcurveview.value);
				envview.curves = [atkcurve, deccurve, 0, relcurve];
				synth.set(atkcurvekey, atkcurve);
			})
			.value_(atkcurvespec.unmap(synth.getVal(atkcurvekey)));

			deccurveview = Knob().mode_(\vert).action_({arg ctrl;
				var atkcurve = atkcurvespec.map(atkcurveview.value);
				var deccurve = deccurvespec.map(ctrl.value);
				var relcurve = relcurvespec.map(relcurveview.value);
				envview.curves = [atkcurve, deccurve, 0, relcurve];
				synth.set(deccurvekey, deccurve);
			})
			.value_(deccurvespec.unmap(synth.getVal(deccurvekey)));

			relcurveview = Knob().mode_(\vert).action_({arg ctrl;
				var atkcurve = atkcurvespec.map(atkcurveview.value);
				var deccurve = deccurvespec.map(deccurveview.value);
				var relcurve = relcurvespec.map(ctrl.value);
				envview.curves = [atkcurve, deccurve, 0, relcurve];
				synth.set(relcurvekey, relcurve);
			})
			.value_(relcurvespec.unmap(synth.getVal(relcurvekey)));

			view = View().layout_(VLayout());
			envview.setEditable(0, false);
			envview.setEditable(3, false);
			view.layout.add(
				envview
				.keepHorizontalOrder_(true)
				.action_({arg ctrl;
					var xvals, yvals, val;
					xvals = ctrl.value[0];
					yvals = ctrl.value[1];
					if (ctrl.index == 1) {
						if (ctrl.y < 1) {
							ctrl.y = 1;
						};
					};
					if (ctrl.index == 3) {
						ctrl.y = yvals[2];
					};
					if (ctrl.index == 4) {
						if (ctrl.y > 0) {
							ctrl.y = 0
						}
					};
					val = ctrl.x - xvals[ctrl.index-1];
					val = val.max(0);
					switch (ctrl.index,
						1, {
							[atkkey, val].postln;
							synth.set(atkkey, val);
						},
						2, {
							[deckey, val, suslevelkey, ctrl.y].postln;
							synth.set(deckey, val);
							synth.set(suslevelkey, ctrl.y);
						},
						3, {
							[suslevelkey, ctrl.y].postln;
							synth.set(suslevelkey, ctrl.y);
						},
						4, {
							[relkey, val].postln;
							synth.set(relkey, val)
						}
					)
				})
				.mouseUpAction_({arg ctrl;
					if (ctrl.index == 2) {
						var y = ctrl.y;
						ctrl.selectIndex(3);
						ctrl.y = y;
					};
					if (ctrl.index == 3) {
						var y = ctrl.y;
						ctrl.selectIndex(2);
						ctrl.y = y;
					}
				})
			);
			view.layout.add(Slider().action_({arg ctrl;
				var val = tsspec.map(ctrl.value);
				[tskey, val].postln;
				synth.set(tskey, val);
			}).orientation_(\horizontal)
			.value_(tsspec.unmap(synth.getVal(tskey, 1)))
			);
			view.layout.add(HLayout(atkcurveview, deccurveview, relcurveview));
			view;
		};

		view.layout.add(envview.(
			(
				\suslevel: \suslevel,
				\atk: \atk,
				\dec: \dec,
				\rel: \rel,
				\atkcurve: \atkcurve,
				\deccurve: \deccurve,
				\relcurve: \relcurve,
				\tskey: \ts
			)
		));

		view.layout.add(envview.(
			(
				\suslevel: \fsuslevel,
				\atk: \fatk,
				\dec: \fdec,
				\rel: \frel,
				\atkcurve: \fatkcurve,
				\deccurve: \fdeccurve,
				\relcurve: \frelcurve,
				\tskey: \fts
			)
		));

		specs.reject({arg assoc;
			[
				\suslevel,
				\atk,
				\dec,
				\rel,
				\atkcurve,
				\deccurve,
				\relcurve,
				\ts,
				\fsuslevel,
				\fatk,
				\fdec,
				\frel,
				\fatkcurve,
				\fdeccurve,
				\frelcurve,
				\fts,
				\cutoff,
				\res
			].includes(assoc.key)
		}).do({arg assoc;
			var k = assoc.key;
			var v = assoc.value;
			var ctrl = this.prCtrlView(k, v.asSpec, Color.rand, synth);
			view.layout.add(ctrl);
		});

		view.layout.add(nil);
		scrollView.canvas = view.background_(Color.clear);
		^scrollView;
	}

	prSendMsg {arg name, val;
		var path = "/%/%".format(key, name).asSymbol;
		server.sendMsg(path, val);
		handler.(name, val);
	}

	prCtrlView {arg key, spec, color, synth;
		var controlSpec = spec;
		var myval = synth.getVal(key);
		var stack, view;
		var font = Font(size:10);
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
					this.prSendMsg(key, mappedVal);
				};
			})
			.mouseDownAction_({arg ctrl, x, y, mod, num, count;
				var val = controlSpec.default;

				if (count == 2) {
					li.value = controlSpec.unmap(val);
					st.string_(val);
					nb.value = val;
					synth.set(key, val);
					this.prSendMsg(key, val);
				} {
					if (mod == 0) {
						var val = x.linlin(0, ctrl.bounds.width, 0, 1);
						var mappedVal = controlSpec.map(val);
						li.value = val;
						st.string_(mappedVal);
						nb.value = mappedVal;
						synth.set(key, mappedVal);
						this.prSendMsg(key, mappedVal);
					};
				};
			}),
			nb
			.action_({arg ctrl;
				var val = ctrl.value;
				li.value = controlSpec.unmap(val);
				st.string_(val);
				synth.set(key, val);
				this.prSendMsg(key, val);
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

		^view;
	}

	clear {
		all[key] = nil;
	}

	*initClass {
		all = ();
	}
}

K {

	*new {arg synth;

		var synthEnvir = synth.envir;

		var map = (
			'z': 0,'s': 1,'x': 2,'d': 3,'c': 4,'v': 5,'g': 6,
			'b': 7,'h': 8,'n': 9,'j': 10,'m': 11,',': 12,
			'q': 12,'2': 13,'w': 14,'3': 15,'e': 16,'r': 17,'5': 18,
			't': 19,'6': 20,'y': 21,'7': 22,'u': 23,'i': 24
		);

		var black = [1,3,6,8,10];
		var rows = 25;

		var keyboard = rows.collect({arg i;
			var color = Color.grey;
			var num = rows-1-i;
			if (black.includes(num.mod(12))) {
				color = Color.black;
			};
			Button()
			.states_([[nil, nil, color], [nil, nil, Color.white]])
			.fixedWidth_(40)
			.fixedHeight_(24)
			.mouseDownAction_({arg ctrl;
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + num;
				synth.on(note);
				ctrl.value = 1;
			})
			.mouseUpAction_({arg ctrl;
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + num;
				synth.off(note);
				ctrl.value = 1;
			});
		});

		var view = View()
		.layout_(VLayout(*keyboard).margins_(0).spacing_(1))
		.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
			var val = map[char.asSymbol];
			if (val.isNil.not) {
				var num = rows-1-val;
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + val;
				synth.on(note);
				if (num < keyboard.size) {
					keyboard[num].value = 1;
				}
			};
			nil;
		})
		.keyUpAction_({arg ctrl, char;
			var val = map[char.asSymbol];
			if (val.isNil.not) {
				var num = rows-1-val;
				var octave = synthEnvir[\octave] ?? 5;
				var note = 12 * octave + val;
				synth.off(note);
				if (num < keyboard.size) {
					keyboard[num].value = 0;
				}
			}
		});

		^view
	}
}

// launcher
L {
	*new {
		var view;
		var pdefs = Pdef.all.keys.asArray
		.sort
		.select({arg k; k.asString.contains("_ptrn")})
		.collect({arg k; Pdef(k)});

		var buttons = List.new;
		var currentrow = nil;
		var lastkey = "";
		pdefs.do({arg pdef, i;
			var key = pdef.key;
			if (key.asString.beginsWith(lastkey).not) {
				lastkey = key.asString.split($_)[0];
				currentrow = List.new;
				buttons.add(currentrow);
			};
			currentrow.add(Button()
				.states_([ [key, nil, Color.gray], [key, nil, Color.blue] ])
				.action_({arg ctrl;
					if (ctrl.value == 1) {
						pdef.play;
					}{
						pdef.stop;
					}
				})
				.value_(pdef.isPlaying)
			);
		});
		view = View().layout_(GridLayout.rows(*buttons));
		^view
	}
}