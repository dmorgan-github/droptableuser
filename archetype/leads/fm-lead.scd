(
ProxySynthDef(\fmdrone, {arg t_trig = 1;

	var num = 1e-6;
	var freq = \freq.kr(300);

	var indexgate = \egate.kr(1);
	//var index = App.makeRetrigEnv(\i, [6, 3], [1], [4], indexgate);
	var index = Env([6,6,3],[0,1],[4]).kr(gate: indexgate);

	//var fenv = App.makeRetrigEnv(\f, [2880, 270, 290], [0.5, 0.5], [-4, -4], t_trig);
	var fenv = Env([2880, 2880, 270, 290],[0, 0.5, 0.5], [-4,-4]).kr(gate: t_trig);

	//var qenv = App.makeRetrigEnv(\q, [0.5, 0.1, 0.5], [0.5, 0.5], [-4, -4], t_trig);
	var qenv = Env([0.5, 0.5, 0.1, 0.5], [0, 0.5, 0.5], [-4, -4]).kr(gate: t_trig);

	var modmul1 = \modmul1.kr(2);
	var modmul2 = \modmul2.kr(2);

	var env = EnvGen.kr(Env([0, 0, 1, 0.7, 0], [num, 0.01, 1, 1], [-4, 4], releaseNode: 3), gate: \egate.kr(1), timeScale: NamedControl.kr(\dur, 1) );
	var sig = PMOsc.ar(freq, freq * [modmul1.lag(0.05), modmul2.lag(0.05)], index.lag(0.1), mul:0.8);// + Gendy1.ar(mul:0.5);
	sig = sig + SyncSaw.ar(freq, freq * [modmul1, modmul2]);
	sig = RLPF.ar(sig, fenv, qenv);
	Splay.ar(sig) * env;

}).add;

)


(Pdef(\FMdrone,
	Pproto({

		"\FMdrone".debug("playing");
		Ndef(\FMdrone).play;
		~group = Ndef(\FMdrone).group;
		~out = Ndef(\FMdrone).bus;

	}, Pchain(Pmono(\fmdrone), Pbindef(\fmdrone,
		\delta, Prout({

			var queue = LinkedList.new;
			var seq = Pseq([1, 1], inf).asStream;
			var dur;

			inf.do({

				if (queue.isEmpty) {
					var val = seq.next();

					(val * [ [0.25, 0.25] ].choose.normalizeSum).do({arg item;
						queue.add(item);
					});
				};

				dur = queue.popFirst;
				(dur * 0.25).yield
			});
		}),
		\egate, Pwrand([1, 0], [0.7, 0.3], inf),
		\dur, Pkey(\delta) * Pwhite(0.1, 0.8, inf),

		\degree, Pseq([0, 1, 3, 4], inf),
		\octave, Pstutter(8, Prand([3, 4, 5], inf)),
		\lag, 0.12,
		\modmul1, Pstutter(4, Pseq([1.3, 2, 2.5], inf)),
		\modmul2, Pstutter(3, Pseq([2.3, 3, 4.5], inf)) * Pseq([2, 3], inf),
		\t_trig, 1
	)))
);
)

Ndef(\FMdrone)[0] = \filter -> {arg in;
	FbC({arg fb;
		in + fb.reverse.lag(0.5) + JPverb.ar(fb.distort) * 0.4
	}, 0.375);
}

Pdef(\FMdrone).play(quant:1.0)





