(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\launch, {|patterns, clock=(TempoClock.default)|

	var rows, grid;
	var active = if (~launch_active.isNil) { ~launch_active = (); ~launch_active } {~launch_active};
	var allButtons = List.new;
	var reset = {
		allButtons.do({|btn|
			btn.valueAction = 0;
		});
	};

	rows = patterns.flatten.collect({|assoc|
		var buttons;
		buttons = assoc.value.collect({|func, i|

			var key = (assoc.key ++ '_ptrn_launch').asSymbol;
			var pdef = Pdef(key);
			var isactive = (active[key] == i);//if (pdef.isPlaying) {1} {0};

			if (isactive) {
				Pdef(key, func.());
			};

			Button()
			.states_([ [nil, nil, Color.clear.alpha_(1.5) ], [nil, nil, Color.white.alpha_(0.8) ] ])
			.action_({|ctrl|

				if (ctrl.value == 1) {
					buttons.do({|btn, j|
						if (i != j) {
							btn.value = 0;
						}
					});

					Pdef(key, func.());
					active[key] = i;
					pdef.play(argClock:clock)
				} {
					pdef.stop;
					active[key] = nil;
				}
			})
			.value_(if (isactive) {1}{0})
		});

		allButtons.addAll(buttons);
		[StaticText()
			.string_(assoc.key)
			.minWidth_(50)
			.mouseUpAction_({|ctrl, x, y, mod, num, click|
				if (Pdef.all[assoc.key].isKindOf(S)) {
					S(assoc.key).view;
				}
			})
			.mouseOverAction_({|ctrl|
				if (Pdef.all[assoc.key].isKindOf(S)) {
					ctrl.stringColor = Color.blue;
				}
			})
			.mouseLeaveAction_({|ctrl|
				ctrl.stringColor = Color.white;
			})
		]
		++
		buttons
	});

	grid = View().layout_(GridLayout.rows(*rows).margins_(0).spacing_(0));
	if (~view.isNil) {

		var baseViewFunc = Fdef(\baseview);
		var baseview;

		~view = View().layout_(VLayout().margins_(3).spacing_(3));
		~view.layout.add(grid);
		CmdPeriod.add(reset);
		~view.onClose = {
			\close.debug(\launcher);
			~view = nil;
			CmdPeriod.remove(reset);
		};
		//~view.front;
		baseview = baseViewFunc.(~view, 'launcher');
		baseview.acceptsMouseOver = true;
		baseview.front;
	} {
		~view.children.do({|child| child.remove});
		~view.layout.add(grid);
	};
})
)


