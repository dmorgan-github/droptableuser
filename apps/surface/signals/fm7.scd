(
view: {arg objName, envir, util;

	var algos = {arg num;

		var algos = [

			// 0
			[0, 2] -> [
				[0, 1, 1],
				[2, 3, 1],
				[3, 4, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 1
			[0, 2] -> [
				[0, 1, 1],
				[1, 1, 1],
				[2, 3, 1],
				[3, 4, 1],
				[4, 5, 1]
			],

			// 2
			[0, 3] -> [
				[0, 1, 1],
				[1, 2, 1],
				[3, 4, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 3
			[0, 3] -> [
				[0, 1, 1],
				[1, 2, 1],
				[3, 4, 1],
				[4, 5, 1],
				[5, 3, 1]
			],

			// 4
			[0, 2, 4] -> [
				[0, 1, 1],
				[2, 3, 1],
				[5, 5, 1]
			],

			// 5
			[0, 2, 4] -> [
				[0, 1, 1],
				[2, 3, 1],
				[5, 4, 1]
			],

			// 6
			[0, 2] -> [
				[0, 1, 1],
				[2, 3, 1],
				[2, 4, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 7
			[0, 2] -> [
				[0, 1, 1],
				[2, 3, 1],
				[2, 4, 1],
				[4, 5, 1],
				[3, 3, 1]
			],

			// 8
			[0, 2] -> [
				[0, 1, 1],
				[2, 3, 1],
				[2, 4, 1],
				[4, 5, 1],
				[1, 1, 1]
			],

			// 9
			[0, 3] -> [
				[0, 1, 1],
				[1, 2, 1],
				[3, 4, 1],
				[3, 5, 1],
				[2, 2, 1]
			],

			// 10
			[0, 3] -> [
				[0, 1, 1],
				[1, 2, 1],
				[3, 4, 1],
				[3, 5, 1],
				[5, 5, 1]
			],

			// 11
			[0, 2] -> [
				[0, 1, 1],
				[1, 2, 1],
				[2, 3, 1],
				[2, 4, 1],
				[2, 5, 1],
				[2, 2, 1]
			],

			// 12
			[0, 2] -> [
				[0, 1, 1],
				[1, 2, 1],
				[2, 3, 1],
				[2, 4, 1],
				[2, 5, 1],
				[5, 5, 1]
			],

			// 13
			[0, 2] -> [
				[0, 1, 1],
				[2, 3, 1],
				[2, 3, 1],
				[3, 4, 1],
				[3, 5, 1],
				[5, 5, 1]
			],

			// 14
			[0, 2] -> [
				[0, 1, 1],
				[2, 3, 1],
				[2, 3, 1],
				[3, 4, 1],
				[3, 5, 1],
				[1, 1, 1]
			],

			// 15
			[0] -> [
				[0, 1, 1],
				[0, 2, 1],
				[0, 4, 1],
				[2, 3, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 16
			[0] -> [
				[0, 1, 1],
				[0, 2, 1],
				[0, 4, 1],
				[2, 3, 1],
				[4, 5, 1],
				[1, 1, 1]
			],

			// 17
			[0] -> [
				[0, 1, 1],
				[0, 2, 1],
				[0, 3, 1],
				[3, 4, 1],
				[4, 5, 1],
				[2, 2, 1]
			],

			// 18
			[0, 3, 4] -> [
				[0, 1, 1],
				[1, 2, 1],
				[3, 5, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 19
			[0, 1, 3] -> [
				[0, 2, 1],
				[1, 2, 1],
				[3, 4, 1],
				[3, 5, 1],
				[2, 2, 1]
			],

			// 20
			[0, 1, 3, 4] -> [
				[0, 2, 1],
				[1, 2, 1],
				[3, 5, 1],
				[4, 5, 1],
				[2, 2, 1]
			],

			// 21
			[0, 2, 3, 4] -> [
				[0, 1, 1],
				[2, 5, 1],
				[3, 5, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 22
			[0, 1, 3, 4] -> [
				[1, 2, 1],
				[3, 5, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 23
			[0, 1, 2, 3, 4] -> [
				[2, 5, 1],
				[3, 5, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 24
			[0, 1, 2, 3, 4] -> [
				[3, 5, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 25
			[0, 1, 3] -> [
				[1, 2, 1],
				[3, 4, 1],
				[3, 5, 1],
				[5, 5, 1]
			],

			// 26
			[0, 1, 3] -> [
				[1, 2, 1],
				[3, 4, 1],
				[3, 5, 1],
				[2, 2, 1]
			],

			// 27
			[0, 2, 5] -> [
				[0, 1, 1],
				[2, 3, 1],
				[3, 4, 1],
				[4, 4, 1]
			],

			// 28
			[0, 1, 2, 4] -> [
				[2, 3, 1],
				[4, 5, 1],
				[5, 5, 1]
			],

			// 29
			[0, 1, 2, 5] -> [
				[2, 3, 1],
				[3, 4, 1],
				[4, 4, 1]
			],

			// 30
			[0, 1, 2, 3, 4] -> [
				[4, 5, 1],
				[5, 5, 1]
			],

			// 31
			[0, 1, 2, 3, 4, 5] -> [
				[5, 5, 1]
			]
		];

		algos[num];
	};

	var node = NodeProxy.audio(s, 1).source_({

		var trig = \trig.tr(0);

		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var curve = \curve.kr(-4);
		var atk = \atk.kr(0.001);
		var decay = \decay.kr(0);
		var sus = \sus.kr(0);
		var rel = \rel.kr(1);

		var fenv = Env([0,1,0.7,0.7,0],[atk,decay,sus,rel], curve);

		var ctrls = Array.fill(6, {arg i;
			[freq * ('f' ++ i).asSymbol.kr(1), 0, EnvGen.kr(fenv, gate:trig) * ('f' ++ i ++ 'amp').asSymbol.kr(1)]
		});

		var mods = Array.fill2D(6, 6, {arg r, c;
			var key = ('mod' ++ r ++ '_' ++ c);
			key.asSymbol.kr(0)
		});

		var sig = FM7.ar(ctrls, mods) * (0..5).collect({arg i; ('chan' ++ i).asSymbol.kr(0.1)});

		sig = sig * AmpCompA.kr(freq);

		Mix.ar(sig)
	});

	var setMod = {arg row, col, val;
		var key = ('mod' ++ row ++ '_' ++ col).asSymbol;
		node.set(key, val);
	};

	var channels = (0..5).collect({arg i;
		CheckBox().action_({arg ctrl;
			var key = ('chan' ++ i).asSymbol;
			if (ctrl.value) {
				node.set(key, 1);
			} {
				node.set(key, 0);
			}
		})
	});

	var gridBoxes = Array.fill2D(6, 6, {arg r, c;
		NumberBox().minHeight_(15).minWidth_(30)
		.action_({arg ctrl;
			setMod.(r, c, ctrl.value);
		})
		.clipLo_(0)
		.clipHi_(2)
		.decimals_(2)
		.normalColor_(Color.white);
	});

	var grid = GridLayout.rows(
		*(0..5).collect({arg k;
			(0..5).collect({arg i;
				var color = Color.clear;
				if (k == i) {color = Color.blue.alpha_(0.2)};
				gridBoxes[k][i].background_(color)
			})
		})
	).margins_(1).spacing_(0);

	var loadAlgo = {arg num;

		// reset
		var mod_vals = algos.(num-1);
		var chans = mod_vals.key;
		var vals = mod_vals.value;

		6.do({arg i;
			channels[i].valueAction_(0);
			6.do({arg k;
				var color = Color.clear;
				if (i == k) {color = Color.blue.alpha_(0.2)};
				gridBoxes[i][k].valueAction_(0).background_(color);
			});
		});

		chans.do({arg i; channels[i].valueAction_(1)});
		vals.do({arg val;
			gridBoxes[val[0]][val[1]].valueAction_(1).background_(Color.gray);
		});
	};

	var specs = (
		trig: \set,
		freq: \set,
		vrate: [0, 10, \lin, 0, 6],
		vdepth: [0, 1, \lin, 0, 0],
		vdelay: [0, 1, \lin, 0, 0],
		vonset: [0, 1, \lin, 0, 0],
		vrateVar: [0, 1, \lin, 0, 0.04],
		vdepthVar: [0, 1, \lin, 0, 0.1]
	);

	var view = View().layout_(VLayout().spacing_(2).margins_(2));
	var playView = util[\playView].(objName, node, view);
	var specsView = util[\specsView].(objName, specs, node, envir, view);

	view.layout.add(playView);
	view.layout.add(HLayout(
		VLayout(*channels),
		VLayout(*(0..5).collect({arg i;
			Knob().fixedSize_(20).value_(1).action_({arg ctrl;
				var key = ('f' ++ i ++ 'amp').asSymbol;
				var val = ctrl.value;
				[key, val].postln;
				node.set(key, val)
			})
			.valueAction_(1)
			.value_(1)
		})),
		VLayout(
			*(0..5).collect({arg i;
				NumberBox()
				.minHeight_(15)
				.minWidth_(30)
				.clipLo_(0)
				.clipHi_(6)
				.decimals_(2)
				.action_({arg ctrl;
					var key = ('f' ++ i).asSymbol;
					var val = ctrl.value;
					node.set(key, val);
				})
				.value_(1)
				.normalColor_(Color.white)
			})
		),
		grid
	));


	view.layout.add(
		HLayout(

			VLayout(PopUpMenu()
				.items_([""] ++ Array.fill(32, {arg i; i + 1}))
				.action_({arg ctrl;
					loadAlgo.(ctrl.value)
				}),
				StaticText().string_("algo")
			),

			VLayout(Knob().fixedSize_(25).action_({arg ctrl;
				var val = ctrl.value.linlin(0,1,0,10);
				node.set(\atk, val);
			})
			.value_(0.001.linlin(0,10,0,1)),
			StaticText().string_("A").align_(\center)),

			VLayout(Knob().fixedSize_(25).action_({arg ctrl;
				var val = ctrl.value.linlin(0,1,0,10);
				node.set(\decay, val);
			})
			.value_(0.linlin(0,10,0,1)),
			StaticText().string_("D").align_(\center)),

			VLayout(Knob().fixedSize_(25).action_({arg ctrl;
				var val = ctrl.value.linlin(0,1,0,10);
				node.set(\sus, val);
			})
			.value_(0.linlin(0,10,0,1)),
			StaticText().string_("S").align_(\center)),

			VLayout(Knob().fixedSize_(25).action_({arg ctrl;
				var val = ctrl.value.linlin(0,1,0,10);
				node.set(\rel, val);
			})
			.value_(1.linlin(0,10,0,1)),
			StaticText().string_("R").align_(\center)),

			VLayout(Knob().fixedSize_(25).action_({arg ctrl;
				var val = ctrl.value.linlin(0,1,-24,24);
				node.set(\curve, val);
			})
			.value_(-4.linlin(-24,24,0,1)),
			StaticText().string_("curve").align_(\center))
		)
	);

	view.layout.add(specsView);

	envir[objName] = node;

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
};
)


