~p[\fx1].clear;
~p[\fx1].play(vol:1);
~p[\fx1].stop;

~p[\fx1][0] = ~p[\pluck2];

(
~p[\fx1][100] = \filter -> {arg in;

	var dur = 1.5;
	var fbNode = FbNode(2, 8, 4);

	var div = 0.25;
	var num = 0;
	var del = (0..3).collect({arg i;
		num = num + div;
		num.postln;
		if (0.5.coin) {
			fbNode.delay(num);
		} {
			Squiz.ar(fbNode.delay(num), [2,3,4].choose, [10,20,30,40].choose);
		};
	});

	fbNode.write(in + (Splay.ar(del) * 0.1));

	//del = NHHall.ar(del, 5, modDepth:0.9) * 0.5 + del;
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
var node = ~p[\sine1];
Pdef(\yaxis,
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
			//[evt[\row], evt[\col]].debug("y");
			evt[\row] == evt[\col]
		}), Pkey(\col), Rest()),
		\degree, Pkey(\foo),
		\octave, 6,
		\mtranspose, Pdefn(\mtranspose),
		\scale, Pdefn(\scale),
		\dur, Pdefn(\dur)
	)
);
)

(
// x axis
var node = ~p[\varsaw1];
Pdef(\xaxis,
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
		\octave, 7,
		\mtranspose, Pdefn(\mtranspose),
		\scale, Pdefn(\scale),
		\dur, Pdefn(\dur),
		\amp, 0.1
	)
);
)

(

var node = ~p[\pulse1];
Pdef(\grid,
	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \freq],
		\trig, 1,
		\degree, Pdefn(\seq),
		\octave, Pbjorklund(5, 8, inf).collect({arg val; if (val == 0) {3} {4}}) + 0,
		\foo, Pif(Pfunc({ 1.coin }), 1, Rest()),
		\mtranspose, Pdefn(\mtranspose),
		\scale, Pdefn(\scale),
		\dur, Pdefn(\dur),
	)
)

)


TempoClock.default.tempo_(2);

Pdefn(\seq, Pseq([0,1,\,2,\,\,3,3,\,3,\,0,0,\,0,\], inf));
Pdefn(\seqlist, Pfunc({ Pdefn(\seq).pattern.list }))
Pdefn(\numcols, Pfunc({ Pdefn(\seq).pattern.list.size }));
Pdefn(\numrows, Pfunc({ Pdefn(\seq).pattern.list.size }));
Pdefn(\mtranspose, -2);
Pdefn(\dur, 0.25);
Pdefn(\scale, Scale.hexSus)

(
Pdef(\main,
	Ppar([
		Pdef(\xaxis),
		Pdef(\yaxis),
		Pdef(\grid),
		Pdef(\pluck2)
	])
);
)

Pdef(\main).play;


(400 + [(400 * 1), (400 * 1).neg]).clip(20, 800)