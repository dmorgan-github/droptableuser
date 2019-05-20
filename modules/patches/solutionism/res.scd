TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// set up voices
Ndef(\varsaw)[0] = Fdef(\varsaw);
Ndef(\res)[0] = Fdef(\res);
Ndef(\syncsaw)[0] = Fdef(\syncsaw);

(
Ndef(\res).filter(10, {arg in;
	in ring1: SinOsc.ar(10);
})
)



/////////////////////////////////////////
// create synth
(Ndef(\res_synth)[0] = {
	var v1 = Ndef(\syncsaw).ar;
	var v2 = Ndef(\varsaw).ar;
	var v3 = Ndef(\res).ar.blend(
		Fold.ar(Ndef(\res).ar * 2,
			SinOsc.kr(1/2).range(-0.5, -0.1),
			SinOsc.kr(1/4).range(0.1, 1)
	), 0.9) * 0.7;
	var which = \which.kr(0);
	var focus = \focus.kr(1);
	var sig = SelectXFocus.ar(which, [
		v1,
		v2,
		Fold.ar(v3.blend(PitchShift.ar(JPverb.ar(v3, 3, 0, 3), 1, [1.5, 2], 0.01, 0.01), 0.5) * 8,
			LFNoise2.kr(1).range(-1.0, -0.1), SinOsc.kr(1).range(0.1, 1.0)) * 0.08
	], focus, wrap:true);

	sig = sig + LocalIn.ar(2);
	LocalOut.ar(DelayC.ar(RLPF.ar(sig.reverse, \ffreq.kr(880), \rq.kr(0.8)) * \fb.kr(0.55), 0.2));
	sig;
});

Ndef(\res_synth).get(\squizpitch) = 2.98
Ndef(\res_synth).get(\squiz) = 3.97
Ndef(\res_synth).get(\fb) = 0.62

/////////////////////////////////////////
// ui

(
var view = View().background_(Color.white).layout_(VLayout(
	EzKnob("fb")
	.action_({arg ctrl, spec;
		Ndef(\res_synth).set(\fb, spec.map(ctrl.value))
	})
	.value_(0.55)
	.format_({arg knob, label, nb;
		knob.background_(Color.rand)
	})
	.toView,

	EzKnob("squizpitch", [1, 12, \lin, 0, 1].asSpec)
	.value_(1)
	.action_({arg ctrl, spec;
		Ndef(\res_synth).set(\squizpitch, spec.map(ctrl.value))
	})
	.format_({arg knob, label, nb;
		knob.background_(Color.rand)
	})
	.toView,

	EzKnob("squiz", [1, 100, \lin, 0, 1].asSpec)
	.value_(1)
	.action_({arg ctrl, spec;
		Ndef(\res_synth).set(\squiz, spec.map(ctrl.value))
	})
	.format_({arg knob, label, nb;
		knob.background_(Color.rand)
	})
	.toView,

	EzKnob("rq")
	.value_(1)
	.action_({arg ctrl, spec;
		Ndef(\res_synth).set(\rq, ctrl.value)
	})
	.format_({arg knob, label, nb;
		knob.background_(Color.rand)
	})
	.toView,

	EzKnob("ffreq", \freq.asSpec)
	.value_(880)
	.action_({arg ctrl, spec;
		Ndef(\res_synth).set(\ffreq, spec.map(ctrl.value));
	})
	.format_({arg knob, label, nb;
		knob.background_(Color.rand)
	})
	.toView

)).front;
~view = view;
)


/////////////////////////////////////////
// fx chain
(
Ndef(\res_synth).filter(10, {arg in;
	var sig = Compander.ar(in, in, 0.5, 1, 1/40);
	sig;
}).set(\wet10, 1);
Ndef(\res_synth).filter(15, {arg in;
	var sig = in;
	sig = FbC({arg fb; fb * 0.5 + sig}, TempoClock.default.beatDur * 0.1);
	sig;
}).set(\wet15, 0.3);
Ndef(\res_synth).filter(20, {arg in;
	var sig = in;
	sig = JPverb.ar(sig, 2, 0, 5);
	sig;
}).set(\wet20, 0.3);
)

/////////////////////////////////////////
// init settings
(
Ndef(\res)
.set(
	\amp, -9.dbamp,
	\res, 0.001,
	\atk, 0.001,
	\sus, 0.2,
	\rel, 1,
	\dec, 0,
	\vdepth, 0.01
);

Ndef(\varsaw)
.set(
	\amp, -15.dbamp,
	\atk, 0.001,
	\sus, 0.2,
	\dec, 0.1,
	\rel, 0.1
);

Ndef(\syncsaw)
.set(
	\amp, -25.dbamp,
	\atk, 0.001,
	\sus, 0.1,
	\rel, 0.1,
	\sync, 1.5
);
)

/////////////////////////////////////////
// modulate which
(
Pdef(\res_which, {
	var node = Ndef(\res_synth);
	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\which],
		\which, Pseq([0, 1, 2], inf),
		\dur, 2
	)
})
)

/////////////////////////////////////////
// modulate focus
(
Pdef(\res_focus, {
	var node = Ndef(\res_synth);
	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\focus],
		\focus, Pseg(Pseq([0.2, 0.5, 0.2], inf), Pseq([4,4,4], inf), \sin, inf),
		\dur, 0.125
	)
})
)

/////////////////////////////////////////
// main player
Ndef(\res_synth).play(vol:1);
(
Pdef(\res_player, {

	var node = Ndef(\res_synth);
	if (node.isMonitoring.not){
		node.play;
	};

	Ppar([

		Pdef(\res_which),

		Pdef(\res_focus),

		Pbind(
			\type, \set,
			\id, Pfunc({[
				Ndef(\res).nodeID,
				Ndef(\varsaw).nodeID,
				Ndef(\syncsaw).nodeID
			]}),
			\args, #[\freq, \trig],
			\degree, Pseq([
				Pseq([2,2,4,3], 1),
				Pseq([2,2,0,-2], 1)
			], inf),
			\scale, Scale.aeolian.tuning_(\just),
			\octave, [6, 5, 4],
			\trig, 1,
			\dur, 0.25,//Prand([0.25, 0.125, Rest(0.5)], inf)
		)
	])
})
)
Pdef(\res_player).play;
Pdef(\res_player).stop;


App.saveWorkspace("beat", rec:true);
s.stopRecording;