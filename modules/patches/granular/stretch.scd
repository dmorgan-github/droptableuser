
~buf = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws7/SC_190105_171820/SC_190105_171820-mono.wav");

(
Ndef(\ps, {

	var buf = ~buf;
	var stretch = buf.duration.reciprocal * 5.reciprocal;

	var sig = Warp1.ar(1,
		bufnum:buf,
		pointer:LFSaw.kr(stretch).range(0, 1),
		freqScale:[1, 2, 0.5, 1.5],
		windowSize:0.1,
		envbufnum:-1,
		overlaps:8,
		windowRandRatio:0.5,
		interp:4
	);

	sig = Splay.ar(sig, 0, 1, 0);

	sig = BLowPass.ar(BHiPass.ar(sig, \hpf.kr(1200), \hpf_res.kr(1)), \lpf.kr(1200), \lpf_res.kr(1));

	sig = sig.blend(FbC({arg fb; PitchShift.ar(fb, 0.2, 1.5, 0.01, 0.01) * 0.6 + sig}, 0.1), 0.6 );

	sig = sig.blend(JPverb.ar(HPF.ar(sig, 100), 6, 0, 5, earlyDiff:0.707, modDepth:0.5), 0.4);

	sig = sig * \amp.kr(-6.dbamp);

	sig;
})
)

Ndef(\ps).set(\hpf, 440, \lpf, 3200, \hpf_res, 0.8, \lpf_res, 0.4, \amp, -8.dbamp)

Ndef(\ps).mold;

App.saveWorkspace("ws7", rec:true);
Ndef(\ps).play(fadeTime:8, vol:0.1);
Ndef(\ps).stop(fadeTime:8);
s.stopRecording;


