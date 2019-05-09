
Ndef(\noise)[0] = Fdef(\noise)

(
Ndef(\noise).filter(8, {arg in;
	var freq = 1579;
	var ffreq = Env(
		[0, 1, 0.5, 0.5, 0],
		[\atk.kr, \dec.kr, \sus.kr, \rel.kr],
		-4
	).kr(gate:\trig.tr) + 1 * (freq * 1.5);//.range(freq * 0.5, freq * 2);
	var sig = in;

	sig = BLowPass4.ar(sig, ffreq, 0.7);
	sig = BHiPass4.ar(sig, ffreq, 0.7);
	sig;
}).set(\wet8, 0.9);
)
(
var beat_dur = TempoClock.default.beatDur;
Ndef(\noise).filter(10, {arg in;
	var sig = FbC({arg fb;
		var sig = PitchShift.ar(fb.reverse, 0.5, 2, 0.01, 0.01) * 0.4 + in;
		sig;// ring1: SinOsc.ar(10)
	}, 3, beat_dur * (2.5 + [3/4, 5/8]));
	sig;// ring1: SinOsc.ar(210)
}).set(\wet10, 0.4);
)
(
Ndef(\noise).filter(12, {arg in;
	NHHall.ar(in, 2);
}).set(\wet12, 0.2)
)

(
Ndef(\noise).filter(14, {arg in;
	Squiz.ar(in, [1.5, 2], SinOsc.kr(1/4).range(1, 100))
}).set(\wet14, 0.2)
)

(
Ndef(\noise).filter(16, {arg in;
	JPverb.ar(in, 5, 0, 2);
}).set(\wet16, 0.2)
)

(
Pdef(\noise, {

	var node = Ndef(\noise);
	if (node.isMonitoring.not) {
		node.play;
	};

	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \amp, \sus, \dec, \rel],
		\trig, 1,
		\sus, 0,
		\rel, 0.2,
		\dec, 0.01,
		\dur, 0.25,
		\amp, -3.dbamp * Pbjorklund(3, 8).collect({arg val; if (val == 1) {1}{ rrand(0.3, 0.5) }})
	)
})
)


Pdef(\noise).play;
Pdef(\noise).stop;


App.saveWorkspace("noise", rec:true);
s.stopRecording;