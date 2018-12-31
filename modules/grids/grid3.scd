~p.push

(
var vals = (0..5).collect({arg i;
	Env([0.01,1],[6],-4).at(i)
});
vals.postln;

)

~fx1.clear;
~fx1.play(vol:0.5);
~fx1.stop(fadeTime:10)
~fx1[0] = ~varsaw1;
~fx1[1] = nil~pluck2;
~fx1[2] = nil~varsaw1;

(
~fx1[100] = \filter -> {arg in;

	var dur = 1.5;
	var fbNode = FbNode(2, 8, 4);

	var taps = 24;
	var div = 0.25;
	var num = 0;
	var del = [ 0.01, 0.50070462079322, 0.75264077349685, 0.8819891071981, 0.94839875603867, 0.98249460662236 ].collect({arg i;

		var sig;
		var freq;
		num = i;//num + [div, div/2].choose;
		sig = PitchShift.ar(fbNode.delay(num), 0.2, ( [2,7].choose + [0, 12].choose).midiratio, 0.01, 0.01);
		Pan2.ar(sig, [-1,1,-0.5, 0.5].choose );
	});

	fbNode.write(in + (Splay.ar(del) * 0.7));

	Splay.ar(del.sum);
};
)


~fx2.play(vol:1);
~fx2.stop(fadeTime:10);
~fx2[0] = ~sine1;
~fx2[1] = ~pluck2;
~fx2[2] = ~varsaw1;

(
~fx2[100] = \filter -> {arg in;

	var dur = 1.5;
	var fbNode = FbNode(2, 8, 4);

	var taps = 16;
	var div = 0.25;
	var num = 0;
	var in_ = in * 1;
	var del = (0..(taps-1)).collect({arg i;

		var sig;
		var freq;

		num = num + div;// [div, div/2, div * 2].choose;
		//if (0.5.coin) {
		//sig = PitchShift.ar(fbNode.delay(num), 0.2, [0, 7, 12, 14].midiratio.choose, 0.01, 0.01);
		sig = fbNode.delay(num);// * [0.01,1].choose;
		//sig = RLPF.ar(sig, rrand(1200,2200), rrand(0.3, 0.7));
		Pan2.ar(sig, [-1,1,-0.5, 0.5].choose ) * [0.0001, 1].choose;
		//} {
		//	Squiz.ar(fbNode.delay(num), [2,3,4].choose, [10,20,30,40].choose);
		//};
	});

	fbNode.write(in_);

	Splay.ar(del.sum);
};
)

/////////////////////////////////////////
// y axis degrees
(
// y axis degrees
Pdef(\yaxis_degrees, {arg node;
	node.play;
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
Pdef(\yaxis_degrees).play;

/////////////////////////////////////////
// y axis
(
// y axis
Pdef(\yaxis, {arg node;
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

/////////////////////////////////////////
// x axis
(
// x axis
Pdef(\xaxis, {arg node;
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
		\dur, 0.125,//Pdefn(\dur),
		\amp, 0.1
	)
});
)
Pdef(\xaxis).play;

/////////////////////////////////////////
// grid
(
Pdef(\grid, {arg node;
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

/////////////////////////////////////////
// play

Pdef(\gridplay, Pdef(\grid) <> (node:~varsaw1));
Pdef(\xaxisplay, Pdef(\xaxis) <> (node:~sine1));
Pdef(\yaxisplay, Pdef(\yaxis) <> (node:~varsaw1));
Pdef(\yaxis_degreesplay, Pdef(\yaxis_degrees) <> (node:~varsaw1))

Pdef(\gridplay).play;
Pdef(\gridplay).stop;

Pdef(\xaxisplay).play;
Pdef(\yaxisplay).play;
Pdef(\yaxis_degreesplay).play;


TempoClock.default.tempo_(1);
Scale.hexSus
[ 4, 7, 6, 2, , , 5, , , 5, 5, 3, , 3, ,  ]

Pdefn(\seq, Pseq(Array.fill(32, { if (0.3.coin) { (0..7).choose } {\} }), inf));
Pdefn(\seqlist, Pfunc({ Pdefn(\seq).pattern.list }));
Pdefn(\numcols, Pfunc({ Pdefn(\seq).pattern.list.size }));
Pdefn(\numrows, Pfunc({ Pdefn(\seq).pattern.list.size }));
Pdefn(\mtranspose, 0);
Pdefn(\dur, 0.25);
Pdefn(\scale, Scale.hexSus)


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



