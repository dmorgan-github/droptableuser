(
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(1);
~p.makeTempoClock;
)


/////////////////////////////////////////
// seq1
~p[\seq1].clear;
~p[\seq1].mold;
(~p[\seq1][0] = {
    var freq = \freq.kr;
	var trig = \trig.tr;
	[freq, trig] ++ (0..7).collect({arg i; ('t' ++ i).asSymbol.tr;});
});
(
var minor_eleven = [ 0, 3, 7, 10, 14, 17 ];
var major_thirteen = [ 0, 4, 7, 14, 18, 21 ];
~p[\seq1][1] = \set -> Pbind(
	\trig, 1,
	\delta, 0.125,//Prand([0.25, 0.5, 0.125], inf),
	\mtranspose, Pstutter(8, Pseq([0,1,2,-2], inf)),
	\octave, Pbjorklund(3,7, inf).collect({arg val; if (val == 0) {4}{5} }),
	[\degree, \t0, \t1, \t2, \t3, \t4, \t5, \t6, \t7], Pseq([
		Ptuple([
			Pseq(minor_eleven, 1),
			Pseq( (0..minor_eleven.size-1), 1 )
		], 1),
		Ptuple([
			Pseq(major_thirteen, 1),
			Pseq( (0..major_thirteen.size-1), 1 )
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
	var trig = seq.select({arg item, i; i.even});

	var env = Env.perc(0.01, \release.kr(0.1)).kr(gate:trig);
	var sig = VarSaw.ar (freq, 0, 0.8);
	sig = sig * env;
	sig = BLowPass4.ar(sig, SinOsc.kr(1/32).range(880, 3600), SinOsc.kr(1/64).range(0.4,0.9));
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
	//var trig = seq[2..4];
	//var trig = seq[5..9];
	var trig = seq.select({arg item, i; i.odd});

	var env = Env.perc(0.01, \release.kr(1)).kr(gate:trig);
	var sig = SinOsc.ar (freq * [1, 1.01]) * env;
	Splay.ar (sig) * \amp.kr (1) * AmpCompA.kr(freq);
});
~p[\s2].play(out:2, vol:-3.dbamp);
~p[\s2].stop;
~p[\s2].gui;
(~p[\s2][2] = \set -> Pbind(
	\amp, Pbjorklund(5, 9, inf).collect({arg val; if (val == 0) {0.4}{1}})
))

/////////////////////////////////////////
// ring1
(~p[\ring1][0] = {
	var in = ~p[\s2].ar;
	var sig = in ring1: SinOsc.ar(200);
	sig = sig * SinOsc.kr(1/32).range(0, 1);
	sig = SoftClipAmp8.ar(sig, 2);
	sig;
});
~p[\ring1].play(out:4, vol:-20.dbamp);
~p[\ring1].stop;
~p[\ring1].gui;


/////////////////////////////////////////
// s3
~p[\s3].clear;
~p[\s3].mold;
(~p[\s3][0] = {

	var seq = ~p[\seq1].kr;
	//var trig = seq[2..4];
	//var trig = seq[5..9];
	var trig = PulseDivider.kr( seq.select({arg item, i; (i%4) == 0}), 3);
	var freq = Vibrato.kr(Latch.kr(seq[0], trig), 6, 0.005);

	var env = Env.linen(1, sustainTime:1, releaseTime:1).kr(gate:trig);
	var sig = SinOscFB.ar (freq * 0.5, 0.6) * env;
	Splay.ar (sig) * \amp.kr (1) * AmpCompA.kr(freq);
});
~p[\s3].play(out:6, vol:-8.dbamp);
~p[\s3].stop;
~p[\s3].gui;


App.recordWorkspace("ws2");
s.stopRecording
