/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

//////////////////////////////////////////////
// resonator
~p[\res].clear;
(~p[\res][0] = {

	var in = {
		var trig = \trig.tr;
		var env = Env([1,1,0],[0,0.05],-4).kr(gate:trig);
		PinkNoise.ar * env;
	}.();

	var numFreqs = 6;

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(432).varlag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var detune = \detune.kr(0);

	var ffreqs = (0..numFreqs-1).collect({arg i;
		(\f ++ i).asSymbol.kr(1);
	}) + detune;

	var amps = (0..numFreqs-1).collect({arg i;
		(\a ++ i).asSymbol.kr(1/numFreqs);
	});

	var rings = (0..numFreqs-1).collect({arg i;
		(\r ++ i).asSymbol.kr(1);
	});

	var sig = DynKlank.ar(`[freq_in * ffreqs, amps, rings], in);

	sig = sig * AmpCompA.kr(freq_in) * \amp.kr(0);

	Mix.ar(sig)!2;
});


(~p[\res][4] = \set -> Pbind(
	\trig, 1,
	\scale, Scale.kumoi,
	\degree, Ppatlace([Pseq([0,6], inf), Pseq([2,1,3,4], inf)], inf),
	\ctranspose, Pstep(Pseq([0, -5, 2, -7], inf), Pseq([4,4,4,4] * 4, inf), inf),
	\octave, 3,
	\delta, 1,
	\amp, Pbjorklund(7,11,inf) * 0.1,

	\foo, Pseg([0, 50, 25, 0], [1, 2, 3], \lin, inf),

	\f0, 1.02340 * Pkey(\foo).lincurve(0, 50, 1, 2, 24),
	\f1, 3.2  * Pkey(\foo).lincurve(0, 50, 1, 2, -24),
	\f2, 5.234 * Pkey(\foo).lincurve(0, 50, 1, 2, 4),
	\f3, 9.123 * Pkey(\foo).lincurve(0, 50, 1, 2, -4),
	\f4, 11.23  * Pkey(\foo).lincurve(0, 50, 1, 2, 10),
	\f5, 13.93930 * Pkey(\foo).lincurve(0, 50, 1, 2, -10),

	\detune, 0.001,

	\r0, 1,
	\r1, 1/2,
	\r2, 1/4,
	\r3, 1/5,
	\r4, 1/6,
	\r5, 1/8,

	\vdepth, 0.001,
	\lag, 0

))

~p[\res].play();
~p[\res].stop();






(
Fdef(\resui, {arg node;

	var view = View().layout_(VLayout().margins_(0).spacing_(0));
	view.layout.add(
		HLayout(
			*(0..5).collect({arg i;
				Slider2D().fixedSize_(45)
				.action_({arg ctrl;
					var key1 = ('f' ++ i).asSymbol;
					var key2 = ('r' ++ i).asSymbol;
					var f = ctrl.x.linlin(0,1,0,16);
					var r = ctrl.y;
					[f,r].postln;
					node.set(key1, f, key2, r);
				})
			});
		)

	);
	view.front;
});
Fdef(\resui).(~p[\res]);
)


App.recordWorkspace("ws8");
s.stopRecording
