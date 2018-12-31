~p.push

(
~ringz = {

	var trigs = (0..3).collect({arg val;
		var trig = ('trig' ++ val).asSymbol;
		Latch.ar(BrownNoise.ar, trig.tr);
	});

	var sig = trigs[0..2].collect({arg trig, i;
		var freq = ('f' ++ i).asSymbol.kr(261);
		Formlet.ar(trig, freq, 0.001, 0.7) * AmpCompA.kr(freq) * -12.dbamp;
	});

	sig = sig ++ [Formlet.ar(trigs[3], \f3.kr(261) * SinOsc.kr(15).range(9, 12).midiratio, 0.005, 2) * AmpCompA.kr(\f3.kr) * -16.dbamp];

	sig = Limiter.ar(sig.sum, -3.dbamp);

	sig = Pan2.ar(sig, LFNoise2.kr(1).range(-1.0, 1.0)) * \amp.kr(-6.dbamp);

	sig = NHHall.ar(sig, 5) * -6.dbamp + sig;

	sig;

};

~ringz[2] = \set -> Ppar(
	[
		'C4' -> [31, 24, 5],
		'Eb4' -> [25, 21, 13],
		'G4' -> [23, 43, 53],
		'Bb4' -> [26, 56, 61]
	].collect({arg assoc, i;
		var note = assoc.key.namecps;
		var divs = assoc.value;
		divs.collect({arg div;
			var trig = ('trig' ++ i).asSymbol;
			var freq = ('f' ++ i).asSymbol;
			Pbind(trig, 1, freq, note * Prand([-12, 0, -7, 7, 12].midiratio, inf), \dur, div * 0.25)
		});
	}).flatten
);

)

~ringz.play;
~ringz.stop;

(
~recbuf = {
	var in = \in.ar([0,0]);//~p[\pulse].ar;
	var buf = \buf.kr;
    var trig = \trig.tr;
	RecordBuf.ar(in, buf);
	0;
}
)

b = Buffer.alloc(s, 44100 * 10, 2);

~recbuf <<> ~ringz;
~recbuf.set(\buf, b);
b.numChannels

(

var buf = b;
var numFrames = buf.numFrames;
var dur = buf.duration;

~glitchbuf = {

	//var numChannels = 2;
	var buf = b;
	var rate = \rate.kr(1);
	var startPos = \pos.kr(0);
	//var loop = \loop.kr(0);
	//var dur = \dur.kr(1);
	var sig = PlayBufCF.ar(2, buf, rate, Impulse.kr(1), startPos, 0);
	//var env = Env([0,1,1,0], [0,dur,0.01], curve:\step).kr(doneAction:Done.freeSelf);
	//sig = sig * \amp.kr(-12.dbamp);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));

	sig = NHHall.ar(sig, 5) * -6.dbamp + sig;

	sig * Env.circle([0, 1, 0], [4, 5, 4], -4).kr();
};

~glitchbuf[2] = \set -> Pbind(
	\buf, buf,
	\foo, Pseg([0, numFrames], [dur], 0, inf).collect({arg val; if (1.coin){val}{Rest()}}),
	\pos, Pkey(\foo),
	\delta, 2,
	\dur, 1,
	\bar, Prand([-12, -7, 12].midiratio, inf),
	\rate, Pfunc({arg evt; if (1.coin) {-1}{1} * if (1.coin) {evt[\bar]} {1} }),
	\amp, 1,//Pif(Pfunc({arg evt; evt[\rate] < 2 }), -12.dbamp, -30.dbamp)
);

)

~glitchbuf.play(vol:1.7);
~glitchbuf.stop;



(
~env = {
	var in = \in.ar([0,0]);
	in.reverse * LFPulse.kr(SinOsc.kr(1/8).range(8, 10)).range(0,1)
}
)
~env.mold;

~env <<> ~jpverb1;
~env.play(vol:0.5);

