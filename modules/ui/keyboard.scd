(
Fdef(\keyboard, {arg root = 48;
	var map = (
		'z': 0,
		's': 1,
		'x': 2,
		'd': 3,
		'c': 4,
		'v': 5,
		'g': 6,
		'b': 7,
		'h': 8,
		'n': 9,
		'j': 10,
		'm': 11,
		',': 12,
		'q': 12,
		'2': 13,
		'w': 14,
		'3': 15,
		'e': 16,
		'r': 17,
		'5': 18,
		't': 19,
		'6': 20,
		'y': 21,
		'7': 22,
		'u': 23,
		'i': 24,
		'9': 25,
		'o': 26,
		'0': 27,
		'p': 28,
		'[': 29
	);
	var text = StaticText().string_("");
	var view = View().layout_(
		VLayout(
			HLayout(
				Button().states_([ ["_"],["-"] ]).action_({arg ctrl;
					if (ctrl.value == 1) {
						view.alwaysOnTop_(true)
					}{
						view.alwaysOnTop_(false)
					};
				})
			),
			text
		)
	).fixedSize_(100);

	view.keyDownAction_({arg ctrl, char, mod, unicode, keycode, key;

		var note;
		note = map.at(char.asSymbol);
		if (note.isNil.not) {
			note = note + root;
			text.string_(note.midiname);
			Fdef(\noteOn).value(note);
		}
	});
	view.keyUpAction_({arg ctrl, char, mod, unicode, keycode, key;

		var note;
		note = map.at(char.asSymbol);
		if (note.isNil.not) {
			note = note + root;
			Fdef(\noteOff).value(note);
		}
	});
	view.front;
});
)


Fdef(\keyboard).();
