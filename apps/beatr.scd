(
SynthDef(\bufplayer, {

	var atk = \atk.kr(0.01);
	var dec = \dec.kr(0.0);
	var sus = \sus.kr(0.0);
	var rel = \rel.kr(1);
	var curve = \curve.kr(-4);
	var ts = \ts.kr(1);
	var env = Env([0,1,0.7,0.7,0],[atk,dec,sus,rel],[curve]).ar(timeScale:ts, doneAction:2);

	var rate = \rate.kr(1);
	var buf = \buf.kr(0);
	var startPos = \pos.kr(0);
	var rq = \rq.kr(1);
	var cutoff = \cutoff.kr(2000);
	var bufRateScale = BufRateScale.ir(buf);
	var sig = PlayBuf.ar(1, buf, bufRateScale * rate, 0, startPos, loop:0);

	// try to keep amp stable from filter
	// SC Book Code granulation example fig. 16.20
	//var comp = (rq ** -1) * (400 / cutoff ** 0.5);
	//var fenv = XLine.kr(cutoff*0.1, cutoff, 0.1);// Env([cutoff,cutoff*0.1],[1],[curve]).kr(timeScale:ts);
	//sig = BLowPass4.ar(sig, cutoff, rq);
	sig = sig * env * \amp.kr(0.1);// * comp;
	sig = Pan2.ar(sig, \pan.kr(0));

	OffsetOut.ar(\out.kr(0), sig);

}).add;
)

(

var specs = (
	pos: [0, 1, \lin, 0, 0].asSpec,
	atk: [0, 1, \lin, 0, 0.01].asSpec,
	dec: [0, 1, \lin, 0, 0].asSpec,
	sus: [0, 1, \lin, 0, 0].asSpec,
	rel: [0, 1, \lin, 0, 1].asSpec,
	ts: [0.01, 4, \lin, 0, 1].asSpec,
	envmod: [0.001, 8, \lin, 0, 1].asSpec,
	trans: [-24,24,\lin,1,1].asSpec,
	cutoff: [20, 20000, \exp, 0, 2000].asSpec,
	rq: [0, 1, \lin, 0, 1].asSpec,
	tune: [-64,64,\lin,0.001,1].asSpec,
	pan: [-1,1,\lin,0.1,0].asSpec,
	amp: [0, 10, \lin, 0, 0.1].asSpec,
	atkmul: [0, 200, \lin, 0, 1].asSpec,
);

var env = [[0.0, 0.01, 0.1, 0.5, 1.0], [0.0, 1.0, 0.7, 0.7 ,0.0]];
var times = env[0];
var atk = times[1] - times[0];
var dec = times[2] - times[1];
var sus = times[3] - times[2];
var rel = times[4] - times[3];
var defaultAmp = 0.5;
var colors = { Color.rand; }!4;
var currentSettings = 0;
var numSettings = 8;

var view = {

	var fontFamily = "Courier New";
	var fontSize = 10;
	var font = Font(fontFamily, fontSize);
	var view = View().layout_(GridLayout().margins_(0).spacing_(0));
	var bufpath = StaticText().string_("").font_(font);
	var soundFileView, stackLayout;
	var menu, file, controls, fx, prob, sets, stack;
	var obj = ();
	var changeSettings;
	var selections = Array.fill(numSettings, { Array.fill(4, {[0,0]}) });

	obj.onSoundFileSelected = {arg self;
		"onSoundFileSelected".debug;
	};
	obj.onAtkChange = {arg self, row, col, val;
		[row, col, val].debug("onAtkChange");
	};
	obj.onDecChange = {arg self, row, col, val;
		[row, col, val].debug("onDecChange");
	};
	obj.onSusChange = {arg self, row, col, val;
		[row, col, val].debug("onSusChange");
	};
	obj.onRelChange = {arg self, row, col, val;
		[row, col, val].debug("onRelChange");
	};
	obj.onProbChange = {arg self, row, col, val;
		[row, col, val].debug("onProbChange");
	};
	obj.onPosChange = {arg self, num, val;
		[num, val].debug("onPosChange");
	};
	obj.onTransposeChange = {arg self, num, val;
		[num, val].debug("onTransposeChange");
	};
	obj.onCutoffChange = {arg self, num, val;
		[num, val].debug("onCutoffChange");
	};
	obj.onRqChange = {arg self, num, val;
		[num, val].debug("onRqChange");
	};
	obj.onTuneChange = {arg self, val;
		val.debug("onTuneChange");
	};
	obj.onEnvChange = {arg self, num, vals;
		[num, vals].debug("onEnvChange");
	};
	obj.onStutterChange = {arg self, num, val;
		[num, val].debug("onStutterChange");
	};
	obj.onRevChange = {arg self, num, val;
		[num, val].debug("onRevChange");
	};
	obj.onAmpChange = {arg self, num, val;
		[num, val].debug("onAmpChange");
	};
	obj.onPanChange = {arg self, num, val;
		[num, val].debug("onPanChange");
	};
	obj.onTsChange = {arg self, num, val;
		[num, val].debug("onTsChange");
	};
	obj.onPlay = {arg self;
		"onPlay".debug;
	};
	obj.onStop = {arg self;
		"onStop".debug;
	};
	obj.onExport = {arg self;
		"onExport".debug;
	};
	obj.onDurChange = {arg self, val;
		val.debug("onDurChange");
	};
	obj.onNodeClick = {arg self;
		"onNodeClick".postln;
	};
	obj.onFilterChange = {arg self, num, val;
		[num, val].debug("onFilterChange");
	};
	obj.onFiltersLoad = {arg self;
		[]
	};
	obj.onReaperStart = {arg self;
		"onReaperStart".debug;
	};
	obj.onReaperStop = {arg self;
		"onReaperStop".debug;
	};
	obj.onSettingsChange = {arg self, val;
		[val].debug("onSettingsChange");
	};
	obj.onMetaAtkChange = {arg self, val;
		[val].debug("onMetaAtkChange");
	};

	changeSettings = {arg val;

		var sel;
		currentSettings = val;
		sel = selections[currentSettings];

		soundFileView.setSelection(0, sel[0]);
		soundFileView.setSelection(1, sel[1]);
		soundFileView.setSelection(2, sel[2]);
		soundFileView.setSelection(3, sel[3]);

		obj.onSettingsChange(val);
		4.do({arg i;
			obj.onPosChange(i,sel[i][0]);
			obj.onTsChange(i,sel[i][1]);
		});

		stackLayout.index = val;
	};

	menu = {

		var view = View().layout_(HLayout());

		view.layout.add(Button()
			.string_("open")
			.font_(font)
			.action_({

				Dialog.openPanel(

					okFunc: {arg path;

						var buffer;
						var soundFile = SoundFile.new;

						soundFile.openRead(path);
						buffer = Buffer.readChannel(s, path, channels: [0], action:{arg buf;
							AppClock.sched(0, {
								bufpath.string_(path ++ " (" ++ buf.duration.round(0.01) ++ " sec.)");
								nil;
							});

						});

						soundFileView.soundfile_(soundFile);
						soundFileView.read(0, soundFile.numFrames);
						specs[\pos] = ControlSpec(0, soundFile.numFrames);
						obj.onSoundFileSelected(buffer);
					},
					cancelFunc: {"cancelled"}
				);
			})
		);
		view.layout.add(Button().string_("play").font_(font).action_({
			obj.onPlay();
		}));
		view.layout.add(Button().string_("stop").font_(font).action_({
			obj.onStop();
		}));
		view.layout.add(Button().string_("rec").font_(font).action_({
			//obj.onRecord();
		}));
		view.layout.add(Button().states_([ ["reaper start"],["reaper stop"] ]).font_(font)
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					obj.onReaperStart();
				} {
					obj.onReaperStop();
				};
			});
		);
		view.layout.add(Button().string_("export").font_(font).action_({
			var data = obj.onExport();
			Document.new(string:data.asCompileString);
		}));

		view;
	};

	file = {
		var view = View().layout_(GridLayout());
		var vlayout = View().layout_(VLayout().margins_(0)).maxWidth_(30).maxHeight_(50);

		soundFileView = SoundFileView()
		.background_(Color.clear)
		.minHeight_(250)
		.mouseUpAction_({arg ctrl, x, y;
			var num = soundFileView.currentSelection;
			var selection = soundFileView.selections[num];
			var startPos = selection[0];
			var numFrames = selection[1];
			obj.onPosChange(num, startPos);
			obj.onTsChange(num, numFrames);
			selections[currentSettings] = soundFileView.selections;
		});
		soundFileView.setSelectionColor(0, colors[0].copy.alpha_(0.4));
		soundFileView.setSelectionColor(1, colors[1].copy.alpha_(0.4));
		soundFileView.setSelectionColor(2, colors[2].copy.alpha_(0.4));
		soundFileView.setSelectionColor(3, colors[3].copy.alpha_(0.4));

		soundFileView.gridResolution = 0.0;

		vlayout.layout.add(Button()
			.states_([ ["", nil, colors[0]] ])
			.action_({arg ctrl;
				soundFileView.currentSelection = 0;
			})
		);
		vlayout.layout.add(Button()
			.states_([ ["", nil, colors[1]] ])
			.action_({arg ctrl;
				soundFileView.currentSelection = 1;
			})
		);
		vlayout.layout.add(Button()
			.states_([ ["", nil, colors[2]] ])
			.action_({arg ctrl;
				soundFileView.currentSelection = 2;
			})
		);
		vlayout.layout.add(Button()
			.states_([ ["", nil, colors[3]] ])
			.action_({arg ctrl;
				soundFileView.currentSelection = 3;
			})
		);

		view.layout.addSpanning(bufpath, 0, 0, columnSpan: 3);

		view.layout.add(vlayout, 1, 0, align:\top);

		view.layout.add(soundFileView.minHeight_(100).maxHeight_(100), 1,2);
		view;
	};

	prob = {

		var view = View().layout_(HLayout());
		//var stack = View().layout_(StackLayout().mode_(\stackAll));
		//var vlayout = View().layout_(VLayout().margins_(0)).maxWidth_(30).maxHeight_(60);

		/*
		vlayout.layout.add(Button()
			.action_({ stack.layout.index = 0; })
			.states_([ ["", nil, colors[0]] ]));
		vlayout.layout.add(Button()
			.action_({ stack.layout.index = 1; })
			.states_([ ["", nil, colors[1]] ]));
		vlayout.layout.add(Button()
			.action_({ stack.layout.index = 2; })
			.states_([ ["", nil, colors[2]] ]));
		vlayout.layout.add(Button()
			.action_({ stack.layout.index = 3; })
			.states_([ ["", nil, colors[3]] ]));
		*/

		/*

		4.do({arg i;
			stack.layout.add(EnvelopeView()
				.background_(colors[i].copy.alpha_(0.01))
				.value_(
					[
						Array.fill(16, {arg i; i/16}),
						Array.fill(16, 0)
					])
				.action_({arg ctrl;
					var index = ctrl.index;
					var val = ctrl.value[1][index];
					obj.onProbChange(i, index, val);
				})
			);
		});
		*/

		/*
		view.layout.add(Slider()
			.orientation_(\vertical)
			.maxHeight_(100)
			.maxWidth_(20)
			.action_({arg ctrl;
				var val = ctrl.value;
				var spec = specs[\atkmul];
				obj.onMetaAtkChange(spec.map(val));
			})
			.thumbSize_(10)
			.value_(specs[\atkmul].unmap(1)), 1, 1);

		view.layout.add(Slider()
			.orientation_(\vertical)
			.maxHeight_(100)
			.maxWidth_(20)
			.action_({arg ctrl;
				var val = ctrl.value;
				var spec = specs[\tune];
				obj.onTuneChange(spec.map(val));
			})
			.thumbSize_(10)
			.value_(specs[\tune].unmap(1)), 1, 1);
		*/

		view.layout.add(NumberBox()
			.font_(font)
			.value_(0.25)
			.maxWidth_(50)
			.maxDecimals_(3)
			.action_({arg ctrl;
			obj.onDurChange(ctrl.value);
		}));

		//view.layout.add(vlayout);
		//view.layout.add(stack);
		view;
	};

	controls = {

		var view = View().layout_(GridLayout()).background_(Color.gray);
		var control = {arg num;

			var view = View().layout_(GridLayout()).background_(colors[num]);

			view.layout.addSpanning(EnvelopeView()
				.value_(
					[
						Array.fill(16, {arg i; i/16}),
						Array.fill(16, 0)
					]
				)
				.action_({arg ctrl;
					var index = ctrl.index;
					var val = ctrl.value[1][index];
					obj.onProbChange(num, index, val);
			}), 0, 0, columnSpan:4);

			view.layout.add(Slider()
				.orientation_(\vertical)
				.maxWidth_(15)
				.value_(specs[\amp].unmap(defaultAmp))
				.action_({arg ctrl;
					var val = ctrl.value;
					var spec = specs[\amp];
					obj.onAmpChange(num, spec.map(val));
			}), 1, 0, align:\right);

			view.layout.addSpanning(EnvelopeView()
				.value_(env)
				//.background_(Color.clear.alpha_(0.0001))
				.action_({arg ctrl;

					// [[0.0, 0.01, 0.1, 0.5, 1.0], [0.0,1.0,0.7,0.7,0.0]]
					var val  = ctrl.value;
					var times = val[0];
					var levels = val[1];
					var atk = times[1] - times[0];
					var dec = times[2] - times[1];
					var sus = times[3] - times[2];
					var rel = times[4] - times[3];

					obj.onEnvChange(num, [levels, [atk, dec, sus, rel]]);
			}), 1, 1, columnSpan:3);

			// transpose
			view.layout.add(StaticText().string_("trans").font_(font), 2,0);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.value_(specs[\trans].unmap(0))
				.action_({arg ctrl;
					var val = ctrl.value;
					var spec = specs[\trans];
					obj.onTransposeChange(num, spec.map(val));
			}), 2, 1);

			view.layout.add(StaticText().string_("rev").font_(font), 2,2);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onRevChange(num, val);
			}), 2, 3);

			// ffreq
			view.layout.add(StaticText().string_("cutoff").font_(font), 3,0);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.value_(specs[\cutoff].unmap(2000))
				.action_({arg ctrl;
					var val = ctrl.value;
					var spec = specs[\cutoff];
					obj.onCutoffChange(num, spec.map(val));
			}), 3, 1);

			// rq
			view.layout.add(StaticText().string_("rq").font_(font), 3,2);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.value_(specs[\rq].unmap(1))
				.action_({arg ctrl;
					var val = ctrl.value;
					var spec = specs[\rq];
					obj.onRqChange(num, spec.map(val));
			}), 3, 3);

			view.layout.add(StaticText().string_("stutter").font_(font), 4,0);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onStutterChange(num, val);
			}), 4, 1);

			view.layout.add(StaticText().string_("pan").font_(font), 4,2);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.value_(specs[\pan].unmap(0))
				.action_({arg ctrl;
					var val = ctrl.value;
					var spec = specs[\pan];
					obj.onPanChange(num, spec.map(val));
			}), 4, 3);

			view;
		};

		view.layout.add(control.(0), 0, 0);
		view.layout.add(control.(1), 0, 1);
		view.layout.add(control.(2), 1, 0);
		view.layout.add(control.(3), 1, 1);
		view;
	};

	sets = {
		var view = View().layout_(HLayout());

		numSettings.do({arg i;
			var button = Button()
			.string_("set " ++ (i + 1))
			.font_(font)
			.action_({arg ctrl;
				changeSettings.(i);
			});

			view.layout.add(button);
		});

		view;
	};

	fx = {
		var view = View().layout_(VLayout());
		var filters = [""] ++ obj.onFiltersLoad();
		view.layout.add(Button().font_(font).string_("node").action_({obj.onNodeClick()}));

		8.do({arg num;
			view.layout.add(PopUpMenu()
				.items_(filters)
				.font_(font)
				.action_({arg ctrl;
					obj.onFilterChange(num, ctrl.item)
			}), align:\top);
		});

		view;
	};

	stack = {

		var stackView = View().layout_(StackLayout());
		numSettings.do({

			var view = View().layout_(VLayout());
			view.layout.add(prob.().minWidth_(800));
			view.layout.add(controls.());

			stackView.layout.add(view);
		});

		stackLayout = stackView.layout;
		stackView;
	};

	obj.show = {

		view.layout.addSpanning(menu.(), 0, 0, columnSpan:2);
		view.layout.addSpanning(sets.(),1,0, columnSpan:2);
		view.layout.add(file.(), 2, 0);
		view.layout.addSpanning(fx.(), 2, 1, rowSpan: 4, align:\top);

		view.layout.add(stack.(),3,0);
		//view.layout.add(prob.().minWidth_(800), 3, 0);
		//view.layout.add(controls.(), 4, 0);
		view.front;
	};

	obj;

};

~beatr = {

	var buffer;
	var numTracks = 4;
	var loopr = Dloopr3(0.25);
	var obj = view.();
	var settings = Array.fill(numSettings, {
		(
			events: Array.fill(numTracks, {
				(instrument:\bufplayer,
					atk:atk,
					dec:dec,
					sus:sus,
					rel:rel,
					amp:defaultAmp,
					stut:0,
					rev:0,
					pan:0 )
			}),
			data: Array.fill(numTracks, { Array.fill(16, { () }) }),
			tune: 1,
			grid: Array.fill(numTracks, { Array.fill(16, {0}) }),
			dur: 0.25,
			metaAtk: 1
		)
	});
	var currentSetting = 0;

	loopr.grid = settings[currentSetting][\grid];
	loopr.func = {arg y, x, val, time;

		var events = settings[currentSetting][\events];
		var tune = settings[currentSetting][\tune];
		var data = settings[currentSetting][\data];

		var myProto = events[y].copy;
		var event = data[y][x];

		var rate = (tune + (myProto[\trans] ? 0)).midiratio;
		var atk = myProto[\atk] * (event[\atk] ? 1);
		var dec = myProto[\dec] * (event[\dec] ? 1);
		var sus = myProto[\sus] * (event[\sus] ? 1);
		var rel = myProto[\rel] * (event[\rel] ? 1);

		event.keysValuesDo({arg k,v;
			myProto[k] = v;
		});

		myProto[\rate] = rate * if (myProto[\rev].coin) {-1}{1};
		myProto[\atk] = atk;
		myProto[\dec] = dec;
		myProto[\sus] = sus;
		myProto[\rel] = rel;
		myProto[\buf] = buffer;

		if (myProto[\stut].coin) {

			var div = [1.5,3,4,5];
			if (0.5.coin) {
				var mydiv = div.scramble[0..1];
				var durs = mydiv.collect({arg val; Pn(time/val, val)});
				var dur = Pseq(durs, 1);
				var amp = myProto[\amp];
				myProto[\amp] = Pwhite(amp * 0.4, amp * 0.7, inf);
				myProto[\dur] = dur;
			} {
				var mydiv = div.choose;
				var dur = Pn(time/mydiv, mydiv);
				var amp = myProto[\amp];
				myProto[\amp] = Pwhite(amp * 0.4, amp * 0.7, inf);
				myProto[\dur] = dur;
			};


			myProto = Pbind(*myProto.getPairs);
		};

		myProto;
	};

	obj.onSoundFileSelected = {arg self, buf;
		buffer = buf;
	};
	obj.onAtkChange = {arg self, row, col, val;
		var data = settings[currentSetting][\data];
		data[row][col][\atk] = val;
	};
	obj.onDecChange = {arg self, row, col, val;
		var data = settings[currentSetting][\data];
		data[row][col][\dec] = val;
	};
	obj.onSusChange = {arg self, row, col, val;
		var data = settings[currentSetting][\data];
		data[row][col][\sus] = val;
	};
	obj.onRelChange = {arg self, row, col, val;
		var data = settings[currentSetting][\data];
		data[row][col][\rel] = val;
	};
	obj.onProbChange = {arg self, row, col, val;
		var data = settings[currentSetting][\data];
		loopr.grid[row][col] = val;
	};
	obj.onPosChange = {arg self, num, val;
		var events = settings[currentSetting][\events];
		events[num][\pos] = val;
	};
	obj.onTransposeChange = {arg self, num, val;
		var events = settings[currentSetting][\events];
		events[num][\trans] = val;
	};
	obj.onCutoffChange = {arg self, num, val;
		var events = settings[currentSetting][\events];
		events[num][\cutoff] = val;
	};
	obj.onRqChange = {arg self, num, val;
		var events = settings[currentSetting][\events];
		events[num][\rq] = val;
	};
	obj.onTuneChange = {arg self, val;
		settings[currentSetting][\tune] = val;
	};
	obj.onEnvChange = {arg self, num, val;

		var times = val[1];
		var atk = times[0];
		var dec = times[1];
		var sus = times[2];
		var rel = times[3];
		var events = settings[currentSetting][\events];

		events[num][\atk] = atk;
		events[num][\dec] = dec;
		events[num][\sus] = sus;
		events[num][\rel] = rel;
	};
	obj.onStutterChange = {arg self, num, val;
		var events = settings[currentSetting][\events];
		events[num][\stut] = val;
	};
	obj.onRevChange = {arg self, num, val;
		var events = settings[currentSetting][\events];
		events[num][\rev] = val;
	};
	obj.onAmpChange = {arg self, num, val;
		var events = settings[currentSetting][\events];
		events[num][\amp] = val;
	};
	obj.onPanChange = {arg self, num, val;
		var events = settings[currentSetting][\events];
		events[num][\pan] = val;
	};
	obj.onTsChange = {arg self, num, val;

		var numFrames = val;
		var secs = numFrames/buffer.sampleRate;
		var events = settings[currentSetting][\events];
		events[num][\ts] = if (secs == 0.0) {0.001} {secs};
	};
	obj.onPlay = {arg self;
		loopr.player.play(quant:1.0);
	};
	obj.onStop = {arg self;
		loopr.player.stop();
	};
	obj.onExport = {arg self;

		var events = settings[currentSetting][\events];
		var data = settings[currentSetting][\data];

		var nodeCode = loopr.node.asCode;
		var gridCode = loopr.grid.asCode;
		var eventsCode = events.asCode;
		var dataCode = data.asCode;

		(
			nodeCode: nodeCode,
			gridCode: gridCode,
			eventsCode: eventsCode,
			dataCode: dataCode
		);
	};
	obj.onDurChange = {arg self, val;
		loopr.dur = val;
	};
	obj.onNodeClick = {arg self;
		loopr.node.gui;
	};
	obj.onFiltersLoad = {arg self;
		~fx.keys.asArray.collect({arg key; key})
	};
	obj.onFilterChange = {arg self, num, val;

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
	obj.onReaperStart = {arg self;
		~reaper.record();
		loopr.player.play(quant:1.0);
	};
	obj.onReaperStop = {arg self;
		loopr.player.stop();
		~reaper.doStop();
	};
	obj.onSettingsChange = {arg self, num;

		// preserve the current settings
		var set = settings[currentSetting];

		set[\grid] = loopr.grid;
		set[\dur] = loopr.dur;

		// update to the new settings
		set = settings[num];
		loopr.grid = set[\grid];
		loopr.dur = set[\dur];

		currentSetting = num;
	};

	(gui: obj, loopr: loopr);
};

~beatr3 = ~beatr.();
~beatr3[\gui].show();

)

s.record
s.stopRecording

0.01 * 2.4166666666667

App.soundflowerOut(s);

EnvelopeView

NdefPreset
DictionaryEditor

interpolationData[\lin] = { mapArray.linlin(mapLo, time, 0.0, 1) }.value;
interpolationData[\exp] = { mapArray.linexp(mapLo, time, expLo, 1)}.value;
		interpolationData[\explin] = { mapArray.explin(expLo, time, mapLo,1) }.value;
		interpolationData[\lincurve] = { mapArray.lincurve(mapLo, time,expLo,1,curve) }.value;
		interpolationData[\curvelin] = { mapArray.curvelin(mapLo, time,0.0,1,curve) }.value;
		interpolationData[\ramp] = { rampData.collect { |num| num.ramp } }.value;
		interpolationData[\bilin] = { mapArray.bilin(centerA,mapLo, time,centerB, 0.0, 1)}.value;
		interpolationData[\biexp] = { mapArray.biexp(centerA,expLo, time,centerB, expLo,1.0)}.value;
		interpolationData[\lcurve] = { curveLData.collect{|num| num.lcurve } }.value;
		interpolationData[\scurve] = { normalizedData.collect {|num| num.scurve } }.value;
		interpolationData[\gausscurve] = { gaussData.collect{ |num| num.gaussCurve } }.value;
		interpolationData[\custom] = { mapArray.linlin(mapLo, time, 0.0, 1)  }.value;



[].explin(expLo, time, mapLo,1)

[0,1].interpolate(division:2, type: 'linear', loop:false)

{^Array.fill(newSize, { |i|
			this.intAt( i * ((this.size - 1) / (newSize-1)), type, loop, extra) }); }


intAt {  |index, type = 'linear', loop = true, extra|
		var args, i, ii;
		^if( index.size > 0 ) // multichannel support
			{ index.collect( this.intAt(_, type, loop, extra) ); }
			{
				i = index.floor;
				ii = index.frac;
				case { loop == true }
					{ args = this.wrapAt(i + (-1,0..2)); }
					{ loop == 'fill' }
					{ args = this.fillEnds(1, 2).clipAt(i + (0,1..3));}
					{ loop == false }
					{ args = this.clipAt(i + (-1,0..2)); };
				(			'spline'  : { args.splineInt(ii, extra) },
							'hermite' : { args.hermiteInt(ii) },
							'bspline' : { this.bSplineInt2(index, extra, loop) },
							'quad'    : { args.quadInt(ii) },
							'sine'    : { args.at([1,2]).sineInt(ii) },
							'linear'  : { args.at([1,2]).linearInt(ii) },
							'step'    : { args.at([1,2]).linearInt(ii, 1)  }
					).at(type).value;
			}
		}



Env([0,1],[1],[\sine]).at(0.1)

\step -> 0,
			\lin -> 1,
			\linear -> 1,
			\exp -> 2,
			\exponential -> 2,
			\sin -> 3,
			\sine -> 3,
			\wel -> 4,
			\welch -> 4,
			\sqr -> 6,
			\squared -> 6,
			\cub -> 7,
			\cubed -> 7,
			\hold -> 8,



Pseg(Pseq([0,1]), Pn(1,1), -20, 1).asStream.nextN(16)


(
var numSteps = 16;
var stepsPerSec = 8;
var mapLo =  1 / numSteps;
var time = 4;
var result = Pseries(1/numSteps,1/stepsPerSec, numSteps).asStream.nextN(numSteps);

result.linlin(mapLo, time, 0.0, 1).postln;
)


[1,0.5,1].blend([1,0,0]);

(
var density = 0.5;
var probHi = 0.3;
var probLo = 0.1;
Array.fill(16, { if(density.coin){rrand(probLo,probHi)}{0} });
)


(

var num = 32;
var env = Env([0,1],[1],20);
(0..num-1).collect({arg i; env.at(i/(num-1)) }).plot;

)

0.reciprocal










