(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\workspace, {|ws|

	var baseview;
	var baseViewFunc = Fdef(\baseview);
	var playview = Fdef(\playview);
	var view = View().layout_(VLayout().spacing_(0).margins_(0));
	var path = App.workspacedir ++ ws.key;
	thisProcess.platform.recordingsDir_(path.debug(\recdir));

	view.layout.add(HLayout(
		Button()
		.action_({|ctrl|
			Server.default.makeGui
		})
		.states_([ ["server"] ]),

		Button()
		.action_({|ctrl|
			if (ctrl.value == 1) {
				App.saveWorkspace(ws.key, rec:true);
			} {
				\stoprecording.postln;
				Server.default.stopRecording;
			}
		})
		.states_([ ["rec", Color.red], ["stop", Color.red] ])
	));

	ws.keysValuesDo({|k, v|
		if (v.respondsTo(\view)) {

			var row = HLayout().margins_(0).spacing_(0);
			row.add(Button()
				.action_({|ctrl| v.nscope })
			);
			row.add(Button()
				.action_({|ctrl| v.view })
				.states_([ [k], [k] ])
			);
			if (v.isKindOf(S)) {
				row.add(playview.(v.node));
			}{
				row.add(playview.(v));
			};
			view.layout.add(row);
		} {
			"skipping key %".format(k).warn
		}
	});

	baseview = baseViewFunc.(view, ws.key);
	baseview.front;
})
)
