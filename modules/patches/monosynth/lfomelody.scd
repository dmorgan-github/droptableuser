/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// name
~p[\lfomel].clear;
~p[\lfomel].mold;
(~p[\lfomel] = {

	var lfo1 = LFPulse.kr(1/16).range(1/4,1);
	var lfo = min(LFTri.kr([lfo1/4, lfo1/5], mul: 3).tanh, LFDNoise1.kr(lfo1));

	var in = lfo.range(0, 11).round;
	// Kumoi scale
	var scale = [
		\s0.kr(1),
		\s1.kr(0),
		\s2.kr(1),
		\s3.kr(1),
		\s4.kr(0),
		\s5.kr(1),
		\s6.kr(0),
		\s7.kr(1),
		\s8.kr(0),
		\s9.kr(1),
		\s10.kr(0),
		\s11.kr(0)
	];

	var inscale = Select.kr(in, scale);
	var semi = in * inscale;

	var trig = Changed.kr(semi);
	var trig2 = PulseDivider.kr(trig, 3);
	var midi = TChoose.kr(trig2, \root.kr(60) + [0, 12, 24]) + (semi) * (inscale > 0);

	var env = Decay2.kr(in:trig * (inscale > 0), decayTime:lfo1);
	var freq = midi.midicps;
	var sig = SinOscFB.ar(freq.lag(0.01) * [1, 1.01], feedback: SinOsc.kr(0.1).range(0.3,0.7)) * env;

	sig;
})

~p[\lfomel].play
~p[\lfomel].stop
~p[\lfomel].gui;

