
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(35/60);



/////////////////////////////////////////
// seq1
~p[\seq1].clear;
~p[\seq1].mold;
(~p[\seq1][0] = {
    var freq = \freq.kr;
	var trig = \trig.tr;
	var trigs = (0..7).collect({arg i; ('t' ++ i).asSymbol.tr;});
	var start = trigs[0] > 0;
	[freq, trig] ++ trigs ++ [start];
});
(
var minor_eleven = [ 0, 3, 7, 10, 14 ];
var major_thirteen = [ 0, 4, 7, 14, 18, 21 ];
~p[\seq1][1] = \set -> Pbind(
	\trig, 1,
	\delta, 0.25,
	\scale, Scale.chromatic,
	\mtranspose, Pstutter(8, Pseq([0,1,2,-2], inf)),
	\octave, Pbjorklund(3,7, inf).collect({arg val; if (val == 0) {5}{6} }),
	[\degree, \t0, \t1, \t2, \t3, \t4, \t5, \t6, \t7], Pseq([
		Ptuple([
			Pseq(minor_eleven, 1),
			Pseq( (0..minor_eleven.size-1), 1)
		], 1),
		Ptuple([
			Pseq(major_thirteen, 1),
			Pseq( (0..major_thirteen.size-1), 1)
		], 1)
	], inf).collect({arg val;
		var idx = val[1];
		[val[0]] ++ Array.fill(8, 0)[idx] = 1
	})
));

/////////////////////////////////////////
// s1
~p[\s1].clear;
~p[\s1].mold;
(~p[\s1][0] = {

	var seq = ~p[\seq1].kr;
	var freq = seq[0];
	var trig = seq.select({arg item, i; i.odd});

	var env = Env.perc(0.01, \release.kr(0.2)).kr(gate:trig);
	var sig = Saw.ar (freq);
	sig = sig * env;
	sig = BLowPass4.ar(sig, env.range(880, 2200), 0.3);
	Splay.ar (sig) * \amp.kr (1) * AmpCompA.kr(freq);
});
~p[\s1].play(out:0, vol:-10.dbamp);
~p[\s1].stop;
~p[\s1].gui;
(~p[\s1][2] = \set -> Pbind(
	\amp, Pbjorklund(4, 7, inf).collect({arg val; if (val == 0) {0.4}{1}})
))


/////////////////////////////////////////
// s2
~p[\s2].clear;
~p[\s2].mold;
(~p[\s2][0] = {

	var seq = ~p[\seq1].kr;
	var freq = seq[0].varlag(0.01, -4);
	var trig = seq.select({arg item, i; i.even });
	var env = Env.perc(0.01, \release.kr(1)).kr(gate:trig);
	//var sig = Pluck.ar(WhiteNoise.ar(0.4), trig,
	//	freq.reciprocal * 2,
	//	freq.reciprocal * LFPulse.kr(1/8).range(1.0, 2.0),
	//	10,
	//	coef:0.3
	//);
	var sig = SinOsc.ar(freq);
	sig = sig * env;
	Pan2.ar (sig.sum) * \amp.kr (1) * AmpCompA.kr(freq);
});
~p[\s2].play(out:0, vol:-20.dbamp);
~p[\s2].stop;
~p[\s2].gui;
(~p[\s2][2] = \set -> Pbind(
	\amp, Pbjorklund(5, 9, inf).collect({arg val; if (val == 0) {0.4}{1}})
));


/////////////////////////////////////////
// s3
~p[\s3].clear;
~p[\s3].mold;
(~p[\s3][0] = {

	var seq = ~p[\seq1].kr;
	var trig = seq[10];
	var freq = Latch.kr(seq[0], trig);
	var sig = SinOscFB.ar( (freq.cpsmidi).midicps, Env([0.3,0.3,0.6],[0,1], 4).kr(trig)).fold(-0.8, 0.8);
	var env = Env.linen(attackTime:1, sustainTime:1, releaseTime:0.1).kr(gate:trig);
	sig = BLowPass.ar(sig, SinOsc.kr(4).range(110, 1880), 0.3);
	Pan2.ar(sig) * env * AmpCompA.kr(freq);
});
~p[\s3].play(out:4, vol:-21.dbamp);
~p[\s3].stop;
~p[\s3].gui;


App.recordWorkspace("ws5");
s.stopRecording
