b = Buffer.alloc(s, 512, 1, { |buf| buf.chebyMsg([1,0,0.7,0.5,0,0.3])});

(
SynthDef(\sinoscfb, {

	var freq = Vibrato.kr(\freq.kr(432), 6, 0.007);
	var sig = [
		{
			var myfreq = freq * [1, 1.001];
			var sig = SinOscFB.ar(myfreq, feedback: SinOsc.kr(7).range(0.5,0.7));
			sig = SoftClipAmp8.ar(FreqShift.ar(sig, [-3,3]), 2) + sig;
			sig * AmpCompA.kr(myfreq) * 0.6;
		},
		{
			var trig = Impulse.kr([4, 4.4]);
			var myfreq = freq * 7.midiratio * 12.midiratio * [1.005, 1];
			var sig = SinOsc.ar(myfreq);
			sig = Shaper.ar(b, sig);
			sig = RLPF.ar(sig, 3300, 0.5);
			sig = sig * Env.linen(0.001, 0.1, 0.1).kr(gate:trig);
			sig * AmpCompA.kr(myfreq) * 0.1;
		},
		{
			var myfreq = freq * -12.midiratio * [1.01, 1];
			var sig = SinOsc.ar(myfreq);
			sig * AmpCompA.kr(myfreq) * 0.5;
		},
		{
			var myfreq = freq * 12.midiratio * [1, 1.01];
			var sig = VarSaw.ar(myfreq);
			sig = JPverb.ar(sig, 10, 0, 5, modDepth:0.5) + sig;
			sig * AmpCompA.kr(myfreq) * 0.18;
		}
	];

	var env = Env.linen(attackTime:1, sustainTime:2, releaseTime:2).kr(gate:1, doneAction:Done.freeSelf);
	//sig = Decimator.ar(sig, 44100/5, 8);
	//sig = BLowPass4.ar(sig, 2400, 0.8);
	// need eq
	sig = Splay.ar(sig, 0.5) * env * AmpCompA.kr(freq) * \amp.kr(0.1);
	Out.ar(\out.kr(0), sig);

}).add;
)


/////////////////////////////////////////
// pbinds

Pbindef(\s1).clear;
(
var k = \s1;
var node = Ndef(k);
Pbindef(k, \instrument, \sinoscfb,
	//\node, Pfunc({node}),
	//\amp, 0.5,
	\dur, 1,
	\scale, Scale.dorian,
	\octave, [4,5],
	\amp, 0.2
	//\group, Pfunc({arg evt; evt[\node].group}),
	//\out, Pfunc({arg evt; evt[\node].bus.index}),
	//\seq, Pseq([1,0,0,0,  0,0,0,0,  1,0,0,0,  0,0,1,0], inf),
	//\foo, Pfunc({arg evt; if (evt[\seq].coin) {1} {Rest()}})
)
)


[1,2,3].rotate(1)

TempoClock.default.tempo_(30/60)
/////////////////////////////////////////
// scene
(
var seq = [
	[ 7, 5, -1 ],
	Rest(1),
	[ 8, 6, 3 ],
	Rest(1),
	[ 8, 5, 3, -1 ],
	Rest(1),
	Rest(1),
	Rest(1),
	[ 7, -1 ],
	Rest(1),
	[ 5, 1 ],
	Rest(1),
	[ 8, 4, -1 ],
	Rest(1),
	[ 7 ],
	Rest(1)
];

Pdef(\s1_a,
	Pbind(\degree, Pseq(seq[0..7], 1)) <> Pbindef(\s1)
);

Pdef(\s1_b,
	Pbind(\degree, Pseq(seq[8..15], 1)) <> Pbindef(\s1);
);
//Pbindef(\s1_a, \degree, Pseq(seq[0..7], 1), \scale, Scale.dorian, \octave, [4,5], \amp, 0.2) <> Pbindef(\s1);
//Pbindef(\s1_b, \degree, Pseq(seq[8..15], 1), \scale, Scale.dorian, \octave, [4,5], \amp, 0.2) <> Pbindef(\s1);
)

(
Pseq([
	Pdef(\s1_a),
	Pdef(\s1_b),
], 2).play
)


