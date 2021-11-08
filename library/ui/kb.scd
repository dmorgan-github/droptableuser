(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\kb, {arg synth;

    var noteChan = 0;
    var midiout = MIDIOut(noteChan).latency_(0);
	var view = View();
	var baseview;
	var baseViewFunc = Fdef(\baseview);
	var synthEnvir = synth.envir ? ();

    var getDefault = {|key, default|
        var val = Event.parentEvents[\default][key] ?? {default};
        val = if (Event.partialEvents.playerEvent.parentTypes[\note].notNil) {
            Event.partialEvents.playerEvent.parentTypes[\note][key];
        }{
            val
        };
        val = synthEnvir[key] ?? {val};
        val;
    };

    var octave = getDefault.(\octave, 5);
    var root = getDefault.(\root, 0);
    var scale = getDefault.(\scale, Scale.dorian);

	var map = [
		'z', 'x', 'c', 'v', 'b',
		'a', 's', 'd', 'f', 'g',
		'h', 'j', 'k', 'l', ';',
		'q', 'w', 'e', 'r', 't',
		'y', 'u', 'i', 'o', 'p'
	];

    var hilight = {
        if (scale.isKindOf(Scale)) {
            scale.degrees;
        }{
            scale
        }
    }.value;

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
			var note = 12 * octave + num + root;
			midiout.noteOn(noteChan, note: note);
			ctrl.value = 1;
		})
		.mouseUpAction_({arg ctrl;
			var note = 12 * octave + num + root;
            midiout.noteOff(noteChan, note:note);
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

	view = view
	.name_(synth.key)
	.layout_(GridLayout.rows(*grid).margins_(0).spacing_(0))
	.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
		var val = map.indexOf(char.asSymbol);
		if (val.isNil.not) {
			var num = val;
			var note = 12 * octave + val + root;
            midiout.noteOn(noteChan, note: note);
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
            midiout.noteOff(noteChan, note: note);
			if (num < keyboard.size) {
				keyboard[num].value = 0;
			}
		}
	})
	.onClose_({arg ctrl;
        \onclose.postln;
		synth.removeDependant(func);
	});

	baseview = baseViewFunc.(view, synth.key);
	baseview.front;
	//view.front
});
)