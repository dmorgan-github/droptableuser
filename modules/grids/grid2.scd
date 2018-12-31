//~p[\fx1].clear;
~fx1.play(vol:2);
//~p[\fx1].stop;

~fx1[0] = ~dfm11;


Scale.hexSus.degrees

(
~fx1[100] = \filter -> {arg in;

	var dur = 1.5;
	var fbNode = FbNode(2, 8, 4);

	var taps = 16;
	var div = 0.25;
	var num = 0;
	var del = (0..(taps-1)).collect({arg i;

		var sig;
		var freq;

		num = num + div;
		//if (0.5.coin) {
		freq = [3,5].choose;
		sig = FreqShift.ar(fbNode.delay(num), [freq, freq.neg]);
		//sig = fbNode.delay(num) * [0.0001,1].choose;
		//sig = RLPF.ar(sig, rrand(1200,2200), rrand(0.3, 0.7));
		sig;
		//} {
		//	Squiz.ar(fbNode.delay(num), [2,3,4].choose, [10,20,30,40].choose);
		//};
	});

	fbNode.write(in);

	Splay.ar(del);
};
)




(
// y axis
var node = ~p[\pluck2];
Pdef(\pluck2, {
	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \freq],
		\trig, 1,
		\seq, Pdefn(\seq),
		\foo, Pif(Pfunc({arg evt; (evt[\seq] == 2) || (evt[\seq] == 3)}), Pkey(\seq), Rest()),
		\degree, Pkey(\foo),
		\octave, 6,
		\mtranspose, Pdefn(\mtranspose),
		\scale, Pdefn(\scale),
		\dur, Pdefn(\dur)
	)
})
)

(
// y axis
var node = ~p[\sine2];
Pdef(\yaxis, {
	node.play;
	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \freq],
		\trig, 1,
		\numrows, Pdefn(\numrows),
		\count, Pstutter(Pkey(\numrows), Pseries(0, 1, inf)),
		\row, Pfunc({arg evt, i; evt[\numrows] - 1 - (evt[\count] % evt[\numrows]) }),
		\col, Pdefn(\seq),
		\foo, Pif(Pfunc({arg evt;
			if (evt[\row] == evt[\col]) {
				[evt[\row], evt[\col]].debug("y");
			};
			evt[\row] == evt[\col];
		}), Pkey(\col), Rest()),
		\degree, Pkey(\foo),
		\octave, 7,
		\mtranspose, Pdefn(\mtranspose),
		\scale, Pdefn(\scale),
		\dur, Pdefn(\dur)
	)
});
)

(
// x axis
var node = ~p[\sine3];
Pdef(\xaxis, {
	node.play;
	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \freq],
		\trig, 1,
		\numcols, Pdefn(\numcols),
		\numrows, Pdefn(\numrows),
		\count, Pseries(0, 1, inf),
		\col, Pstutter(Pkey(\numcols), Pdefn(\seq)),
		\row, Pfunc({arg evt, i; evt[\numrows] - 1 - (evt[\count] % evt[\numrows]) }),
		\foo, Pif(Pfunc({arg evt;
			//[evt[\row], evt[\col]].debug("x");
			evt[\row] == evt[\col] }), Pkey(\col), Rest()),
		\degree, Pkey(\foo),
		\octave, 6,
		\mtranspose, Pdefn(\mtranspose),
		\scale, Pdefn(\scale),
		\dur, Pdefn(\dur),
		\amp, 0.1
	)
});
)

(
var node = ~p[\varsaw1];
Pdef(\grid, {
	node.play;
	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \freq],
		\trig, 1,
		\degree, Pdefn(\seq),
		\octave, Pbjorklund(5, 8, inf).collect({arg val; if (val == 0) {3} {4}}) + 1,
		\foo, Pif(Pfunc({ 1.coin }), 1, Rest()),
		\mtranspose, Pdefn(\mtranspose),
		\scale, Pdefn(\scale),
		\dur, Pdefn(\dur)
	)}
)
)
~p[\varsaw1].play
Pdef(\grid).play;
Pdef(\grid).stop;


TempoClock.default.tempo_(1);

Pdefn(\seq, Pseq(Array.fill(16, { if (0.5.coin) { (0..7).choose } {\} }), inf));
Pdefn(\seqlist, Pfunc({ Pdefn(\seq).pattern.list }));
Pdefn(\numcols, Pfunc({ Pdefn(\seq).pattern.list.size }));
Pdefn(\numrows, Pfunc({ Pdefn(\seq).pattern.list.size }));
Pdefn(\mtranspose, -2);
Pdefn(\dur, 0.25);
Pdefn(\scale, Scale.dorian)

Pdefn(\seq).pattern.list


Pdef(\main).clear;
(
Pdef(\main,
	Ppar([
		Pdef(\xaxis),
		Pdef(\yaxis),
		Pdef(\grid)
		//Pdef(\pluck2)
	])
).play;
)


Pdef(\main).play;
Pdef(\main).stop;


(400 + [(400 * 1), (400 * 1).neg]).clip(20, 800)