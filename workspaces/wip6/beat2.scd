(
Ndef(\osc1, {

	var trig = \trig.tr;
	var freq = \freq.kr('C1'.namecps);

	var sig = {
		var width = \width.kr(0.5);
		var tri = VarSaw.ar(freq, width:width);
		var square = Pulse.ar(freq, width:width);
		var which = \which.kr(0);
		var focus = \focus.kr(1);
		var sig = SelectXFocus.ar(which, [tri, square], focus);
		sig + (Ndef(\osc2).ar * \fm.kr(0)) + (Ndef(\osc1).ar * 1);
	};

	var sus = \sus.kr(1);
	var gate = Trig1.kr(trig, sus);
	var env = Env.adsr(
		attackTime:\atk.kr(0.01),
		decayTime:\dec.kr(0.3),
		sustainLevel:\suslevel.kr(0.5),
		releaseTime:\rel.kr(1),
		curve:\curve.kr(-4)
	).kr(gate:gate);

	sig = sig.() * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);

	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));

	sig;
})
)

(
Ndef(\osc2, {

	var trig = \trig.tr;
	var freq = \freq.kr('C1'.namecps);

	var sig = {
		var width = \width.kr(0.5);
		var tri = VarSaw.ar(freq, width:width);
		var square = Pulse.ar(freq, width:width);
		var which = \which.kr(0);
		var focus = \focus.kr(1);
		var sig = SelectXFocus.ar(which, [tri, square], focus);
		sig + (Ndef(\osc1).ar * \fm.kr(0)) + (Ndef(\osc2).ar * 1);
	};

	var sus = \sus.kr(1);
	var gate = Trig1.kr(trig, sus);
	var env = Env.adsr(
		attackTime:\atk.kr(0.01),
		decayTime:\dec.kr(0.3),
		sustainLevel:\suslevel.kr(0.5),
		releaseTime:\rel.kr(1),
		curve:\curve.kr(-4)
	).kr(gate:gate);

	sig = sig.() * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);

	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));

	sig;
})
)

/////////////////////////////////////////
// osc1 base pattern
(
Pdef(\osc1, {arg fadeTime=1, monitor=true;

	var node = Ndef(\osc1);
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
Pdef(\osc1).play;
Pdef(\osc1).stop;

/////////////////////////////////////////
// osc2 base pattern
(
Pdef(\osc2, {arg fadeTime=1, monitor=true;

	var node = Ndef(\osc2);
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
Pdef(\osc2).play;
Pdef(\osc2).stop;


(
Ndef(\osc1freq, {
	var trig = \trig.tr;
	var freq1 = 'C6'.namecps;
	var freq2 = 'C1'.namecps;
	var env = Env([freq1, freq1, freq2], [0, 0.1], -24).kr(gate:trig);
	env;
})
)

(
Ndef(\osc2freq, {
	var freq1 = \freq1.kr('C2'.namecps);
	var freq2 = \freq2.kr('C5'.namecps);
	SinOsc.kr(440).range(freq1, freq2)
})
)


Ndef(\mix)[0] = \mix -> {Ndef(\osc1).ar};
Ndef(\mix)[1] = \mix -> { Ndef(\osc2).ar ring1: SinOsc.ar(\ring1.kr(10)) };

Ndef(\osc1).stop;
Ndef(\osc2).stop;

(
Ndef(\mix).filter(10, {arg in;
	var sig = in;
	sig = FbC({arg fb; FreqShift.ar(fb.reverse, [-30, 30]) * 0.7 + sig}, TempoClock.default.beatDur * [3/4, 5/8]);
	sig;
}).set(\wet10, 0.3)
)

(
Ndef(\mix).filter(20, {arg in;
	var sig = in;
	sig = NHHall.ar(sig, 1);
	sig;
}).set(\wet20, 0.1)
)

Ndef(\mix).play(vol:0.1);
Ndef(\mix).stop;

Ndef(\mix).set(\mix1, 1);

TempoClock.default.tempo_(45/60);

(
Pdef(\groove, {

	var mix = Ndef(\mix);
	if (mix.isMonitoring.not) {
		mix.play;
	};

	Ppar([

		Pbind(
			\type, \set,
			\id, Pfunc({Ndef(\osc1freq).nodeID}),
			\args, #[\trig],
			\trig, 1,
			\dur, Pbjorklund2(5,9) * 0.125
		),

		Pbind(
			\freq, Ndef(\osc1freq),
			\dur, 2,
			\sus, 1,
			\rel, 1,
			\fm, 4,
			\which, 0,
			\amp, 0.dbamp
		) <> Pdef(\osc1) <> (monitor:false),

		Pbind(
			\type, \set,
			\id, Pfunc({Ndef(\osc2freq).nodeID}),
			\args, #[\freq2],
			\freq2, Pseq(['C5', 'C7'].namecps, inf),
			\dur, 8
		),

		Pbind(
			\type, \set,
			\id, Pfunc({Ndef(\osc2freq).nodeID}),
			\args, #[\freq1],
			\freq1, Pseq(['C2'].namecps, inf),
			\dur, 8
		),

		Pbind(
			\type, \set,
			\id, Pfunc({Ndef(\mix).nodeID}),
			\args, #[\ring1],
			\ring1, Pseg(Pseq([10, 400, 10], inf), Pseq([5,3,2], inf), -4),
			\dur, 0.125
		),

		Pbind(
			\freq, Ndef(\osc2freq),
			\dur, 1,//Pbjorklund2(7,13) * 0.25,
			\sus, 0.01,
			\rel, 0.05,
			\which, 0,
			\width, 0.8,
			\focus, 0.5,
			\fm, 4,
			\amp, -18.dbamp
		) <> Pdef(\osc2) <> (monitor:false)
	])
})
)

Pdef(\groove).play;
Pdef(\groove).stop;


App.saveWorkspace("wip6", rec:true);
Pdef(\groove).play;
s.stopRecording