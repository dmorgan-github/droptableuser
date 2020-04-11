(
Fdef(\varsaw, {
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

	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0));
	var detune = \dtune.kr(4.4);
	var sig = {
		var width = \width.kr(0.5);
		var sig = {
			var dt = LFNoise2.kr(\dtunedepth.kr(5)).range(detune.neg, detune);
			VarSaw.ar(freq + dt, width:width);
		}.dup(2);
		sig;
	};

	var noise = {
		PinkNoise.ar * \noise.kr(0.0);
	};

	var sub = {
		SinOsc.ar(freq * 0.5) * \sub.kr(0.0);
	};

	sig = sig.() + noise.() + sub.();

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);

	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));

	sig;
});
Fdef(\square, {
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

	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0));
	var detune = \dtune.kr(4.4);
	var sig = {
		var width = \width.kr(0.5);
		var sig = {
			var dt = LFNoise2.kr(\dtunedepth.kr(5)).range(detune.neg, detune);
			Pulse.ar(freq + dt, width:width);
		}.dup(2);
		sig;
	};

	var noise = {
		PinkNoise.ar * \noise.kr(0.0);
	};

	var sub = {
		SinOsc.ar(freq * 0.5) * \sub.kr(0.0);
	};

	sig = sig.() + noise.() + sub.();

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);

	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));

	sig;
});
)


Ndef(\synth1)[0] = Fdef(\varsaw);
Ndef(\synth2)[0] = Fdef(\square);

Ndef(\synth1).stop;
Ndef(\synth2).stop;

Ndef(\synth_mix)[0] = \mix -> { Ndef(\synth1).ar};
Ndef(\synth_mix)[1] = \mix -> { WaveLoss.ar(Ndef(\synth2).ar) };

(Ndef(\synth_mix).filter(10, {arg in;

	var sig = in;
	var trig = \trig.tr;

	sig = sig.blend(DFM1.ar(sig, Env.perc(releaseTime:0.1).kr(gate:trig).range(440, 4200), 0.7), 0.4);
	//sig = sig.blend(RLPF.ar(sig, Env.perc(releaseTime:0.1).kr(gate:trig).range(440, 4200), 0.2), 0.4);

	sig = sig.blend(FbC({arg fb;
		fb.reverse * 0.4 + sig
	}, TempoClock.default.beatDur * [5/8, 3/4]), 0.3);

	sig = sig.blend(JPverb.ar(HPF.ar(sig, 110), 3, 0, 3), 0.3);

	//sig = sig.blend(Squiz.ar(sig, 1.5, SinOsc.kr(1/4).range(1, 10)), 0.1);

	sig;
}));


(
Pdef(\lead, {

	var synth1 = Ndef(\synth1);
	var synth2 = Ndef(\synth2);
	var mix = Ndef(\synth_mix);

	if (mix.isMonitoring.not) {
		\lead.debug("monitoring");
		synth1.stop;
		synth2.stop;
		mix.play;
	};

	Ppar([

		Pbind(
			\type, \set,
			\id, Pfunc({mix.nodeID}),
			\args, #[\mix1],
			\mix1, 0.55
		),

		Pbind(
			\type, \set,
			\id, Pfunc({synth1.nodeID}),
			\args, #[\sus, \rel, \dec, \width, \amp],
			\width, Pseq([0.8, 0.1], inf),
			\atk, 0.1,
			\sus, 0.2,
			\dec, 0.3,
			\rel, 1,
			\dur, 1,
			\amp, -12.dbamp
		),

		Pbind(
			\type, \set,
			\id, Pfunc({synth2.nodeID}),
			\args, #[\sus, \rel, \dec, \amp],
			\sus, Pwhite(0.1, 1.0),
			\dec, 0.1,
			\rel, 1,
			\amp, -20.dbamp,
			\dur, 0.25
		),

		Pspawner({arg ps;

			var dur = Pseq(0.25!6 ++ [0.5, 2], inf).asStream;
			var degree = Pshuf([0,1,2,3,4,5,6,7], inf).asStream;

			inf.do({

				var s1 = (type:\set,
					id:{synth1.nodeID},
					args:#[\freq, \trig],
					degree:degree.next,
					scale:Scale.ritusen,
					trig:1);

				var s2 = (type:\set,
					id:{synth2.nodeID},
					args:#[\freq, \trig],
					degree:degree.next,
					scale:Scale.ritusen,
					octave: 5,
					trig:1);

				var s3 = (type:\set, id:{mix.nodeID}, args:#[\trig], trig:1);

				ps.par(Pn(s1, 1));
				ps.par(Pn(s2, 1));
				ps.par(Pn(s3, 1));
				ps.wait(dur.next * 1/2);
			})
		})
	])
})
)

Pdef(\lead).play;
Pdef(\lead).stop;

App.saveWorkspace("wip6", rec:true);
Pdef(\lead).play;

s.stopRecording;

(
Fdef(\noteOn, {arg note, vel;
	var freq = note.midicps;
	Ndef(\synth1).set(\trig, 1, \freq, freq);
	Ndef(\synth2).set(\trig, 1, \freq, freq);
});
Fdef(\noteOff, {arg note, vel;
	//[note, vel].debug(\noteOff);
})
)

TempoClock.default.tempo