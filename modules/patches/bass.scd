/////////////////////////////////
// patch
~bass = ProxySpace.new(s);
~bass.quant = 1.0;

/////////////////////////////////
// sequencer
(~bass[\bass_seq][0] = {
	var trig = \trig.tr;
	var freq = \freq.kr;
	[trig, freq];
});
(~bass[\bass_seq][4] = \set -> Pbind(
	\delta, 16,
	\trig, 1,
	\scale, Scale.kumoi,
	\freq, Pseq(['C1', 'C1', 'C1', 'C1', 'F1', 'F1', 'F1', 'Eb1'].namecps, inf)
))

/////////////////////////////////
// trig
~bass[\basstrig] = {~bass[\bass_seq].kr[0]};
/////////////////////////////////
// freq
~bass[\bassfreq] = {~bass[\bass_seq].kr[1]};

/////////////////////////////////
// amp env
(~bass[\bassenv] = {
	var trig_in = ~bass[\basstrig];
	var ts_in = 1;
	var atk_in = 1;
	var sus_in = 8;
	var rel_in = 6;
	var curve_in = -4;
	var ls_in = 1;
	var env = Env.linen(atk_in,sus_in,rel_in,curve:curve_in).kr(gate:trig_in, timeScale:ts_in, mul:ls_in);
	env;
});

/////////////////////////////////
// synth
(~bass[\snd][0] = {

	var amp = 0;
	var freq = 432;

	var sin = SinOsc.kr(1/6).range(0.3, 0.7);
	var lfo = LFTri.kr(sin).range(0.3, 0.7);

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var sig = VarSaw.ar(freq_in, width:lfo);
	sig = sig * AmpCompA.kr(freq_in) * \amp.kr(amp);
	Splay.ar(sig);
});

~bass[\snd].set(\freq, ~bass[\bassfreq], \amp, ~bass[\bassenv], \vdepth, 0.002);

/////////////////////////////////
// play
~bass[\snd].play
~bass[\snd].stop
~bass[\snd].vol = 0.3;


