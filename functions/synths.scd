(
~fx = {arg id, func;

	var synthId = id.asSymbol;
	SynthDef(synthId, {arg out, wet = 0, gate = 1;

		var sig = In.ar(out, 2);
		var env = EnvGate.new(gate: gate);
		var fx = SynthDef.wrap(func, nil, sig);
		var fade = XFade2.ar(sig, fx, wet);
		XOut.ar(out, env, fade);
		//ReplaceOut.ar(out, in);
	}).add;
};

SynthDef(\piano, {arg freq = 440, amp = 0.5, out = 0;
	var sig = MdaPiano.ar(freq);
	var env = EnvGen.kr(Env.linen, doneAction:2);
	sig = sig * env * amp;
	OffsetOut.ar(out, Splay.ar(sig));
}).add;

SynthDef(\smplr_m, {arg startPos = 0, buf, rate = 1, loop = 1,
	atk = 0.005, rel = 0.005, curve = 0, dur = 0.1,
	amp = 0.5, out = 0, pan = 0, t_trig = 1;

	var env= Env([0,1,1,0], [atk, dur-atk-rel, rel], curve).ar(doneAction:2);
	var sig = PlayBufCF.ar(numChannels: 1, bufnum: buf, rate: BufRateScale.ir(buf) * rate, trigger: t_trig, startPos: startPos, loop: loop);
	sig = sig * env * amp;
	OffsetOut.ar(out, Pan2.ar(sig, pan));

}).add;

SynthDef(\smplr_s, {arg startPos = 0, buf, rate = 1, loop = 1,
	atk = 0.005, rel = 0.005, curve = 0, dur = 0.1,
	amp = 0.5, out = 0, pan = 0, t_trig = 1;

	var env= Env([0,1,1,0], [atk, dur-atk-rel, rel], curve).ar(doneAction:2);
	var sig = PlayBufCF.ar(numChannels: 2, bufnum: buf, rate: BufRateScale.ir(buf) * rate, trigger: t_trig, startPos: startPos, loop: loop);
	sig = sig * env * amp;
	OffsetOut.ar(out, Pan2.ar(sig, pan));

}).add;

)