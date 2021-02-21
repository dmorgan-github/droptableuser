// adapted from here
// https://fredrikolofsson.com/f0blog/n-fm7-patches/
(
SynthDef(\fm7noise, {

	var sig;
	var chans = #[0, 1];

	var ctrls = 6.collect({|ctrl|
		["f", "p", "a"].collect({|val|
			["freq", "phase", "mul", "add"].collect({|param|
				"op_%_%_%".format(ctrl, val, param).asSymbol().kr(0)
			});
		});
	});

	var mods = 6.collect({|row|
		6.collect({|col|
			["freq", "phase", "mul", "add"].collect({|param|
				"mod_%_%_%".format(row, col, param).asSymbol().kr(0)
			});
		});
	});

	ctrls = ctrls.collect({|ctrl| ctrl.collect({|vals| LFSaw.ar(*vals) })});
	mods = mods.collect({|mod| mod.collect({|vals| LFSaw.ar(*vals) })});

	sig = FM7.ar(ctrls, mods).slice(chans) * \amp.kr(0.1);
	sig = sig * Env.asr.ar(doneAction:Done.freeSelf, gate:\gate.kr(1));
	sig = Splay.ar(sig, 0);
	Out.ar(\out.kr(0), sig);

}).add;
)

(
var func = {|seed=1000000|

	var randseed = thisThread.randSeed_(seed);
	var ctrls = 6.collect({|ctrl|
		["f", "p", "a"].collect({|val|
			["freq", "phase", "mul", "add"].collect({|param|
				["op_%_%_%".format(ctrl, val, param).asSymbol(), 1.5.linrand.round(0.25)]
			}).flatten;
		}).flatten;
	});

	var mods = 6.collect({|row|
		6.collect({|col|
			["freq", "phase", "mul", "add"].collect({|param|
				["mod_%_%_%".format(row, col, param).asSymbol, 1.5.linrand.round(0.25)]
			}).flatten;
		}).flatten;
	});

	var pairs = ctrls.flatten ++ mods.flatten;
	pairs;
};

Pdef(\fm7noise, {

	var seed = 723528;//nil;//187437;//nil;//67193;//843353; //83506
	var dur = 16;

	Pspawner({|sp|
		inf.do({
			var myseed = seed ?? { 1000000.rand; };
			var pairs = func.(myseed.debug(\seed));
			var ptrn = sp.par(Pbind(\instrument, \fm7noise, \amp, 0.1) <> Pbind(*pairs));
			sp.wait(dur);
			sp.suspend(ptrn);
		});
	})
})
)

987280
30829
67193
843353
918344
113701
951385
Pdef(\fm7noise).play(argClock:t, quant:[3.0, 0.5]);
Pdef(\fm7noise).stop;


