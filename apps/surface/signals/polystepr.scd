(
view: {arg name, envir;

	var node = NodeProxy.audio.quant_(1.0);
	var instrument, scale = \minor;
	var octave = 5;
	var height = 20;
	var seq = (0..7).collect({ (0..15).collect( { 0 }  ) });

	var pbind = {arg i;

		var rtn = Routine({
			inf.do({arg i;
				var vals = seq.collect({arg row, n; var col = i%row.size; [n, row[col]] });
				vals.flop.yield;
			})
		});

		PbindProxy(
			\instrument, Pfunc({instrument.asSymbol}),
			\vol, 0,
			\scale, Pfunc({Scale.at(scale.asSymbol)}),
			\octave, Pfunc({octave}),
			[\degree, \amp], rtn * Ptuple([1, Pkey(\vol)], inf),
			\mtranspose, 0,
			\delta, 1/(i+1),
			\dur_mul, 1,
			\dur, Pkey(\delta) * Pkey(\dur_mul) * Pfunc({thisThread.clock.beatDur})
		)
	};

	var cellOn = {arg y, x;
		var id = ((8 * y) + x);
		if (node[id].isNil) {
			var proxy = pbind.(x);
			proxy.set(\mtranspose, y);
			proxy.set(\vol, 0.1);
			node[id] = proxy;
		} {
			node[id].set(\vol, 0.1);
		};
	};

	var cellOff = {arg y, x;
		var id = ((8 * y) + x);
		node[id] = nil;
	};

	var view = View().layout_(VLayout().margins_(2).spacing_(2));
	var status = StaticText().string_("");

	var stepGrid = {
		var view = View().layout_(GridLayout().margins_(2).spacing_(2));
		8.do({arg i;

			16.do({arg n;
				view.layout.add(
					Button()
					//.fixedSize_(20@20)
					.states_([ ["", "", Color.grey], ["", nil, Color.white] ])
					.action_({arg ctrl;
						seq[7-i][n] = ctrl.value;
					}),
					i, n
				);
			})
		});

		view;
	};

	var partGrid = {

		var view = View().layout_(VLayout().margins_(2).spacing_(2));
		var ampDur = View().layout_(GridLayout().margins_(2).spacing_(2));
		var grid = View().layout_(GridLayout().margins_(2).spacing_(2));

		8.do({arg i;
			ampDur.layout.add(
				Slider2D().action_({arg ctrl;

					var y = ctrl.y;
					var x = ctrl.x;
					var dur = x.linlin(0,1,0.01,16);

					8.do({arg n;
						var id = ((8 * n) + i);
						if (node[id].isNil.not) {
							node[id].set(\vol, y, \dur_mul, dur);
						}
					});

				})
				//.step_(0.0001)
				.setXY(1.linlin(0.01,16,0,1),0.1), 0, i
			);
		});
		view.layout.add(ampDur);

		8.do({arg i;
			8.do({arg n;
				grid.layout.add(
					Button()
					//.fixedSize_(40@20)
					.states_([ ["", "", Color.grey], ["", nil, Color.white] ])
					.action_({arg ctrl;
						if (ctrl.value == 1) {
							cellOn.(7-i,n);
						} {
							cellOff.(7-i,n);
						}
					}),
					i + 1, n
				);
			});
		});
		view.layout.add(grid);

		view;
	};

	view.layout.add(StaticText().string_(name));
	view.layout.add(
		HLayout(

			TextField()
			.minWidth_(100)
			.action_({arg ctrl; instrument = ctrl.value; status.string_(instrument)}),

			PopUpMenu()
			.items_(Scale.names)
			.action_({arg ctrl;
				scale = ctrl.item; status.string_(scale)
			}),

			Slider()
			.orientation_(\horizontal)
			.thumbSize_(10)
			.minWidth_(50)
			.value_(1.linlin(0.1, 8, 0, 1))
			.action_({arg ctrl;
				var val = ctrl.value.linlin(0, 1, 0.1, 8);
				node.fadeTime = val;
				status.string_("fadetime: " ++ val.asString);
			}),

			PopUpMenu()
			.items_([8,7,6,5,4,3,2,1])
			.value_(3)
			.action_({arg ctrl;
				octave = ctrl.item;
			}),

			Button()
			//.fixedSize_(30@height)
			.states_([ ["play"], ["stop"] ])
			.string_("play")
			.action_({arg ctrl;
				if (ctrl.value == 1) {
					node.play;
				} {
					node.stop;
				}
			}),

			Button()
			//.fixedSize_(30@height)
			.string_("doc")
			.mouseDownAction_({arg ctrl;
				node.document;
				seq.asCompileString.postln;
			})
		)
	);



	node.fadeTime = 1;
	envir[name] = node;

	view.fixedWidth_(400);
	view.layout.add(stepGrid.());
	view.layout.add(partGrid.());
	view.layout.add(status);
	view.onClose_({
		node.clear(fadeTime:node.fadeTime);
		{
			node = nil;
			envir[name] = nil;
		}.defer(node.fadeTime + 1);
	});
	view;
};
)

