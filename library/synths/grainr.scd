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
		var in_freq = \freq.ar(20).lag(\glis.kr(0));
		var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);
		// bend by semitones...
		var bend = \bend.ar(0).midiratio;
		var freqbend = in_freq * bend;
		var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));
		var sync = \sync.kr(1);
		Select.ar(sync, [Dust.ar(freq), Impulse.ar(freq)]);
	};

	var graindur = {
		var durRand = \durRand.kr(1);
		var dur = \grainDur.kr(0.1);
		dur * LFNoise1.kr(100).exprange(1/durRand, durRand);
	};

	var pos = {
		var offset =  \pos.ar(0);
		var speed = \posSpeed.kr(1);
		var posRand = \posRand.kr(0);
		var pos = Phasor.ar(0, speed * BufRateScale.ir(buf), 0, BufSamples.ir(buf));
		pos = pos + LFNoise1.kr(100).bipolar(posRand * SampleRate.ir);
		pos = pos / BufSamples.ir(buf);
		pos = pos + offset;
		pos
	};

	var pan = {
		var pan = \pan.kr(0);
		var panHz = \panHz.kr(0.1);
		var panRand = \panRand.kr(0);
		pan + LFNoise1.kr(panHz).bipolar(panRand);
	};

	var sig = GrainBuf.ar(
		numChannels:2,
		trigger:density.(),
		dur:graindur.(),
		sndbuf:buf,
		rate:rate,
		pos:pos.(),
		interp:2,
		pan:0,
		envbufnum:-1
	);

	sig = BLowPass.ar(
		BHiPass.ar(sig,
			\hpf.kr(20).clip(20, 18000),
			\hpfres.kr(0).linlin(0, 1, 1.4, 0.001)
		),
		\lpf.kr(20000).clip(20, 20000),
		\lpfres.kr(0).linlin(0, 1, 1.4, 0.001)
	);

	sig = sig * aeg.() * \amp.kr(0.3) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));

	Out.ar(\out.kr(0), sig);

}, metadata: (
	specs: (

		\rate: ControlSpec(-48.midicps, 24.midicps, \lin, 0, 1, "pitch"),
		\freq: ControlSpec(0.1, 20000, \lin, 0, 20, "overlap"),
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
		amp: ControlSpec(0, 1, \lin, 0, -10.dbamp, "vol")
	)
)).add;
)
