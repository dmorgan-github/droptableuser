(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\transport, {|clock=(TempoClock.default)|

	var baseViewFunc = Fdef(\baseview);
	var baseview;
	var ctrlTempo = StaticText().string_(t.tempo * 60),
	ctrlBar = StaticText().string_(0),
	ctrlBeat = StaticText().string_(0);

	var controller = SimpleController(clock)
	.put(\tempo, {|obj, prop|
		{ ctrlTempo.string = obj.tempo * 60 }.defer
	});

	var view = View().layout_(HLayout(
		Button().states_([["P"]])
		.action_({|ctrl|
			Server.default.plotTree
		})
		.maxWidth_(35),
		Button().states_([["F"]])
		.action_({|ctrl|
			Server.default.freqscope;
		})
		.maxWidth_(35),
		Button().states_([ ["L"] ])
		.action_({|ctrl| Server.default.meter(2, 2) })
		.maxWidth_(35),
		Knob().mode_(\vert).action_({|ctrl|
			var val = ctrl.value.ampdb;
			Server.default.volume.volume = val;
			ctrl.toolTip = Server.default.volume.volume.trunc(0.01);
		})
		.value_(Server.default.volume.volume.dbamp)
		.toolTip_(Server.default.volume.volume.trunc(0.01))
		.maxSize_(30),
		Button().states_([ ["M", nil, Color.grey ], ["M", Color.black, Color(1, 0.67, 0) ] ]).action_({|ctrl|
			if (ctrl.value == 1) {
				Server.default.volume.mute;
			}{
				Server.default.volume.unmute;
			}
		})
		.maxWidth_(35),
		Button().states_([ [ "O", nil, Color.grey ], ["[]", Color.black, Color.red] ])
		.action_({|ctrl|
			if (ctrl.value == 1) {
				Server.default.record;
			}{
				Server.default.stopRecording;
			}
		})
		.maxWidth_(35),
		ctrlTempo,
		ctrlBar,
		ctrlBeat
	))
	.minWidth_(250)
	.onClose_({controller.remove});

	var nextBar = clock.nextBar/clock.beatsPerBar;

	clock.schedAbs(t.nextTimeOnGrid(1), {
		{
			var barnum = clock.bar;// - nextBar;
			var beat = (clock.beats - clock.bars2beats(barnum)).trunc;
			ctrlBar.string = (barnum - nextBar + 1).trunc;
			ctrlBeat.string = beat + 1;
			//[barnum, beat].postln;
		}.defer(s.latency);
		if (view.isClosed) {
			nil;
		}{
			1;
		}
	});

	baseview = baseViewFunc.(view, 'transport');
	baseview.alwaysOnTop = true;
	baseview.front;
})
)
