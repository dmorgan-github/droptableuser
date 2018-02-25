(
SynthDef(\ethereal_pad, {

	var freq = \freq.kr(300) * [1, 1.01];

	var ts = \ts.kr(1);

	var osc1 = {

		var fb = \fb.kr(0.3);
		var sig = SinOscFB.ar( Vibrato.ar( K2A.ar(freq), 3, 0.01 ), fb, mul:1);
		var env = Env.linen(attackTime:0.1).ar(timeScale: ts);
		var f = freq.cpsmidi + (3 * 12);
		sig = IIRFilter.ar(sig, f.midicps, Rand(0.3, 0.5) );
		sig * env;
	};

	var osc2 = {

		var sig = WhiteNoise.ar(0.8);
		var env = Env.linen(attackTime:0.5).ar(timeScale: ts);
		sig = RLPF.ar(WaveLoss.ar(sig), freq * LFPulse.kr(LFNoise2.kr(1).range(0.5,3)).range(2,4), 0.005);
		sig = JPverb.ar(sig);
		sig * env * 0.5;
	};

	var sig = osc1.() + osc2.();

	sig = Splay.ar(sig) * \amp.kr(0.1) * AmpCompA.kr(freq);

	DetectSilence.ar(sig, time:0.5, doneAction:2);

	Out.ar(\out.kr(0), sig);

}).add
)

~epad = ProxySpace.new(s);
~epad.quant = 1.0;
(
~epad[\snd] = Pbind(
	\instrument, \ethereal_pad,
	\freq, Pseq([
		//['F2', 'D3'].namecps,
		//['B2b', 'G3'].namecps,
		//['E3', 'B2b'].namecps,
		//['E2b', 'G3'].namecps
		['C2', 'A3', 'E3', 'B4'].namecps,
		['D2', 'F3', 'G3', 'A3'].namecps
	], inf),
	\delta, 4,
	\fb, Pwhite(0.5, 0.6),
	\ts, Pkey(\delta) * 0.3,
	\amp, 0.1
)
)

~epad[\snd].play;
~epad[\snd].stop(fadeTime:5);
~epad[\snd].vol = 0.3

(~epad[\snd][4] = \filter -> {arg in;
	JPverb.ar(in, t60:10, size:5);
})
~epad[\snd].set(\wet4, 0.9)







