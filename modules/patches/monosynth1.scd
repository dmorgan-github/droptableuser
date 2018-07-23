~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 1.0;

//////////////////////////////////////////////
// synth
(~p[\synth][0] = {

	var trig = \trig.tr;
	var freq_in = \freq.kr(432);

	var freq = Vibrato.ar(K2A.ar(freq_in.lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var osc1 = {
		var sig = SinOsc.ar(freq) * \osc1.kr(0.5);
		var env = Env.linen(
			\osc1_atk.kr(0.01),
			\osc1_sus.kr(0.1),
			\osc1_rel.kr(0.1),
			curve:\osc1_curve.kr(-4)
		).kr(gate:trig);
		sig * env;
	};

	var osc2 = {
		var myTrig = PulseDivider.kr(trig, 2);
		var sig = VarSaw.ar(freq, width:SinOsc.kr(0.5).range(0.2, 0.7)) * \osc2.kr(0.5);
		var env = Env.linen(
			\osc2_atk.kr(0.01),
			\osc2_sus.kr(0.1),
			\osc2_rel.kr(0.2),
			curve:\osc2_curve.kr(-4)
		).kr(gate:myTrig);
		sig * env;
	};

	var sig = [osc1.(), osc2.()];

	Pan2.ar(sig.sum) * AmpCompA.kr(freq) * \amp.kr(0.3);
});

(
~p[\synth][1] = \set -> Pbind(
	\trig, 1,
	\scale, Scale.lydian,
	\octave, Pbjorklund(3,8,inf).collect({arg val; if (val == 0) {5}{6}}),
	[\delta, \degree], Prout({

		var durs = [0.125];
		var degrees = Ppatlace([

			Pseq([
				Pseq([0, 7], 1),
				Pseq([0, -9], 1),
				Pseq([8, 2], 1),
				//Pseq([-1, -7], 1)
			], inf)
			,
			Pshuf([1,2,3,4,5], inf)
		], inf);

		var durSeq = Pseq(durs, inf);
		var degreesSeq = degrees;

		var result = Ptuple([durSeq, degreesSeq], inf).asStream;

		loop({
			result.next.yield;
		});
	}),
	\amp, Pbjorklund(3,8, inf, 3).collect({arg val; if (val == 0) {1}{0.4}}) * 0.2,
))
)

~p[\synth].set(\osc1, 0.8, \osc2, 0.2, \sus, 0.02, \vdepth, 0.005, \lag, 0.01);
~p[\synth].play(out:0);
~p[\synth].stop;

(~p[\send_del] = {

	var in = \in.ar([0, 0]);
	var del = \del.kr(1.4).lag(0.1);
	var fx = DelayC.ar(in, 4, [3/4, 5/4]);
	var ld = RLPF.ar(fx[0], 1280, 0.2);
	var trig = Impulse.kr(1/16);
	var env = Env.perc.kr(gate:trig).range(200, 3200);
	var left = LeakDC.ar(FreqShift.ar(ld.abs, env)) * 0.4;

	fx = [
		DelayC.ar(left, 3/4, 3/4, add:ld),
		(fx[1] * 2).tanh * 0.8];
	fx;
});


//////////////////////////////////////////////
// ui
(
Slider()
.minWidth_(100)
.maxHeight_(50)
.orientation_(\horizontal)
.action_({arg ctrl;
	var val = ctrl.value.linlin(0,1,0,4);
	~p[\send_del].set(\del, val);
	[\send_del, \del, val].postln;
})
.value_(~p[\send_del].get(\del).linlin(0,4,0,1))
.front
)

//////////////////////////////////////////////
// play
~p[\send_del] <<> ~p[\synth];
~p[\send_del].play(out:0);
~p[\send_del].stop;
~p[\send_del].vol = 0.3;


App.recordWorkspace("ws13");
s.stopRecording;
