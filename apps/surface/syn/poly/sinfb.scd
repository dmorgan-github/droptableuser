(
SynthDef(\sinfb, {

	var dur = \dur.kr(1);

	var freq = {

		var lag = \lag.kr(0.0);
		var freq = \freq.kr(220).lag(lag);
		var rate = \rate.kr(6);
		var depth = \depth.kr(0.02);
		var delay = \delay.kr(0);
		var onset = \onset.kr(0.0);
		var rateVariation = \rateVar.kr(0.04);
		var depthVariation = \depthVar.kr(0.1);
		var iphase = 0;

		Vibrato.ar(K2A.ar(freq),
			rate:rate, depth:depth,
			delay:delay,
			onset:onset,
			rateVariation:rateVariation,
			depthVariation:depthVariation,
			iphase:0,
			trig: 1);
	}.();

	var sig = SinOscFB.ar(freq, \fb.kr(0.7));

	var env = Env.perc(attackTime: \atk.kr(0.01), releaseTime:\rel.kr(1)).kr(timeScale:dur, doneAction:2);

	sig = sig * env * AmpCompA.ar(freq) * \amp.kr(0.1);

	Out.ar(\out.kr(0), Pan2.ar(sig, Rand(-1, 1)));

}).add;
)