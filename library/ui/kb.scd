(
func: {|node|

	var view = View();
	var baseview;
    var keys = Order.new;

    var scale = Scale.ritusen;
    var map, rows, cols, buttons, hilight;
    var keyboard, grid, func, scales;
    var keyboardview, update;
    var mode = \push;

    var octave = (node.get(\octave) ?? 3).debug("octave");
    var root = ~root ?? 0;

	map = [
		'z', 'x', 'c', 'v', 'b',
		'a', 's', 'd', 'f', 'g',
		'h', 'j', 'k', 'l', ';',
		'q', 'w', 'e', 'r', 't',
		'y', 'u', 'i', 'o', 'p'
	];

	rows = 5;
	cols = 5;

	buttons = rows * cols;

    hilight = {
        if (scale.isKindOf(Scale)) {
            scale.degrees;
        }{
            scale
        }
    };

    keyboardview = View();

    update = {

        keyboard = buttons.collect({arg i;
            var label;
            var color = Color.grey.alpha_(0.3);
            var num = buttons-i;
            num = buttons - num;
            label = map[num];
            if (hilight.().includes(num.mod(12))) {
                color = node.color.alpha_(0.5);
            };
            Button()
            .states_([[label, nil, color], [label, nil, Color.white]])
            .fixedWidth_(40)
            .mouseDownAction_({arg ctrl;

                if (mode == \push) {
                    var note = 12 * octave + num + root;
                    var vel = num.linlin(0, 24, 127, 100);
                    node.on(note, vel);
                    ctrl.value = 1;
                };
            })
            .mouseUpAction_({arg ctrl;
                var note = 12 * octave + num + root;
                if (mode == \push) {
                    ctrl.value = 1;
                }
            })
            .action_({|ctrl|
                var note = 12 * octave + num + root;
                if (ctrl.value == 1) {
                    // toggle mode
                    var vel = num.linlin(0, 24, 127, 100);
                    node.on(note, vel);
                } {
                    node.off(note);
                }
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

        keyboardview.layout = VLayout(
            GridLayout.rows(*grid).margins_(0).spacing_(0),
            nil
        ).margins_(0).spacing_(0);

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
        .background_(Color.clear)
        .value_(default+1);
    };

    update.();

	view = view
    .name_('kb')
	.layout_(VLayout(
        HLayout(
            scales.(),
            Button()
            .states_([  ["push", nil, Color.clear.alpha_(0.5)], ["toggle", nil, Color.clear.alpha_(0.5)] ] )
            .action_({|ctrl|
                if (ctrl.value == 1) {
                    mode = \toggle
                }{
                    mode = \push
                }
            })
        ),
        keyboardview
    ).spacing_(2).margins_(2))
	.keyDownAction_({arg ctrl, char, mod, uni, keycode, key;
		var val = map.indexOf(char.asSymbol);

		if (val.isNil.not) {
            var vel = val.linlin(0, 24, 127, 100);
			var num = val;
			var note = 12 * octave + val + root;
            if (keys[note].isNil) {
                keys[note] = 1;
                node.on(note, vel);
                if (num < keyboard.size) {
                    keyboard[num].value = 1;
                }
            } {
                if (mode == \toggle) {
                    keys.removeAt(note);
                    node.off(note);
                    if (num < keyboard.size) {
                        keyboard[num].value = 0;
                    }
                }
            }

		};
		nil;
	})
	.keyUpAction_({arg ctrl, char;
		var val = map.indexOf(char.asSymbol);
        if (mode == \push) {
            if (val.isNil.not) {
                var num = val;
                var note = 12 * octave + val + root;
                keys.removeAt(note);
                node.off(note);
                if (num < keyboard.size) {
                    keyboard[num].value = 0;
                }
            }
        }
	})
	.onClose_({arg ctrl;
        //
	});

    view
}
)
