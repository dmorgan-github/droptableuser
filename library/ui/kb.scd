(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\kb, {

    var noteChan = 0;
    var midiout = MIDIOut(noteChan).latency_(0);
	var view = View();
	var baseview;
	var baseViewFunc = Fdef(\baseview);
    var keys = Order.new;

    var octave = 3;
    var root = 0;
    var scale = Scale.ritusen;

	var map = [
		'z', 'x', 'c', 'v', 'b',
		'a', 's', 'd', 'f', 'g',
		'h', 'j', 'k', 'l', ';',
		'q', 'w', 'e', 'r', 't',
		'y', 'u', 'i', 'o', 'p'
	];

	var rows = 5;
	var cols = 5;

	var buttons = rows * cols;

    var hilight = {
        if (scale.isKindOf(Scale)) {
            scale.degrees;
        }{
            scale
        }
    };

    var keyboard, grid, func, scales;
    var keyboardview = View();

    var update = {

        keyboard = buttons.collect({arg i;
            var label;
            var color = Color.grey;
            var num = buttons-i;
            num = buttons - num;
            label = map[num];
            if (hilight.().includes(num.mod(12))) {
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

        grid = rows.collect({arg i;
            cols.collect({arg j;
                var num = cols * i + j;
                keyboard[buttons-1-num];
            }).reverse;
        });

        keyboardview.children.do({|child|
            child.remove
        });

        keyboardview.layout = GridLayout.rows(*grid).margins_(0).spacing_(0);

    };

    scales = {
        var names = Scale.names.select({|scale| Scale.at(scale).pitchesPerOctave == 12 });
        var default = names.indexOf(scale.name.toLower.asSymbol);
        PopUpMenu().items_([""] ++ names).action_({|ctrl|
            if (ctrl.item != "") {
                scale = Scale.at(ctrl.item.asSymbol);
                update.();
            }
        })
        .value_(default+1);
    };

    update.();

	view = view
    .name_('kb')
	.layout_(VLayout(
        scales.(),
        keyboardview
    ).spacing_(2).margins_(2))
	.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
		var val = map.indexOf(char.asSymbol);
		if (val.isNil.not) {
			var num = val;
			var note = 12 * octave + val + root;
            if (keys[note].isNil) {
                keys[note] = 1;
                midiout.noteOn(noteChan, note: note);
                if (num < keyboard.size) {
                    keyboard[num].value = 1;
                }
            }
		};
		nil;
	})
	.keyUpAction_({arg ctrl, char;
		var val = map.indexOf(char.asSymbol);
		if (val.isNil.not) {
			var num = val;
			var note = 12 * octave + val + root;
            keys.removeAt(note);
            midiout.noteOff(noteChan, note: note);
			if (num < keyboard.size) {
				keyboard[num].value = 0;
			}
		}
	})
	.onClose_({arg ctrl;
        \onclose.postln;
	});

    baseview = baseViewFunc.(view, 'kb');
	baseview.front;
});
)