(
var osc_freq = {arg freq_in = 432, num, detune_rate = 0.01;

	var key = 'osc' ++ num;
	var freq_mul = (key ++ '_freq_mul').asSymbol.kr(1);
	var detune = LFNoise2.kr(detune_rate).range(-5,5);

	var freq = Vibrato.ar(K2A.ar(freq_in * freq_mul + detune),
		(key ++ '_vrate').asSymbol.kr(6),
		(key ++ '_vdepth').asSymbol.kr(0.0),
		(key ++ '_vdelay').asSymbol.kr(0),
		(key ++ '_vonset').asSymbol.kr(0),
		(key ++ '_vrateVar').asSymbol.kr(0.04),
		(key ++ '_vdepthVar').asSymbol.kr(0.1)
	);

	freq;
};

var osc_env = {arg num;

	var oscEnv = Env([0,1,0.7,0.7,0],[0.001,0.05,0.8541,0.0949],\sin);
	var key = 'osc' ++ num;
	var env = (key ++ '_env').asSymbol.kr(oscEnv.asArray);
	var level = (key ++ '_level').asSymbol.kr(1);
	var ts = (key ++ '_ts').asSymbol.kr(1);
	var envgen = EnvGen.kr(env, gate:1, levelScale:level, timeScale:ts);

	envgen;
};

SynthDef(\poly2, {

	var freq_in = \freq.kr(432);

	var trig = \gate.kr(1);
	var susLevel = \susLevel.kr(0.7);
	var atk = \atk.kr(0.001);
	var decay = \decay.kr(0.05);
	var rel = \rel.kr(0.0949);
	var curve = \curve.kr(-4);
	var env = Env.adsr(atk, decay, susLevel, rel, curve:curve).kr(gate:trig, doneAction:Done.freeSelf);

	var osc0 = {
		var num = 0;
		var freq = osc_freq.(freq_in, num);
		var sig = SinOsc.ar(freq);
		var env = osc_env.(num);
		sig * env;
	};

	var osc1 = {
		var num = 1;
		var freq = osc_freq.(freq_in, num);
		var sig = VarSaw.ar(freq, 0, width:\osc1_width.kr(0.5));
		var env = osc_env.(num);
		sig * env;
	};

	var osc2 = {
		var num = 2;
		var freq = osc_freq.(freq_in, num);
		var sig = Saw.ar(freq);
		var env = osc_env.(num);
		sig * env;
	};

	var osc3 = {
		var num = 3;
		var freq = osc_freq.(freq_in, num);
		var index = Line.kr(13, 0, \osc3_dur.kr(1));
		var sig = PMOsc.ar(freq, freq * \osc3_mod.kr(1), index);
		var env = osc_env.(num);
		sig * env;
	};

	var sig = [osc0.(), osc1.(), osc2.(), osc3.()];
	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	sig = sig * AmpCompA.kr(freq_in) * env * \amp.kr(0.5);
	Out.ar(\out.kr(0), sig);

}).add;
)


~polynode = NodeProxy.audio(s, 2);

(
Pdef(\poly2, Pproto({
	var node = topEnvironment[\polynode];
	node.play;
	~group = node.group;
	~out = node.bus.index;

}, Pbind(
	\instrument, \poly2,
	\scale, Scale.mixolydian,
	\degree, Pwhite(0, 4, inf),
	\delta, 0.5,

	\sustain, 0.1,
	\rel, 0.1,
	\decay, 0.05,
	\susLevel, 0.5,

	\osc0_level, 1,
	\osc1_level, 0.3,
	\osc2_level, 0,
	\osc3_level, 0.1,

	\osc1_width, Pseg(Pseq([0.1, 0.9, 0.1], inf), 16, \lin, inf),
	\osc1_level, 0.3,
	\osc1_ts, 0.1,

	\osc2_level, 0,

	\osc3_mod, Pbjorklund(7, 11, inf).collect({arg val; if (val == 0) {12.11} {3.01}  }),
	\osc3_dur, 0.1,
	\osc3_ts, 1,
	//\osc3_level, 0.5,

	\osc0_freq_mul, 1,
	\osc1_freq_mul, 0.5,
	\osc3_freq_mul, Pbjorklund(3, 5, inf).collect({arg val; if (val == 0) {2} {4}  }),

	\spread, 0.5
)))
)

Pdef(\poly2).play