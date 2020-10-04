(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\launcher, {|...args|

	var rows, grid;
	var active = ~active ? ();
	var allButtons = List.new;
	var reset = {
		allButtons.do({|btn|
			btn.valueAction = 0;
		});
	};
	rows = args.collect({|assoc|
		var buttons;
		buttons = assoc.value.collect({|func, i|

			var key = (assoc.key ++ '_ptrn_launch').asSymbol;
			var pdef = Pdef(key);
			var isactive = (active[key] == i);//if (pdef.isPlaying) {1} {0};

			if (isactive) {
				Pdef(key, func.());
			};

			Button()
			.states_([ [nil, nil, Color.clear.alpha_(1.5) ], [nil, nil, Color.red.alpha_(0.5) ] ])
			.action_({|ctrl|

				if (ctrl.value == 1) {
					buttons.do({|btn, j|
						if (i != j) {
							btn.value = 0;
						}
					});

					Pdef(key, func.());
					active[key] = i;
					pdef.play;
				} {
					pdef.stop;
					active[key] = nil;
				}
			})
			.value_(isactive)
		});

		allButtons.addAll(buttons);
		[StaticText().string_(assoc.key).minWidth_(50)]
		++
		buttons
	});

	grid = View().layout_(GridLayout.rows(*rows).margins_(0).spacing_(0));
	if (~view.isNil or: ~view.isClosed) {

		var baseViewFunc = Fdef(\baseview);
		var baseview;
		~view = View().layout_(VLayout().margins_(3).spacing_(3));
		~view.layout.add(grid);
		CmdPeriod.add(reset);
		~view.onClose = { \close.debug(\launcher); CmdPeriod.remove(reset) };
		//~view.front;
		baseview = baseViewFunc.(~view, 'launcher', 150, 170);
		baseview.front;

	} {
		~view.children.do({|child| child.remove});
		~view.layout.add(grid);
	};
})
)

