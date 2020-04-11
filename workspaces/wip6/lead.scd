/////////////////////////////////////////
// lead node
(
Ndef(\lead, {

    var trig = \trig.tr;
    var sus = \sus.kr(1);
	var gate = Trig1.kr(trig, sus);
	var env = Env.adsr(
		attackTime:\atk.kr(0.01),
		decayTime:\dec.kr(0.3),
		sustainLevel:\suslevel.kr(0.5),
		releaseTime:\rel.kr(1),
		curve:\curve.kr(-4)
	).kr(gate:gate);

	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0.1)), \vrate.kr(6), \vdepth.kr(0.0));
	var detune = \dtune.kr(4.4);
	var sig = {
		var width = \width.kr(0.8);
		var which = \which.kr(0);
		var focus = SinOsc.kr(1/8).range(0.1, 1);//\focus.kr(0.5);
		var sig = {
			var dt = LFNoise2.kr(\dtunedepth.kr(5)).range(detune.neg, detune);
			var tri = VarSaw.ar(freq + dt, width:width);
			var square = Pulse.ar(freq + dt, width:width);
			SelectXFocus.ar(which, [tri, square], focus);
		}.dup(2);
		sig;
	};

	var noise = {
		PinkNoise.ar * \noise.kr(0.2);
	};

	var sub = {
		SinOsc.ar(freq * 0.5) * \sub.kr(0.2);
	};

	sig = (sig.() + noise.() + sub.()) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);

	sig = sig.blend(DFM1.ar(sig, Env.perc(releaseTime:0.5).kr(gate:trig).range(440, 1200), 0.9), 0.5);

	sig = sig.blend(FbC({arg fb;
		PitchShift.ar(fb.reverse, 1, [2, 1.5], 0.01, 0.01) * 0.4 + sig}, TempoClock.default.beatDur * [5/8, 3/4]), 0.3);

	sig = sig.blend(JPverb.ar(HPF.ar(sig, 110), 3, 0, 3), 0.3);

	sig = sig.blend(Squiz.ar(sig, 1.5, SinOsc.kr(1/4).range(1, 10)), 0.1);

	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	sig;
})
)
Ndef(\lead).play;
Ndef(\lead).stop;

/////////////////////////////////////////
// lead base pattern
(
Pdef(\lead, {arg fadeTime=1, monitor=true;

	var node = Ndef(\lead);
	if (node.isMonitoring.not && monitor) {
		node.play(fadeTime:fadeTime)
	};

	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, node.controlNames.collect({arg ctrl; ctrl.name}),
		\amp, -3.dbamp,
		\trig, 1,
		\beatdur, Pfunc({thisThread.clock.beatDur})
	)
}
);
)
Pdef(\lead).play;
Pdef(\lead).stop;


/////////////////////////////////////////
// lead_p1
(
Pdef(\lead_p1, {
	Pbind(
		\octave, 6,
		\dur, Pseq(0.25!6 ++ [0.5, 2], inf),
		\scale, Scale.ritusen,
		\degree, Pshuf([0,1,2,3,4,5,6,7], inf),
		\amp, -60.dbamp,
		\sus, 0.1,
		\timingOffset, 1
	) <> Pdef(\lead)
})
)


Pdef(\lead_p1).play;
Pdef(\lead_p1).stop;


App.saveWorkspace("beat", rec:true);
s.stopRecording;