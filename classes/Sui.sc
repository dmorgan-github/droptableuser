Sui {

	*new {arg key, envir, specs;
		/*
		TODO: move to own class and called from here
		*/
		var scrollView = ScrollView()
		.name_(key);
		var view = View()
		.layout_(VLayout().margins_(0.5).spacing_(0.5))
		.palette_(QPalette.dark);

		specs.do({arg assoc;
			var k = assoc.key;
			var v = assoc.value;
			var ctrl = this.prCtrlView(k, v.asSpec, Color.rand, envir);
			view.layout.add(ctrl);
		});

		view.layout.add(nil);
		scrollView.canvas = view.background_(Color.clear);
		^scrollView;
	}

	prCtrlView {arg key, spec, color, envir=();
		/*
		TODO: move to own class
		*/
		var controlSpec = spec;
		var myval = envir[key] ?? controlSpec.default;
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

		envir[key] = myval;
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
					envir[key] = mappedVal;
				};
			})
			.mouseDownAction_({arg ctrl, x, y, mod, num, count;
				var val = controlSpec.default;
				if (count == 2) {
					li.value = controlSpec.unmap(val);
					st.string_(val);
					nb.value = val;
					envir[key] = val;
				} {
					if (mod == 0) {
						var val = x.linlin(0, ctrl.bounds.width, 0, 1);
						var mappedVal = controlSpec.map(val);
						li.value = val;
						st.string_(mappedVal);
						nb.value = mappedVal;
						envir[key] = mappedVal;
					};
				};
			}),
			nb
			.action_({arg ctrl;
				var val = ctrl.value;
				li.value = controlSpec.unmap(val);
				st.string_(val);
				envir[key] = val;
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