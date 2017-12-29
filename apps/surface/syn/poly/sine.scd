(
SynthDef(\sine, {

	var dur = \dur.kr(1);
	var freq = \freq.kr(300);
	var sig = FSinOsc.ar(freq);// SinOsc.ar(freq);

	var env = Env([0,1,1,0],[\atk.kr(0.01),\sus.kr(0),\rel.kr(0.99)],[\curve1.kr(-4), \curve2.kr(4)]).kr(timeScale:dur, doneAction:2);

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(0.1);

	Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0)));

}).add;
)

