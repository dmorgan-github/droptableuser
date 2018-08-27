/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);


/////////////////////////////////////////
// s1
~p[\s1].clear;
~p[\s1].mold;
(~p[\s1][0] = {

	var trig = \trig.tr;
	var freq = 180;
	var index = Env([16,16,0.1],[0,0.1],-4).kr(gate:trig);//XLine.kr(16, 0.1, 0.1);
	var sig = { PMOsc.ar(freq, freq * 2.1, index, mul:2) }.dup(2).sum.tanh;
	var env = Env.perc(releaseTime:1).kr(gate:trig) * LFPulse.kr(20).range(0,1);
	sig = Pan2.ar(sig, \pan.kr(0)) * env * \amp.kr(0.1);
	sig
});
(~p[\s1][2] = \set -> Pbind(
    \trig, 1,
	\dur, Pseq([6, 10], inf) * 0.25
));
~p[\s1].play;
~p[\s1].stop;
~p[\s1].gui;

/////////////////////////////////////////
// s2
~p[\s2].clear;
~p[\s2].mold;
(~p[\s2][0] = {

	var trig = \trig.tr;
	var sig = WhiteNoise.ar();
	var env = Env.perc(releaseTime:0.1).kr(gate:trig);
	sig = sig * env * \amp.kr(0.1);
	sig = { RLPF.ar(sig, 880, 0.01) }.dup(2).sum;
	sig = Pan2.ar(sig, \pan.kr(0));
	sig
});

(~p[\s2][2] = \set -> Pbind(
    \trig, 1,
	\dur, Pseq([8], inf) * 0.25,
	\timingOffset, 5
));

~p[\s2].play;
~p[\s2].stop;
~p[\s2].gui;


/////////////////////////////////////////
// fx1
~p[\fx1].clear;
(~p[\fx1][0] = {
	var in = ~p[\s1].ar;
	var fx = FbC({arg fb; fb * 0.3 + in}, [3/8, 5/8]);
	fx;
});
~p[\fx1].play;
~p[\fx1].stop;
~p[\fx1].gui;

/////////////////////////////////////////
// fx2
~p[\fx2].clear;
(~p[\fx2][0] = {
	var in = ~p[\fx1].ar;
	var sig = in ring1: SinOsc.ar(550);
	var fx = sig;
	fx;
});
~p[\fx2].play;
~p[\fx2].stop;
~p[\fx2].gui;

/////////////////////////////////////////
// fx3
~p[\fx3].clear;
(~p[\fx3][0] = {
	var in = ~p[\fx2].ar + ~p[\s1].ar;
	var sig = FreqShift.ar(in, [200, -200]);
	var fx = FbC({arg fb; fb * 0.4 + in}, [2/8, 6/8]);
	fx;
});
~p[\fx3].play;
~p[\fx3].stop;
~p[\fx3].gui;

/////////////////////////////////////////
// fx4
~p[\fx4].clear;
(~p[\fx4][0] = {
	var in = ~p[\fx3].ar;
	var fbNode = FbNode(2, 10);
	var fb = fbNode.delay(0.3);
	var sig = fb * 0.4 + in;
	sig = PitchShift.ar(sig, 0.5, 2);
	sig = SoftClipAmp8.ar(sig, 2.1);
	sig = JPverb.ar(sig, 2, 0, 2) * LFPulse.kr(15) * LFPulse.kr(0.5);
	fbNode.write(sig.tanh);
	sig;
});
~p[\fx4].play(vol:0.5);
~p[\fx4].stop;
~p[\fx4].gui;

/////////////////////////////////////////
// fx5
~p[\fx5].clear;
(~p[\fx5][0] = {
	var in = ~p[\fx4].ar + ~p[\fx3].ar;
	var fx = RLPF.ar(in, SinOsc.kr(1/16).range(440, 2200), 0.7);
	fx;
});
~p[\fx5].play;
~p[\fx5].stop;
~p[\fx5].gui;



/////////////////////////////////////////
// s3
~p[\s3].clear;
~p[\s3].mold;
(~p[\s3][0] = {

	var trig = \trig.tr;
	var sig = SinOsc.ar(330);
	var env = Env.perc(releaseTime:0.2).kr(gate:trig);
	sig = sig * env * \amp.kr(-12.dbamp);
	Pan2.ar(sig, \pan.kr(0));
});

(~p[\s3][2] = \set -> Pbind(
    \trig, 1,
	\dur, 1,
	\amp, -6.dbamp
));


~p[\s3].play;
~p[\s3].stop;
~p[\s3].gui;


/////////////////////////////////////////
// generate patterns
Tdef(\kit3).play;
Tdef(\kit3).stop;

(
Tdef(\kit3, {

	~cols = 16;

	~kit.matrix[0] = [ 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0 ];

	loop({

		(1..~kit.events.size-1).do({arg i;

			(0..~cols-1).do({arg j;

				var has_hit = false;
				i.do({arg k;
					if (~kit.matrix[k][j] == 1) {
						has_hit = true
					} {
						if (j > 0) {
							// if previous cell has a hit
							if (~kit.matrix[k][j-1] == 1) {
								if (0.6.coin) {
									has_hit = true;
								}
							}
						}
					}
				});

				if (has_hit) {
					//if (0.7.coin) {
						~kit.matrix[i][j] = 0;
					//} {
					//	~kit3_player.matrix[i][j] = 1;
					//}
				} {
					if (0.7.coin) {
						~kit.matrix[i][j] = 1;
					} {
						~kit.matrix[i][j] = 0;
					}
				}
			});

		});

		"............".postln;
		~kit.matrix.asString.replace("],", "],\n").postln;
		32.wait;
	});
});
)



PeakFollower
