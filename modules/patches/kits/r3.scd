/////////////////////////////////////////
// instrs
(
SynthDef(\oneshot, {
	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var sig = PlayBuf.ar(1, buf, rate, loop:0, doneAction:Done.freeSelf);
	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);
	//sig = Latch.ar(sig, Impulse.ar(LFNoise0.kr(5).lag(0.1).exprange(1000, 16000)));
	OffsetOut.ar(\out.kr(0), sig);
}).add;

SynthDef(\sine, {

	var freq = \freq.kr(432);
	var sig = SinOsc.ar(freq * [1, 1.01]);
	var env = Env.adsr.kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = Splay.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\varsaw, {

	var freq = \freq.kr(432);
	var sig = Saw.ar(freq * [1, 1.01]);
	var env = Env.adsr.kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = Splay.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	sig = RLPF.ar(sig, XLine.kr(2400, 880, 0.01), 0.5).tanh * 0.8;
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\bp, {

	var freq = \freq.kr(432);
	var noise = WhiteNoise.ar;
	var sig = { BPF.ar(noise, freq * [1, 2.01], 0.005) } !2;
	var env = Env.adsr(releaseTime:0.1).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = Splay.ar(sig, 0.5) * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp) * 30;
	//sig = RLPF.ar( (sig * 2).tanh, XLine.kr(2400, 880, 0.01), 0.2).tanh;
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\pulse, {

	var freq = \freq.kr(432);
	var sig = Pulse.ar(freq * [1, 1.01], Rand(0.3, 0.7));
	var env = Env.adsr.kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = Splay.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	sig = RLPF.ar(sig, XLine.kr(2400, 880, 0.2), 0.2).tanh;
	Out.ar(\out.kr(0), sig);

}).add;

)

//So there it is... Armed with a handful of conventional 'waveform' oscillators, a noise generator and a ring modulator

(~p[\n1][0] = {

	var rel = 0.5;
	var trig = \trig.tr;
	var fenv = { Env([rrand(2000, 6600), rrand(220, 440)], [0, rel], -4).kr(gate:trig) } !4;
	var sig = SinOsc.ar(fenv);
	var env = Env.perc(releaseTime:rel).kr(gate:trig);

	// feedback loop
	sig = Splay.ar(sig) + LocalIn.ar(2).reverse;
	sig = PitchShift.ar(sig, 0.5, 7.midiratio, 0.01, 0.01).tanh;
	//sig = FreqShift.ar(sig, 50).tanh;
	LocalOut.ar(sig);

	sig = sig * env * \amp.kr(-6.dbamp);
	Splay.ar(sig);
})

(~p[\n2][0] = {

	var rel = 0.1;
	var trig = \trig.tr;
	var sig = WhiteNoise.ar;
	var env = Env.perc(releaseTime:rel).kr(gate:trig);
	sig = BPF.ar(sig, 110, 0.5) * 4;

	// feedback loop
	sig = Splay.ar(sig) + LocalIn.ar(2).reverse;
	sig = sig ring2: SinOsc.ar(220);
	//sig = PitchShift.ar(sig, 0.5, 12.midiratio, 0.01, 0.01).tanh;
	//sig = FreqShift.ar(sig, 50).tanh;
	LocalOut.ar(sig.tanh);

	sig = sig * env * \amp.kr(-6.dbamp);
	Splay.ar(sig);
})

/////////////////////////////////////////
// shaker
(
var node = ~p[\shaker];
Pdef(\shaker, {arg seq;
	node.play;
	Pbind(\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig],
		\trig, seq,//Pdefn(\shaker_trig, Pseq([1,0,0,0], inf)),
		\dur, 0.25
	)
})
)

Pdef(\shaker).play;

/////////////////////////////////////////
// n1
(
var node = ~p[\n1];
Pdef(\n1, {arg seq;
	node.play;
	Pbind(\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig],
		\trig, seq,//Pdefn(\n1_trig, Pseq([1,0,0,0], inf)),
		\dur, 0.25
	)
})
)

(
var node = ~p[\waveloss];
Pdef(\waveloss, {arg seq;
	node.play;
	Pbind(\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\outof],
		\seq, seq,
		\outof, Pif(Pkey(\seq) > 0, 10, 40),
		\dur, 0.25
	)
})
)

/////////////////////////////////////////
// n2
(
var node = ~p[\n2];
Pdef(\n2, {arg seq;
	node.play;
	Pbind(\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig],
		\trig, seq, //Pdefn(\n2_trig, Pseq([1,0,0,0], inf)),
		\dur, 0.25,
		\amp, 1.dbamp
	)
})
)

(
var node = ~p[\sine];
Pdef(\sine, {arg seq;
	node.play;
	Pbind(
		\instrument, \sine,
		\seq, seq,
		\type, Pif(Pkey(\seq) > 0, \note, \rest),
		\dur, 0.25,
		\sustain, 0.01,
		\octave, 6,
		\mtranspose, Pdefn(\mtranspose, Pn(0, inf)),
		\amp, 0.dbamp,
		\out, Pfunc({node.bus.index}),
		\group, Pfunc({node.group})
	)
})
)

(
var node = ~p[\varsaw];
Pdef(\varsaw, {arg seq;
	node.play;
	Pbind(
		\instrument, \bp,
		\seq, seq,
		\type, Pif(Pkey(\seq) > 0, \note, \rest),
		\dur, 0.25,
		\sustain, 0.5,
		\octave, 5,
		\degree, 4,
		\mtranspose, Pdefn(\mtranspose, Pn(0, inf)),
		\amp, 0.dbamp,
		\out, Pfunc({node.bus.index}),
		\group, Pfunc({node.group})
	)
})
)


(
var node = ~p[\varsaw2];
Pdef(\varsaw2, {arg seq;
	node.play;
	Pbind(
		\instrument, \varsaw,
		\seq, seq,
		\type, Pif(Pkey(\seq) > 0, \note, \rest),
		\dur, 0.25,
		\sustain, 0.2,
		\octave, 4,
		\degree, 5,
		\mtranspose, Pdefn(\mtranspose, Pn(0, inf)),
		\amp, -6.dbamp,
		\out, Pfunc({node.bus.index}),
		\group, Pfunc({node.group})
	)
})
)

(
var node = ~p[\pulse];
Pdef(\pulse, {arg seq;
	node.play;
	Pbind(
		\instrument, \pulse,
		\seq, seq,
		\type, Pif(Pkey(\seq) > 0, \note, \rest),
		\dur, 0.25,
		\sustain, 3,
		\octave, 3,
		\degree, 2,
		\mtranspose, Pdefn(\mtranspose, Pn(0, inf)),
		\amp, -6.dbamp,
		\out, Pfunc({node.bus.index}),
		\group, Pfunc({node.group})
	)
})
)


/////////////////////////////////////////
// samples
~bufs_r3 = ~bufs_r3 ? ();
~bufs_r3[\tabla_hi] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc2/tabla/tabla-hi-tun.wav");

(
~bufs_r3.keysValuesDo({arg k, v;
	var node = ~p[k];
	var buf = ~bufs_r3[k];
	Pdef(k, {arg seq;
		node.play;
		Pbind(\instrument, \oneshot,
			\buf, Pfunc({buf}),
			\seq, seq, //Pdefn((k ++ '_trig').asSymbol, Pseq([1], inf)),
			\type, Pif(Pkey(\seq) > 0, \note, \rest),
			\dur, 0.25,
			\amp, 0.dbamp,
			\out, Pfunc({node.bus.index}),
			\group, Pfunc({node.group})
		)
	})
});
)


/////////////////////////////////////////
// patterns
(
var foo = {
	// 376323
	thisThread.randSeed_(1000000.rand.debug("rand seed"));
	//thisThread.randSeed_(62491);
}.();

var pdefs = [
	\shaker -> [1,0,1,0],
	//\tabla_hi -> Array.fill(16, {if (0.4.coin) {1}{0}}),
	//\n1 -> [1,0,0, 1,0,0, 1,0,0, 1,0,0, 1,0,0,0],
	//\n2 -> [1,0,0,0,0],
	//\sine -> [1,0,0,1,0],
	//\varsaw -> [1,0,0,1,0,0,0],
	//\varsaw2 -> [1,0,0,0,1,0,0,0,0],
	//\pulse -> [0,1,0,0,0,0,0,0,0,0,0,0],
	//\waveloss -> [0,0,1,0,0,0,1,0,0,1,0,0,0]
].collect({arg assoc;
	Pdef(assoc.key) <> (seq: Pseq(assoc.value, inf));
});

Pdef(\r3, {
	Ppar(pdefs, inf)
}).quant_(4.0);
)

Pdefn(\mtranspose, Pstutter(64, Pseq([0, -2, 1, -5], inf)).trace)

Pdef(\r3).clear;
Pdef(\r3).play;
Pdef(\r3).stop;