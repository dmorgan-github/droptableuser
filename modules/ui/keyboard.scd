(
~keyboard = {
	var map = (
		'a': 48,
		'w': 49,
		's': 50,
		'e': 51,
		'd': 52,
		'f': 53,
		't': 54,
		'g': 55,
		'y': 56,
		'h': 57,
		'u': 58,
		'j': 59,
		'k': 60,
		'o': 61,
		'l': 62,
		'p': 63
	);
	var octave = 0;
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
		//[char, mod, unicode, keycode, key].debug("keyDownAction");
		///////////////
		// "+" = up 1 octave, "-" = down 1 octave
		switch(key, 43, { octave = octave + 12}, 45, { octave = octave -12} );
		note = map[char.asSymbol];
		if (note.isNil.not) {
			note = note + octave;
			text.string_(note.midiname);
			Fdef(\noteOn).value(note);
		}
	});
	view.keyUpAction_({arg ctrl, char, mod, unicode, keycode, key;

		var note;
		//[char, mod, unicode, keycode, key].debug("keyUpAction");
		note = map[char.asSymbol];
		if (note.isNil.not) {
			note = note + octave;
			Fdef(\noteOff).value(note);
		}
	});
	view;
}
)


