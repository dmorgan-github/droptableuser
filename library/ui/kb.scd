(
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\kb, {arg synth;

	var baseview;
	var synthEnvir = synth.envir ? ();
	var palette = QPalette.auto(Color.grey, Color.black);
	var octave = synthEnvir[\octave] ?? 5;
	var root = synthEnvir[\root] ? 4;

	var view;
	var map = [
		'z', 'x', 'c', 'v', 'b',
		'a', 's', 'd', 'f', 'g',
		'h', 'j', 'k', 'l', ';',
		'q', 'w', 'e', 'r', 't',
		'y', 'u', 'i', 'o', 'p'
	];

	var scale = synthEnvir[\scale] ? Scale.at(\dorian);
	var hilight = scale.degrees;
	var rows = 5;
	var cols = 5;

	var buttons = rows * cols;
	var keyboard = buttons.collect({arg i;
		var label;
		var color = Color.grey;
		var num = buttons-i;
		num = buttons - num;
		label = map[num];
		if (hilight.includes(num.mod(12))) {
			color = Color.blue.alpha_(0.5);
		};
		Button()
		.states_([[label, nil, color], [label, nil, Color.white]])
		.fixedWidth_(40)
		.fixedHeight_(24)
		.mouseDownAction_({arg ctrl;
			var octave = synthEnvir[\octave] ?? 5;
			var root = synthEnvir[\root] ?? S.defaultRoot;
			var note = 12 * octave + num + root;
			synth.on(note);
			ctrl.value = 1;
		})
		.mouseUpAction_({arg ctrl;
			var octave = synthEnvir[\octave] ?? 5;
			var root = synthEnvir[\root] ?? S.defaultRoot;
			var note = 12 * octave + num + root;
			synth.off(note);
			ctrl.value = 1;
		});
	});

	var grid = rows.collect({arg i;
		cols.collect({arg j;
			var num = cols * i + j;
			keyboard[buttons-1-num];
		}).reverse;
	});

	var func = {arg obj, prop, params;
		if(prop == \set) {
			var vals = params.asDict;
			if (vals[\octave].isNil.not) {
				octave = vals[\octave];
				octave.debug(\kb);
			};
			if (vals[\root].isNil.not) {
				root = vals[\root];
				root.debug(\kb);
			};
		}
	};
	synth.addDependant(func);

	view = View()
	.palette_(palette)
	.name_(synth.key)
	.layout_(GridLayout.rows(*grid).margins_(0).spacing_(1))
	.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
		var val = map.indexOf(char.asSymbol);
		if (val.isNil.not) {
			var num = val;
			var note = 12 * octave + val + root;
			synth.on(note);
			if (num < keyboard.size) {
				keyboard[num].value = 1;
			}
		};
		nil;
	})
	.keyUpAction_({arg ctrl, char;
		var val = map.indexOf(char.asSymbol);
		if (val.isNil.not) {
			var num = val;
			var note = 12 * octave + val + root;
			synth.off(note);
			if (num < keyboard.size) {
				keyboard[num].value = 0;
			}
		}
	})
	.onClose_({arg ctrl;
		synth.removeDependant(func);
	});

	baseview = Fdef(\baseview).(view, synth.key);
	baseview.front;
	//view.front
});
)