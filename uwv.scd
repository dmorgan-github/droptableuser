
S.uwv.synth = \subtractr;
S.uwv.play;

(
S.uwv.pset(
	\dur, Prand([1, 2, 4, 0.5], inf),
	\degree, Pslide([0, 4, -2, 2, -1, 1], inf),
	\legato, 0.5,
	\sine, 0.3,
	\sinefreqmul, 1,
	\tri, 0,
	\saw, 1,
	\sawfreqmul, 1,
	\octave, Pbjorklund(4, 9).linlin(0, 1, 4, 5),
	\sineskew, 0,
	\cutoff, Ndef(\uwv_cutoff),
	\amp, 0.3,
	\atk, 1,
	\rel, 2
)
)


Ndef(\uwv_sineskew, { \val.kr(1) });
Ndef(\uwv_cutoff, { \val.kr(100) });

(
Pdef(\uwv_play,

	Ppar([

		Pbind(
			\type, \set,
			\id, Pfunc({ Ndef(\uwv_cutoff).nodeID }),
			\args, #[\val],
			\val, Pseg([80, 500], [4, 5], -4, inf),
			\dur, 0.12
		)

	])
)
)

Pdef(\uwv_play).play;


b = Buffer.alloc(s, 1024, 1);
// or, for an arbitrary transfer function, create the data at 1/2 buffer size + 1
t = Signal.chebyFill(513, [1, 0, 0.6, 0.5, 0.3, 0, 0.3]);
b.sendCollection(t.asWavetableNoWrap);
t.plot

S.uwv.node.stop;

V.izhb.vst = 'Raum';
V.izhb.mix(0, S.uwv.node);
V.izhb.editor;
V.izhb.isMonitoring


(
Ndef(\shaper, {

	var in = V.izhb.ar;
	//var sig = JPverb.ar(in, 10, 0, 10);
	var sig = in;
	sig = Shaper.ar(b, sig);
	sig = LeakDC.ar(sig);
	sig = LPF.ar(sig, 940);
	sig;
})
)

Ndef(\shaper).play;





