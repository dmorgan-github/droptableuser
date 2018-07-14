(
var getSpecsForSynth = {arg synth;

	var synthDesc = SynthDescLib.at(synth.asSymbol);

	if (synthDesc.isNil.not) {

		var exclude = [\out, \freq, \gate, \trig];
		var meta = (synthDesc.metadata ? ())[\specs] ? ();
		var specs = SynthDescLib.at(synth.asSymbol).controls
		.select({arg ctrl;
			(ctrl.name != \out)
			and: (ctrl.name != \freq)
			and: (ctrl.name != \gate)
			and: (ctrl.name != \trig)
		}).collect({arg ctrl;

			var name = ctrl.name.asSymbol;
			var default = ctrl.defaultValue ? 0;
			var spec = ControlSpec.specs[name];

			if (meta[name].isNil) {
				if ( spec.isNil) {
					[0, 1, \lin, 0.01, default, name.asString].asSpec;
				} {
					spec.units_(name.asString).default_(default);
				};
			} {
				meta[name].asSpec.units_(name.asString).default_(default);
			};
		});

		specs;
	} {
		[];
	}
};

var view = {arg dur = 0.25, numCols = 16, proto = (instrument:\default);

	var main = View().layout_(GridLayout());
	var controlPanelLayout = VLayout();
	var controlPanelView = ScrollView()
	.fixedWidth_(80)
	.canvas_(View().layout_(controlPanelLayout));

	var buttons = (0..15).collect({ (0..numCols-1).collect() });
	var actionPanelView = View().layout_(HLayout());
	var gridPanelView = View().layout_(GridLayout());
	var filtersPanelView = View().layout_(VLayout());

	var fontFamily = "Courier New";
	var fontSize = 10;
	var font = Font(fontFamily, fontSize);
	var populateGrid, populateControlPanel, populateActionPanel, populateFiltersPanel;

	var obj = ();

	obj.onCellEnabled = {arg self, view, row, col, degree;
		[view, row, col, degree].debug("onCellEnabled");
	};

	obj.onCellDisabled = {arg self, view, row, col;
		[view, row, col].debug("onCellDisabled");
	};

	obj.onControlPanelLoad = {arg self, row, col;
		proto
	};

	obj.onCellControlChange = {arg self, name, row, col, val;
		[name, row, col, val].debug("onCellControlChange");
	};
	obj.onPlay = {
		"onPlay".debug;
	};
	obj.onStop = {
		"onStop".debug;
	};
	obj.onScaleChange = {arg self, scale;
		[scale].debug("onScaleChange");
	};
	obj.onOctaveChange = {arg self, octave;
		[octave].debug("onOctaveChange");
	};
	obj.onDurChange = {arg self, dur;
		[dur].debug("onDurChange");
	};
	obj.onSynthChange = {arg self, synth;
		[synth].debug("onSynthChange");
	};
	obj.onNodeClick = {arg self;
		"onNodeClick".postln;
	};
	obj.onRecStart = {arg self;
		"onRecStart".postln;
	};
	obj.onRecStop = {arg self;
		"onRecStop".postln;
	};
	obj.highlight = {arg self, row, col, time;

		var button = buttons[row][col];
		button.background_(Color.blue);
		{button.background_(Color.blue.alpha_(0));}.defer(time);
	};
	obj.onExport = {arg self;
		()
	};
	obj.onFiltersLoad = {
		[];
	};
	obj.onFilterChange = {arg self, num, val;
		[num, val].debug("onFilterChange");
	};

	populateGrid = {arg view;

		var gridButton = {arg row, col, degree;

			var myView = View().layout_(HLayout().margins_(1).spacing_(0));
			myView.layout.add(
				Button()
				.maxWidth_(20)
				.maxHeight_(20)
				.states_([ [nil, nil, Color.grey], [nil, nil, Color.white] ] )
				.action_({arg ctrl;
					if (ctrl.value == 0) {
						obj.onCellDisabled(ctrl, row, col);
					} {
						obj.onCellEnabled(ctrl, row, col, degree);
					}
				})
			);

			buttons[row][col] = myView;
			myView;
		};

		Array.series(16, 8, -1).do({arg val, row;
			numCols.do({arg col;
				view.layout.add(StaticText().string_(val).font_(font), row, 0 );
				view.layout.add(gridButton.(row, col, val), row, col + 1);
			});
		})
	};

	populateControlPanel = {arg row, col;

		var view = controlPanelView;
		var layout = controlPanelLayout;
		var state = obj.onControlPanelLoad(row, col);
		var synth = state[\instrument];
		var specs = getSpecsForSynth.(synth);
		view.removeAll;

		specs.do({arg spec;

			var name = spec.units.asString;
			var val = state[name.asSymbol] ? spec.default;
			var scaled = spec.unmap(val);
			var knob, nb;

			knob = Knob().value_(scaled)
			.action_({arg ctrl;
				var val = spec.map(ctrl.value);
				nb.value_(val);
				obj.onCellControlChange(name, row, col, val);
			});

			nb = NumberBox()
			.minDecimals_(3)
			.maxWidth_(50)
			.value_(val)
			.font_(font)
			.action_({arg ctrl; knob.valueAction_(spec.unmap(ctrl.value)); });

			layout.add(StaticText().string_(name).font_(font));
			layout.add(knob, align:\left);
			layout.add(nb, align:\left);
		});
	};

	populateActionPanel = {arg view;

		var octaves = [1,2,3,4,5,6,7,8];
		var scale = Scale.names.indexOf(\major);

		var vlayout = VLayout();
		var hlayout1 = HLayout();
		var hlayout2 = HLayout();

		view.layout.add(vlayout);
		vlayout.add(hlayout2);
		vlayout.add(hlayout1);

		hlayout2.add(Button()
			.string_("open")
			.font_(font)
			.action_({arg ctrl;
				"open".debug;
			})
			, align:\topLeft);

		hlayout2.add(Button()
			.string_("export")
			.font_(font)
			.action_({
				var data = obj.onExport();
				Document.new(string:data.asCompileString);
			})
			, align:\topLeft);

		hlayout2.add(StaticText()
			.minWidth_(500)
			.font_(font)
			.string_(proto[\instrument])
			, align:\left
		);

		hlayout1.add(Button()
			.string_("play")
			.font_(font)
			.maxWidth_(100)
			.action_({ obj.onPlay() })
		);

		hlayout1.add(Button()
			.string_("stop")
			.font_(font)
			.maxWidth_(40)
			.action_({obj.onStop()})
		);

		hlayout1.add(Button()
			.string_("rec")
			.states_( [ ["rec", nil, nil], ["stop",nil,nil]] )
			.font_(font)
			.maxWidth_(40)
			.action_({arg ctrl;

				if (ctrl.value == 1) {
					obj.onRecStart();
				} {
					obj.onRecStop();
				}
			})
		);

		hlayout1.add(StaticText().string_("dur").font_(font).maxWidth_(20));

		hlayout1.add(TextField()
			.minWidth_(50)
			.maxWidth_(50)
			.font_(font)
			.value_(dur)
			.action_({arg ctrl; obj.onDurChange(ctrl.value.asNumberIfPossible)})
		);

		hlayout1.add(StaticText().string_("scale").font_(font).maxWidth_(40));

		hlayout1.add(PopUpMenu()
			.items_(Scale.names)
			.font_(font)
			.action_({arg ctrl;
				obj.onScaleChange(ctrl.item);
			})
			.value_(scale)
		);

		hlayout1.add(StaticText().string_("octave").font_(font).maxWidth_(40));

		hlayout1.add(PopUpMenu()
			.items_(octaves)
			.minWidth_(50)
			.maxWidth_(50)
			.font_(font)
			.action_({arg ctrl;
				obj.onOctaveChange(ctrl.item);
			})
			.value_(4)
		);
	};

	populateFiltersPanel = {arg view;

		var layout = view.layout;
		var filters = [""] ++ obj.onFiltersLoad();

		layout.add(Button()
			.string_("node gui")
			.font_(font)
			.action_({obj.onNodeClick()})
		);

		8.do({arg num;
			layout.add(PopUpMenu()
				.items_(filters)
				.font_(font)
				.action_({arg ctrl;
					obj.onFilterChange(num, ctrl.item)
			}), align:\top);
		});
	};

	obj.show = {

		populateGrid.(gridPanelView);
		populateControlPanel.(0, 0);
		populateActionPanel.(actionPanelView);
		populateFiltersPanel.(filtersPanelView);

		main.layout.addSpanning(actionPanelView, 0, 0, columnSpan:3);
		main.layout.add(controlPanelView, 1, 0);
		main.layout.add(gridPanelView, 1, 1);
		main.layout.add(filtersPanelView, 1, 2);

		main.front;
	};

	obj;
};

var build = {arg dur = 0.25, numCols = 16, synth;

	var proto = (instrument: synth.asSymbol, amp:0.1);

	var events = (0..15).collect({
		(0..numCols-1).collect({ () }).asList
	}).asList;

	var loopr = Dloopr3(dur);
	var obj = ();
	var gui = view.(dur, numCols, proto);

	var updateGrid = {
		loopr.grid = events.collect({arg row;
			row.collect({arg col;
				col[\prob] ? 0;
			});
		});
	};

	gui.onCellEnabled = {arg self, view, row, col, degree;
		var event = events[row][col];
		event[\prob] = 1;
		event[\degree] = degree;
		updateGrid.();
	};

	gui.onCellDisabled = {arg self, view, row, col;
		var event = events[row][col];
		event[\prob] = 0;
		updateGrid.();
	};
	gui.onControlPanelLoad = {arg self, row, col;
		proto;
	};

	gui.onCellControlChange = {arg self, name, row, col, val;
		proto[name.asSymbol] = val;
	};
	gui.onPlay = {
		loopr.player.play(quant:1.0);
	};
	gui.onStop = {
		loopr.player.stop();
	};
	gui.onScaleChange = {arg self, scale;
		proto[\scale] = Scale.at(scale.asSymbol);
	};
	gui.onOctaveChange = {arg self, octave;
		proto[\octave] = octave;
	};
	gui.onDurChange = {arg self, dur;
		loopr.dur = dur;
	};
	gui.onNodeClick = {arg self;
		loopr.node.gui;
	};
	gui.onRecStart = {arg self;
		Server.default.record;
	};
	gui.onRecStop = {arg self;
		Server.default.stopRecording;
	};
	gui.onExport = {arg self;
		var nodeCode = loopr.node.asCode;
		var gridCode = loopr.grid.asCode;
		var eventCode = proto.asCode;
		(
			node:nodeCode,
			grid:gridCode,
			event:eventCode;
		)
	};
	gui.onFiltersLoad = {arg self;
		~fx.keys.asArray.collect({arg key; key})
	};
	gui.onFilterChange = {arg self, num, val;

		if ((val.isNil) or: (val == "") ) {
			loopr.node[num] = nil;
		} {
			var filter = ~fx[val.asSymbol];
			var func = filter[\func];
			var specs = filter[\specs];
			specs.do({arg spec;
				var key = spec.key;
				var val = spec.value;
				ControlSpec.specs[key.asSymbol] = val.asSpec;
			});
			loopr.node[num] = \filter -> func;
		}
	};

	loopr.grid = events.collect({arg row;
		row.collect({arg col;
			col[\prob] ? 0;
		});
	});

	loopr.func = {arg y, x, val, time;

		var event, myProto;
		var latency = Server.default.latency;
		AppClock.sched(latency,{
			gui.highlight(y, x, time);
			nil;
		});

		event = events[y][x];
		myProto = proto.copy;
		event.keysValuesDo({arg k,v;
			myProto[k] = v;
		});
		myProto;
	};

	gui.show();
	obj[\gui] = gui;
	obj[\loopr] = loopr;
	obj[\events] = events;

	obj;
};

~stepr1 = build.(0.25, 16, \fsinosc2);

)

//~loopr2003

~loopr2003.loopr.node.vol = 2


