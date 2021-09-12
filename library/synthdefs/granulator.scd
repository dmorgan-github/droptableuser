(
// adapted from https://github.com/alikthename/Musical-Design-in-Supercollider/blob/master/14_microsound_time_pitch_filters.sc
SynthDef(\granulator, {|buf, freq=20, overlap=2, rate=1, posRate=1|

	var phasor, sig, env;
	var bufFrames = BufFrames.ir(buf);
	var t;

	var freqMod = {
        var freqModFreq = \freqModFreq.kr(0);
        var freqModDepth = \freqModDepth.kr(0);
		SinOsc.ar(freqModFreq, Rand(0.0,2pi)) * freqModDepth;
	};

	var rateMod = {
        var rateModFreq = \rateModFreq.kr(0);
        var rateModDepth = \rateModDepth.kr(0);
		SinOsc.ar(rateModFreq, Rand(0.0,2pi)) * rateModDepth;
	};

	var posRateMod = {
        var posRateModFreq = \posRateModFreq.kr(0);
        var posRateModDepth = \posRateModDepth.kr(0);
		SinOsc.ar(posRateModFreq, Rand(0.0,2pi)) * posRateModDepth;
	};

	freq = freq + freqMod.dup;
	posRate = posRate + posRateMod.dup;
	rate = rate + rateMod.dup;

	t = Impulse.ar(freq.lag(0.05));

	phasor = Phasor.ar(
		trig: 0.0,
		rate: posRate * BufRateScale.kr(buf),
		start: 0.0,
		end: bufFrames,
		resetPos: 0.0
	);

	sig = GrainBuf.ar(
		numChannels: 1,
		trigger: t,
		dur: freq.reciprocal * overlap,
		sndbuf: buf,
		rate: rate,
		pos: phasor / bufFrames,
		interp: 2,
		pan: 0,
		envbufnum: -1,
		maxGrains: 512,
	);

    sig = sig * Env.adsr(
        attackTime:\atk.kr(0.01),
        sustainLevel: 1,
        releaseTime: \rel.kr(8)
    ).ar(gate:\gate.kr(1), doneAction:Done.freeSelf);

    sig = sig * \amp.kr(0.3);

    Out.ar(\out.kr(0), sig);

}).add;
)