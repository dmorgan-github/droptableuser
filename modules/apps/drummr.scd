
(

var view;
var obj = ();
var specs;

obj.onSoundFileSelected = {arg self;
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

specs = (
	pos: \amp.asSpec,
);

view = {

	var fontFamily = "Courier New";
	var fontSize = 10;
	var font = Font(fontFamily, fontSize);
	var view = View().layout_(GridLayout().margins_(0).spacing_(0));
	var bufpath = StaticText().string_("").font_(font);
	var soundFileView;

	var menu = {

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

						obj.onSoundFileSelected(buffer);
						//soundFileView.mouseUpAction.value(soundFileView);
					},
					cancelFunc: {"cancelled"}
				);
			})
		);
		view.layout.add(Button().string_("play").font_(font).action_({
			obj.onPlay();
		}));
		view.layout.add(Button().string_("rec").font_(font).action_({
			obj.onRecord();
		}));
		view.layout.add(Button().string_("export").font_(font).action_({
			obj.onExport();
		}));

		view;
	};

	var file = {
		var view = View().layout_(GridLayout());

		soundFileView = SoundFileView()
		.background_(Color.gray(0.3));
		//.mouseUpAction = ({arg view;
		//	var loFrames, hiFrames, loSlider, hiSlider;
		//	loFrames = view.selection(0)[0];
		//	hiFrames = view.selection(0)[1] + loFrames;
		//	loSlider = specs[\pos].unmap(loFrames);
		//	hiSlider = specs[\pos].unmap(hiFrames);
		//	2.do{centerPosSlider.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
		//});
		soundFileView.timeCursorOn = true;
		soundFileView.timeCursorColor = Color.blue(alpha:0.5);
		soundFileView.setSelectionColor(0, Color.blue(alpha:0.5));
		soundFileView.gridResolution = 0.0;

		view.layout.addSpanning(bufpath, 0, 0, columnSpan: 2);
		view.layout.add(Slider()
			.orientation_(\vertical)
			.maxHeight_(100)
			.action_({arg ctrl;
				var val = ctrl.value;
				obj.onTuneChange(val);
			})
			.thumbSize_(10), 1,0
		);
		view.layout.add(soundFileView.minHeight_(100).maxHeight_(100), 1,1);
		view;
	};

	var grid = {

		var view = View().layout_(GridLayout());

		var gridButton = {arg row, col, color;

			var view = View().layout_(GridLayout().margins_(0).spacing_(0)).background_(color);

			view.layout.add(Slider()
				.orientation_(\horizontal)
				.minWidth_(35)
				.maxWidth_(35)
				.maxHeight_(10)
				.thumbSize_(10)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onAtkChange(row, col, val);
			}), 0,0);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxWidth_(35)
				.maxHeight_(10)
				.thumbSize_(10)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onDecChange(row, col, val);
			}), 1,0);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxWidth_(35)
				.maxHeight_(10)
				.thumbSize_(10)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onSusChange(row, col, val);
			}), 2,0);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxWidth_(35)
				.maxHeight_(10)
				.thumbSize_(10)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onRelChange(row, col, val);
			}), 3,0);
			view.layout.addSpanning(Slider()
				.orientation_(\vertical)
				.maxWidth_(10)
				.thumbSize_(10)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onProbChange(row, col, val);
			}), 0, 1, rowSpan:4);

			view;
		};

		4.do({arg i;
			var color = Color.rand;
			16.do({arg n;
				view.layout.add(gridButton.(i, n, color), i, n);
			});
		});

		view;
	};

	var controls = {
		var view = View().layout_(GridLayout());

		var control = {arg num;

			var view = View().layout_(GridLayout());

			view.layout.addSpanning(EnvelopeView()
				.value_([[0.0, 0.1, 0.5, 0.5, 1.0],[0.0,1.0,0.7,0.9,0.0]])
				.action_({arg ctrl;
					var val  = ctrl.value;
					var times = val[0];
					var levels = val[1];
					var atk = times[1] - times[0];
					var dec = times[2] - times[1];
					var sus = times[3] - times[2];
					var rel = times[4] - times[3];

					obj.onEnvChange(num, [levels, [atk, dec, sus, rel]]);
			}), 0, 0, columnSpan:4);

			// pos
			view.layout.add(StaticText().string_("pos").font_(font), 1,0);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onPosChange(num, val);
			}), 1, 1);
			// transpose
			view.layout.add(StaticText().string_("trans").font_(font), 1,2);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onTransposeChange(num, val);
			}), 1, 3);
			// ffreq
			view.layout.add(StaticText().string_("cutoff").font_(font), 2,0);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onCutoffChange(num, val);
			}), 2, 1);
			// rq
			view.layout.add(StaticText().string_("rq").font_(font), 2,2);
			view.layout.add(Slider()
				.orientation_(\horizontal)
				.maxHeight_(15)
				.action_({arg ctrl;
					var val = ctrl.value;
					obj.onRqChange(num, val);
			}), 2, 3);

			view;
		};

		view.layout.add(control.(0), 0, 0);
		view.layout.add(control.(1), 0, 1);
		view.layout.add(control.(2), 1, 0);
		view.layout.add(control.(3), 1, 1);
		view;
	};

	var fx = {
		var view = View().layout_(VLayout());
		view.layout.add(Button());
		view;
	};

	view.layout.addSpanning(menu.(), 0, 0, columnSpan:2);

	view.layout.add(file.(), 1, 0);
	view.layout.addSpanning(fx.(), 1, 1, rowSpan: 3, align:\top);

	view.layout.add(grid.(), 2, 0);
	view.layout.add(controls.(), 3, 0);
	view.front;

};

view.();

)


/*
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
*/


)