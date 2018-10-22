(
SynthDef(\sine1, {

	var freq = Vibrato.kr(\freq.kr(432), 6, 0.01);
	var env = Env.adsr(releaseTime:1, curve:-4).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	var sig = SinOscFB.ar(freq * [1, 1.01], \fb.kr(0.075));
	sig = Splay.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
	//sig = Latch.ar(sig, Impulse.ar(LFNoise0.kr(5).lag(0.1).exprange(1000, 16000)));
	Out.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////////////
// sends
Ndef(\send1).play;
(
Ndef(\send1).filter(2, {arg in;
	var sig = FbC({arg fb; fb.abs * 0.6 + in}, [3/8, 4/8] * 0.91.reciprocal) * 0.5 + in;
	sig = sig + FbC({arg fb; fb * 0.6 + in}, [3/8, 4/8] * 0.91.reciprocal + 2) * 0.5 + in;
	//sig = Latch.ar(sig, Impulse.ar(LFNoise0.kr(5).lag(0.1).exprange(1000, 16000))) * 0.2 + sig;
	sig = JPverb.ar(sig, 5, 0, 2, modDepth:0.5) * 0.3 + sig;
	sig = BLowShelf.ar(sig, 200, 1, -12);
	sig;
})
)

/////////////////////////////////////////
// fig1
(
Pdef(\fig1, {var out = 0, vol = 1;
	var node = Ndef(\send1);
	node.play(out:out, vol:vol);
	Pbind(\instrument, \sine1,
		\freq, Pseq([ 'F3', 'G#3', 'C3', 'Eb3', 'G2', 'Bb3', 'D3', 'G#3', 'C4', 'F3', 'Eb4', 'G#2', 'G3', 'F2', 'Eb3', 'D2' ].namecps, inf),
		\dur, Pseq([   0.5,  0.5,   1,    0.5,   0.25, 0.25,  0.5,  0.25,  0.25, 0.5,  0.25,  0.25,  1,    0.5,  0.5,   1 ], inf),
		\legato, 0.5,
		\amp, -9.dbamp,
		\out, Pfunc({node.bus.index}),
		\group, Pfunc({node.group})
	);
})
)

Pdef(\bobo).clear;

// make this change in different phase to melody
Pdef(\bobo, Pbind(\instrument, \sine1, \octave, [3,4], \root, Pstutter(16, Pseq([5,3,8,10], inf)), \dur, 0.25, \legato, 0.4, \amp, 0.1))
.play
Pdef(\bobo).stop;

Pdef(\fig1).play
Pdef(\fig1).stop;
Ndef(\send1).stop(fadeTime:10);
Ndef(\send1).play(fadeTime:8);

TempoClock.default.tempo_(55/60);

App.saveWorkspace("ws19", rec:true);
s.stopRecording