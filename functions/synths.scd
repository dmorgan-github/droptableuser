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

/*
kik
{arg freq, rq = 0.5, high = 85, low = 40, pitch = 3, phase = 0.85;

var env = EnvGen.kr(Env.perc(0.001, 0.05) );
var osc1 = FSinOsc.ar(  XLine.kr(high, low, 0.1),  phase * pi  );
var osc2 = PMOsc.ar(osc1, 65, XLine.kr( pitch, 0.01, 0.1 ) );

var sig = Mix([  osc1, osc2]);
sig = sig + RLPF.ar(sig, 2000, rq);
sig * env;
};

snare
{arg freq = 349.228, tightness = 3000, strike = 3, strikelevel = 0.3, snare = 0.55, decay = 0.2;

var env = EnvGen.kr(Env([0,1,0], [0.001, decay], -4));

var osc1 = FSinOsc.ar(freq * 0.53, 0.5, XLine.kr( 1, 0.01, 0.2 ) );
var osc2 = PMOsc.ar( osc1, 184, XLine.kr( strike, 0.01, 0.1 )  )  * strikelevel;
var noise = WhiteNoise.ar * snare;
var sig = Mix.ar([osc1, osc2, noise]);

sig = sig + Resonz.ar(sig, tightness, 1, 1);
sig = sig + LPF.ar(sig, 150);
// TODO: tune this...
//sig = MidEQ.ar(sig, MouseX.kr(200, 6000).poll, 0.5, MouseY.kr(-12, 12).poll );
sig * env;
};

hat
// "http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/High-Hats-td4823993.html"
{arg freq=230, hpf=6500, release=0.15, fxb=0, fxv=0, bbcb=0, bbcv=0;

var pulse, sig, env, freqs;
freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 0.15));
sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
env = EnvGen.kr(Env.perc(0, release));
sig = sig*env;
sig;
};
*/

SynthDef.new(\piano, {arg freq = 440, amp = 0.5, out = 0;
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