(
// adapted from Eli Fieldsteel
SynthDef(\grainr, {

	var gate = \gate.kr(1);
	var freq = \freq.ar(20);
	var buf = \buf.kr(0);
	var grainenv = \grainenv.kr(-1);
	var pitch = \pitch.kr(1);
	var replyid = \bufposreplyid.kr(-1);
	var graindur = \graindur.kr(0.1);

	var aeg = {
		var atk = \atk.kr(0.001);
		var suslevel = \suslevel.kr(1);
		var rel = \rel.kr(1);
		var curve = \curve.kr(-4);
		Env.asr(atk, suslevel, rel, curve).ar(doneAction:Done.freeSelf, gate:gate)
	};

	var density = {
		var sync = \sync.kr(1);
		Select.ar(sync, [Dust.ar(freq), Impulse.ar(freq)]);
	}.();

	var phase = {
		var speed = \pb.kr(1);
		var posrand = \posrand.kr(0);
		var start = \startPos.kr(0) * BufFrames.kr(buf);
		var end = \endPos.kr(1) * BufFrames.kr(buf);
		var phase = Phasor.ar(0, speed * BufRateScale.ir(buf), start, end);
		phase = phase + LFNoise1.kr(100).bipolar(posrand * SampleRate.ir);
		phase = phase/BufSamples.ir(buf);
		phase
	}.();

	var pan = {
		var pan = \pan.kr(0);
		var panHz = \panHz.kr(0.1);
		var panRand = \panRand.kr(0);
		pan + LFNoise1.kr(panHz).bipolar(panRand);
	}.();

	var sig = GrainBuf.ar(
		numChannels:2,
		trigger:density,
		dur:graindur,
		sndbuf:buf,
		rate:pitch,
		pos:phase,
		interp:2,
		pan:pan,
		envbufnum:grainenv
	);

	sig = sig * aeg.() * \amp.kr(0.3) * AmpCompA.kr(freq) * \vel.kr(1);
	SendReply.kr(Impulse.kr(60), '/bufpos', [0, phase * BufFrames.kr(buf)], replyid);
	Out.ar(\out.kr(0), sig);

}, metadata: (
	specs: (

		pitch: ControlSpec(-48.midicps, 24.midicps, \lin, 0, 1, "pitch"),
		freq: ControlSpec(0.0, 20000, \lin, 0, 20, "overlap"),
		sync: ControlSpec(0, 1, \lin, 1, 1, "overlap"),

		graindur: ControlSpec(0, 1, \lin, 0, 0.1, "dur"),

		pos: ControlSpec(0, 1, \lin, 0, 0, "playback"),
		pb: ControlSpec(-4.0, 4, \lin, 0, 1, "playback"),
		posrand: ControlSpec(0, 1, \lin, 0, 0, "playback"),
		startPos: ControlSpec(0, 1, \lin, 0, 0, "playback"),
		endPos: ControlSpec(0, 1, \lin, 0, 1, "playback"),

		\pan: ControlSpec(0, 1, \lin, 0, 0, "pan"),
		\panHz: ControlSpec(0, 1, \lin, 0, 0.1, "pan"),
		\panRand: ControlSpec(0, 1, \lin, 0, 0, "pan"),

		atk: ControlSpec(0, 1, \lin, 0, 0.01, "aeg"),
		rel: ControlSpec(0, 8, \lin, 0, 0.29, "aeg"),
		suslevel: ControlSpec(0, 1, \lin, 0, 1, "aeg"),
		curve: ControlSpec(-8, 8, \lin, 0, -4, "aeg"),

		vel: ControlSpec(0, 1, \lin, 0, 1, "vol"),
		amp: ControlSpec(0, 1, \lin, 0, -10.dbamp, "vol")
	)
)).add;
)