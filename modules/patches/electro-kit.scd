(
SynthDef(\s1, {

	var sig = PMOsc.ar(1880, 1623, Rand(1,1, 3.1), mul:0.5) * LFPulse.ar(20).range(0, 1);
	var env = Env.triangle(dur:Rand(0.1, 1)).kr(doneAction:2);
	sig = sig * env * \amp.kr(0.1)!2;

	OffsetOut.ar(\out.kr(0), sig);

}).add;

SynthDef(\s2, {

	//var sig = HPF.ar(WhiteNoise.ar(), 10220);// * LFPulse.ar(150).range(0, 1);
	var sig = SinOsc.ar(Line.kr(3200, 111, 0.015));
	var env = Env.triangle(dur:0.1).kr(doneAction:2);
	sig = sig * env * \amp.kr(0.1)!2;
	sig = Decimator.ar(sig, 44100/7, 8);
	sig = RLPF.ar(sig, 440, 0.1);

	OffsetOut.ar(\out.kr(0), sig);

}).add;

SynthDef(\s3, {

	var sig = WhiteNoise.ar() * Env([0,1].dup(10).flatten, 1.dup(9), -4).ar(timeScale:0.05);
	var env = Env.perc(0.001, releaseTime:0.1).kr(doneAction:2);
	sig = sig * env * \amp.kr(0.1)!2;

	OffsetOut.ar(\out.kr(0), sig);

}).add;

SynthDef(\s4, {

	var sig = HPF.ar(Blip.ar(20), 50);
	var env = Env.perc(0.001, releaseTime:0.1).kr(doneAction:2);
	sig = sig * env * 0;//\amp.kr(0.1)!2;

	OffsetOut.ar(\out.kr(0), sig);

}).add;

)


TempoClock.default.tempo_(40/60);

~kit3_player = ~grid_player.();
~kit3_player.dur = Pseq([0.25], inf).asStream;

(

var dur = [
	Pseq([0.125, 0.125, 0.125], 1),
	Pseq([0.125, 0.125], 1)
];

var count = 0;



~kit3_player.events = [
	Pbind(\instrument, \s2, \amp, 0.1, \delta, Plazy({ count = count + 1; dur.wrapAt(count); }) ),//(instrument:\s2, amp:0.1),
	Pbind(\instrument, \s1, \amp, 0.03, \dur, Pseq([0.125, 0.125], 1)),//(instrument:\s1, amp:0.03),
	(instrument:\s3, amp:0.05)/*,
	(instrument:\s4, amp:0.2)*/
];
)


/*
(~kit3_player.matrix = [
	[1,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,0],
	[0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0],
	[0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1],
	//[0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1]
])

(
~kit3_player.matrix = (0..~kit3_player.events.size-1).collect({arg i;
	(0..~cols-1).collect({arg j; 0})
});
)
*/

~kit3_player.player.play
~kit3_player.player.stop

~s5 = ProxySpace.new(s);
~s5[\snd] = ~kit3_player.player;
~s5[\snd].play
~s5[\snd].stop

(~s5[\snd].filter(4, {arg in;
	//var sig = FbC({arg fb; fb * 0.4 + in}, 0.4);
	JPverb.ar(in);
}).set(\wet4, 0.2))

Tdef(\kit3).stop;

(
Tdef(\kit3, {

	~cols = 16;

	~kit3_player.matrix[0] = [ 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0 ];

	loop({

		(1..~kit3_player.events.size-1).do({arg i;

			(0..~cols-1).do({arg j;

				var has_hit = false;
				i.do({arg k;
					if (~kit3_player.matrix[k][j] == 1) {
						has_hit = true
					} {
						if (j > 0) {
							// if previous cell has a hit
							if (~kit3_player.matrix[k][j-1] == 1) {
								if (0.6.coin) {
									has_hit = true;
								}
							}
						}
					}
				});

				if (has_hit) {
					//if (0.7.coin) {
						~kit3_player.matrix[i][j] = 0;
					//} {
					//	~kit3_player.matrix[i][j] = 1;
					//}
				} {
					if (0.7.coin) {
						~kit3_player.matrix[i][j] = 1;
					} {
						~kit3_player.matrix[i][j] = 0;
					}
				}
			});

		});

		"............".postln;
		~kit3_player.matrix.asString.replace("],", "],\n").postln;
		32.wait;
	});

});

Tdef(\kit3).play;
)


(1/3).reciprocal


3 ** 0.1


(1 - 3).abs

(1 - 2).abs

