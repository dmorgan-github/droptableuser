(
// adapted from Eli Fieldsteel
SynthDef(\grainr, {

	var gate = \gate.kr(1);
	var buf = \buf.kr(0);
	var grainenv = \grainenv.kr(-1);
	var rate = \rate.kr(1);

	var aeg = {
		var atk = \atk.kr(0.01);
		var suslevel = \suslevel.kr(1);
		var rel = \rel.kr(1);
		var curve = \curve.kr(-4);
		Env.asr(atk, suslevel, rel, curve).ar(gate:gate, doneAction:Done.freeSelf)
	};

	var density = {
		var dens = \density.kr(20);
		var sync = \sync.kr(1);
		Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	};

	var graindur = {
		var durRand = \durRand.kr(1);
		var dur = \grainDur.kr(0.1);
		dur * LFNoise1.kr(100).exprange(1/durRand, durRand);
	};

	var pos = {
		var offset = \pos.kr(0);
		var speed = \posSpeed.kr(1);
		var posRand = \posRand.kr(0);
		var pos = Phasor.ar(0, speed * BufRateScale.ir(buf), 0, BufSamples.ir(buf)-1);
		pos = pos + LFNoise1.kr(100).bipolar(posRand * SampleRate.ir);
		pos = pos / BufSamples.ir(buf);
		pos + offset;
	};

	var pan = {
		var pan = \pan.kr(0);
		var panHz = \panHz.kr(0.1);
		var panRand = \panRand.kr(0);
		pan + LFNoise1.kr(panHz).bipolar(panRand);
	};

	var sig = GrainBuf.ar(
		2,
		density.(),
		graindur.(),
		buf,
		rate,
		pos.(),
		2,
		pan.(),
		grainenv
	);

	sig = (sig * \sat.kr(1)).softclip * aeg.() * \amp.kr(0.3) * \vel.kr(1);

	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));

	Out.ar(\out.kr(0), sig.softclip);

}, metadata: (
	specs: (

		\rate: ControlSpec(0, 1, \lin, 0, 0.01, "overlap"),
		\density: ControlSpec(0, 1, \lin, 0, 0.01, "overlap"),
		\sync: ControlSpec(0, 1, \lin, 1, 1, "overlap"),

		\durRand: ControlSpec(0, 1, \lin, 0, 1, "dur"),
		\grainDur: ControlSpec(0, 1, \lin, 0, 0.1, "dur"),

		\pos: ControlSpec(0, 1, \lin, 0, 0, "pos"),
		\posSpeed: ControlSpec(0, 1, \lin, 0, 1, "pos"),
		\posRand: ControlSpec(0, 1, \lin, 0, 0, "pos"),

		\pan: ControlSpec(0, 1, \lin, 0, 0, "pan"),
		\panHz: ControlSpec(0, 1, \lin, 0, 0.1, "pan"),
		\panRand: ControlSpec(0, 1, \lin, 0, 0, "pan"),

		atk: ControlSpec(0, 1, \lin, 0, 0.01, "aeg"),
		rel: ControlSpec(0, 8, \lin, 0, 0.29, "aeg"),
		suslevel: ControlSpec(0, 1, \lin, 0, 1, "aeg"),
		curve: ControlSpec(-8, 8, \lin, 0, -4, "aeg"),

		spread: ControlSpec(0, 1, \lin, 0, 1, "stereo"),
		center: ControlSpec(0, 1, \lin, 0, 0, "stereo"),
		vel: ControlSpec(0, 1, \lin, 0, 1, "vol"),
		amp: ControlSpec(0, 1, \lin, 0, -10.dbamp, "vol"),
		sat: ControlSpec(1, 100, \lin, 0, 1, "dist")
	)
)).add;
)


