~p = ~p ? ProxySpace.new(s, \p);

//////////////////////////////////////////////
// resonator
~p[\res].clear;
(~p[\res][0] = {

	var in = {
		var trig = \trig.tr;
		var env = Env([1,1,0],[0,0.05],-4).kr(gate:trig);
		PinkNoise.ar/* Blip.ar(200, 30)*/ * env;
		//~p[\fx4].ar * env;
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
	\delta, 0.125,
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

(~p[\res][12] = \filter -> {arg in;

	var sig;
	var tap1, tap2, tap3;
	var fbNode = FbNode(2, 1.304, 4);

	tap1 = BBandPass.ar( fbNode.delay(0.2), 4400, 0.5);
	tap2 = BBandPass.ar( fbNode.delay(0.27) * 0.4, 880, 1.5);
	tap3 = BBandPass.ar( fbNode.delay(1.303) * 0.2, 2200, 3.5);

	sig = [tap2 + tap3, in + tap1];

	fbNode.write(in);

	sig;
});

(~p[\res][14] = \filter -> {arg in;
	JPverb.ar(in);
})

~p[\res].set(\wet12, 1, \wet14, 0.2)

~p[\res].play(fadeTime:4);
~p[\res].stop(fadeTime:10);

App.recordWorkspace("ws6");
s.stopRecording;


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
