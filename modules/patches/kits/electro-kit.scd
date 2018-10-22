/////////////////////////////////////////
// s1
~p[\s1].clear;
~p[\s1].mold;
(~p[\s1][0] = {

	var trig = \trig.tr;
	var freq = 180;
	var index = Env([16,16,0.1],[0,0.1],-4).kr(gate:trig);//XLine.kr(16, 0.1, 0.1);
	var sig = { PMOsc.ar(freq, freq * 2.1, index, mul:2) }.dup(2).sum.tanh;
	var env = Env.perc(releaseTime:1).kr(gate:trig) * LFPulse.kr(20).range(0,1);
	sig = Pan2.ar(sig, \pan.kr(0)) * env * \amp.kr(0.1);
	sig
});

(
var node = ~p[\s1];
Pbindef(\s1,
	\type, \set,
	\id, Pfunc({ node.nodeID }),
	\args, #[\trig],
	\trig, 1,
	\dur, 0.25,
	\seq, Pseq([1,0,0,0,  0,0,0,0,  1,0,0,0,  0,0,1,0], inf),
	\foo, Pfunc({arg evt; if (evt[\seq].coin) {1} {Rest()}})
).quant_(4.0);
)

Pbindef(\s1).play;
~p[\s1].play;

Pbindef(\s1).stop;
~p[\s1].stop;

/////////////////////////////////////////
// s2
~p[\s2].clear;
~p[\s2].mold;
(~p[\s2][0] = {

	var trig = \trig.tr;
	var sig = WhiteNoise.ar();
	var env = Env.perc(releaseTime:0.1).kr(gate:trig);
	sig = { RLPF.ar(sig, [220, 440, 880, 1760], 0.05) }.dup(1).sum;

	sig = sig * env * \amp.kr(0.1);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig
});

(
var node = ~p[\s2];
Pbindef(\s2,
	\type, \set,
	\id, Pfunc({ node.nodeID }),
	\args, #[\trig],
	\trig, 1,
	\dur, 0.125,
	\seq, Pseq([1,0,0,0,  0,0,0,0,  1,0,0,0,  0,0,1,0], inf),
	\foo, Pfunc({arg evt; if (evt[\seq].coin) {1} {Rest()}})
).quant_(4.0)
)

Pbindef(\s2).play;
~p[\s2].play;

Pbindef(\s2).stop;
~p[\s2].stop;


/////////////////////////////////////////
// patterns
(
var seqs = [
	\s1 ->      [1,0,0,0,  0,0,0,0,  1,0,0,1,  0,0,1,0],
	\s2 ->      [0,0,1,0,  0,0,1,1,  0,0,0,0,  0,1,0,0]
].do({arg val;
	Pbindef(val.key, \seq, Pseq(val.value, inf))
});
)

/////////////////////////////////////////
// mix
(
// clear
var foo = {~p[\electro_mix].clear}.();
var keys = [\s1, \s2];
var pdefs;

keys.do({arg key, i;
	var node = ~p[key];
	~p[\electro_mix][i] = \mix -> {node.ar;};
});
);

/////////////////////////////////////////
// ppar
(
var keys = [\s1, \s2];
pdefs = keys.collect({arg key;
	Pdef(key)
});

Pdef(\electro_scene1,
	Ppar(pdefs, inf)
).quant_(4.0);
)

/////////////////////////////////////////
// play
Pdef(\electro_scene1).play;
~p[\electro_mix].play(vol:1);

~p[\electro_mix].set(\mix0, 1, \mix1, 1)

Pdef(\electro_scene1).stop;
~p[\electro_mix].stop;

