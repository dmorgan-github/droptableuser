TempoClock.default.tempo = 1;

B.read(\guitar, "/Users/david/Documents/supercollider/media/1channel/loops/nylon-guitar-loop-b-1.mono.wav", 0);
B.read(\a, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0);
B.read(\h, "/Users/david/Documents/supercollider/media/Hainbach - Isolation Loops (soundpack)/Hainbach - Isolation Loops (soundpack) - 20 Soundtrack Acoustics.wav", 0);

B.read(\h2, "/Users/david/Documents/supercollider/media/Hainbach - Isolation Loops (soundpack)/Hainbach - Isolation Loops (soundpack) - 39 Test Equipment.wav",0);

(
//var buf = Buffer.read(Server.default, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
//var buf = B(\guitar);
var buf = B(\a);
Ndef(\s)[0] = {

	var in = {
		var sig = PlayBuf.ar(1, buf, loop:1);
		sig;
	};

	var stutter = {|in|
		var sig, which = \which.kr(0);
		var del = \del.kr(0.2);// * Rand(0.5, 2.0);
		var fb = LocalIn.ar(2);
		sig = SelectX.ar(which, [in, fb]);
		sig = DelayC.ar(sig.reverse, 4, del * [1, 0.2]);
		LocalOut.ar(sig);
		sig = SelectX.ar(which, [in, fb * 1.2]);
		sig;
	};

	var del = {|in|
		var beatDur = TempoClock.default.beatDur;
		var beats = beatDur * TempoClock.default.beatsPerBar;
		var sig = DelayC.ar(in.reverse, beats, beats * LFSaw.ar(beats.reciprocal).unipolar( 0.2 ) );
		sig;
	};

	var sig = in.();
	sig = stutter.(sig);
	sig = del.(sig);

	sig = JPverb.ar(sig, 5, 0, 5) * 0.7 + (sig);

	Splay.ar(sig, 0.5) * \amp.kr(0.2)

};
)

Ndef(\s).set(\which, 0).play;

Ndef(\s).set(\amp, 0.5);

// switch between executing these lines
Ndef(\s).set(\which, 0);
Ndef(\s).set(\which, 1, \del, exprand(0.01, 4).postln);
Ndef(\s).set(\del, 0.01)


Ndef(\s).stop;




