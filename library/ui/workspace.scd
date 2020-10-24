(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\workspace, {|ws|

	var baseview;
	var baseViewFunc = Fdef(\baseview);

	var view = View().layout_(VLayout().spacing_(0).margins_(0));
	view.layout.add(HLayout(
		Button()
		.action_({|ctrl|
			Server.default.makeGui
		})
		.states_([ ["server"] ])
	));
	ws.keysValuesDo({|k, v|
		var row = HLayout().margins_(0).spacing_(0);
		row.add(Button()
			.action_({|ctrl| v.view })
			.states_([ [k], [k] ])
		);
		row.add(Button()
			.action_({|ctrl|
				if (ctrl.value == 1) {
					if (v.isKindOf(S)) {
						v.node.play;
					}{
						v.play;
					}
				} {
					if (v.isKindOf(S)) {
						v.node.stop;
					}{
						v.stop;
					}
				}
			})
			.states_([[">"], ["[]"]])
		);
		row.add(TextField());
		row.add(nil);
		view.layout.add(row);
	});

	baseview = baseViewFunc.(view, ws.key);
	baseview.front;

})
)