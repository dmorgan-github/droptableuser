(
SynthDef(\oneshot, {

	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var start = \start.kr(0);
	var curve = \curve.kr(0);
	var dur = \sus.kr(1);

	var numFrames = BufFrames.kr(buf);
	var startFrame = start * numFrames;
	var bufDur = BufDur.kr(buf);

	var phase = Env([startFrame, numFrames], [bufDur * rate.reciprocal], curve).ar();
	var sig = BufRd.ar(1, buf, phase, loop:0, interpolation: 4);
	var env = Env.linen(0, dur, 0).kr(doneAction:2);
	sig = sig * env;

	4.do({
		sig = LPF.ar(sig, 18000);
	});

	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);

	OffsetOut.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////
// patch
//~kit2 = ProxySpace.new(s);
//~kit2.quant = 4.0;
//~kit2.clock = TempoClock.default;


/////////////////////////////////
// buffers
~bufs = ~bufs ? ();
~bufs[\cdosys] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/windows-system-samples/cdosys.dll.wav");

~fx = NodeProxy.audio(s, 2);

~kit2_player = ~grid_player.();
~kit2_player.dur = Pseq([0.5], inf).asStream;

(
var rate = Pwhite(0.1, 0.2).asStream;
var rev = Pwrand([1,-1], [0.4, 0.6], inf).asStream;
var start = Pwhite(0.1, 0.5).asStream;
var dur = Pwhite(0.1, 0.3).asStream;

~kit2_player.events = [
	(instrument:\oneshot, buf:~bufs[\cdosys], amp:0.2, rate:0.9, start:0, sus:0.1),
	(instrument:\oneshot, buf:~bufs[\cdosys], amp:0.2, rate:0.5, start:0.1, sus:0.2),
	(instrument:\oneshot, buf:~bufs[\cdosys], amp:0.0, rate:0.5, start:0.3, sus:0.1)
];
)

(~kit2_player.matrix = [
	[1,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,0],
	[0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0],
	[0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1],
])

(
~kit2_player.matrix = (0..~kit2_player.events.size-1).collect({arg i;
	(0..~cols-1).collect({arg j; 0})
});
)

~kit2_player.player.play


(

Tdef(\kit2, {

	~cols = 16;

	loop({

		(0..~kit2_player.events.size-1).do({arg i;

			(0..~cols-1).do({arg j;

				var has_hit = false;
				i.do({arg k;
					if (~kit2_player.matrix[k][j] == 1) {
						has_hit = true
					} {
						if (j > 0) {
							// if previous cell has a hit
							if (~kit2_player.matrix[k][j-1] == 1) {
								if (0.6.coin) {
									has_hit = true;
								}
							}
						}
					}
				});

				if (has_hit) {
					~kit2_player.matrix[i][j] = 0;
				} {
					if (0.6.coin) {
						~kit2_player.matrix[i][j] = 1;
					} {
						~kit2_player.matrix[i][j] = 0;
					}
				}
			});

		});

		"............".postln;
		~kit2_player.matrix.asString.replace("],", "],\n").postln;
		32.wait;
	});

});

Tdef(\kit2).play;
)



App.soundflowerOut(s);
App.recordWorkspace("ws4");
s.stopRecording



