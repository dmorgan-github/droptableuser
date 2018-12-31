~buf = Buffer.read(s, "/Users/david/Downloads/75129__digifishmusic__vocodex-pitched-carrier-tutorial-vocal.wav");
~buf = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws1/332554__ebcrosby__city-field-recording-with-spanish-dialogue-between-mother-and-son.wav");
~buf = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws1/55208__noisecollector__kidstory.wav");
~buf = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws1/cdosys.dll.wav");

~p[\buffy].mold
~p[\buffy].clear;
~p[\buffy].play(vol:1)
~p[\buffy].stop;
(
~p[\buffy][0] = {

	var buf = \buf.kr(0);
	//var startPos = 0;
	var startPos = DemandEnvGen.kr(
		Dseq([1], inf),
		Dseq([0.01, 0.05, 0.07, 0.1].reciprocal, inf),
		7
	) * BufFrames.kr(buf);

	var trig = Impulse.kr([1,2]);
	var rev = TChoose.kr(PulseDivider.kr(trig, 2), [-1, 1]);
	var sig = PlayBuf.ar(1, buf, rate:0.2 * rev, trigger:trig, startPos: startPos, loop: 1);
	sig = LeakDC.ar(sig);
	Splay.ar(sig);
};
)
~p[\buffy].set(\buf, ~buf);

Ndef(\del).clear;
Ndef(\del).play;
Ndef(\del).stop;
(
Ndef(\del).filter(16, {arg in;
	var sig = FbC({arg fb; fb * 0.6 + in}, [1/8, 3/8]);
	Splay.ar(sig, 0.6);
})
)

Ndef(\del)[0] = \mix -> {Ndef(\buffy).ar}
(Ndef(\del)[1] = \mix -> {

	var trig = Dust.kr(1);
	var val = TChoose.kr(PulseDivider.kr(trig, 2), [5, 10, 20, 30]);
	Squiz.ar(Ndef(\del).ar, 2, [val, 1])
});
Ndef(\del).set(\mix1, 0.8)

Ndef(\rev).clear;
Ndef(\rev).play(vol:0.4);
Ndef(\rev).stop;
(
Ndef(\rev).filter(16, {arg in;
	JPverb.ar(in, 6, 0, 6);
})
);

Ndef(\rev)[0] = \mix -> {Ndef(\del).ar};

NdefMixer(s).parent.alwaysOnTop_(true); // show mixer in front of IDE


s.prepareForRecord(Document.current.path ++ ".aiff", 2);
s.record;
s.stopRecording