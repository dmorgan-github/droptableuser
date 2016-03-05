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

SynthDef.new(\piano, {arg freq = 440, amp = 0.5, out = 0;
	var sig = MdaPiano.ar(freq);
	var env = EnvGen.kr(Env.linen, doneAction:2);
	sig = sig * env * amp;
	OffsetOut.ar(out, Splay.ar(sig));
}).add;

SynthDef(\smplr_m, {arg startPos = 0, buf, rate = 1, loop = 1,
	atk = 0.001, rel = 1, curve = -4,
	t_trig = 1, gate = 1, amp = 0.5, out = 0, pan = 0;

	var env = EnvGen.kr(Env.asr(attackTime:atk, releaseTime: rel, curve: curve), gate: gate, doneAction:2);
	var sig = PlayBufCF.ar(numChannels: 1, bufnum: buf, rate: BufRateScale.ir(buf) * rate, trigger: t_trig, startPos: startPos, loop: loop);
	sig = sig * env * amp;
	OffsetOut.ar(out, Pan2.ar(sig, pan));

}).add;

SynthDef(\smplr_s, {arg startPos = 0, buf, rate = 1, loop = 1,
	atk = 0.01, rel = 1, curve = -4,
	t_trig = 1, gate = 1, amp = 0.5, out = 0, pan = 0;

	var env = EnvGen.kr(Env.asr(attackTime:atk, releaseTime: rel, curve: curve), gate: gate, doneAction:2);
	var sig = PlayBufCF.ar(numChannels: 2, bufnum: buf, rate: BufRateScale.ir(buf) * rate, trigger: t_trig, startPos: startPos, loop: loop);
	sig = sig * env * amp;
	OffsetOut.ar(out, Pan2.ar(sig, pan));

}).add;

)