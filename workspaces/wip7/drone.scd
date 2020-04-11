(
~bufs = [
"/Users/david/projects/droptableuser/workspaces/wip5/bitwig/drone-guitar/samples/7f76fc8_20200404111634.aiff",
"/Users/david/projects/droptableuser/workspaces/wip5/bitwig/drone-guitar/samples/7f76fc8_20200404111848.aiff",
"/Users/david/projects/droptableuser/workspaces/wip5/bitwig/drone-guitar/samples/7f76fc8_20200404112427.aiff",
"/Users/david/projects/droptableuser/workspaces/wip5/bitwig/drone-guitar/samples/568da71_20200404105748.aiff",
"/Users/david/projects/droptableuser/workspaces/wip5/bitwig/drone-guitar/samples/SC_190609_174613.wav"
];
)


~bb = List.new;
~bufs.do({arg path; Buffer.read(s, path, action:{arg buf;~bb.add(buf)})});

(
~b = ~bufs.collect({arg path, i;
	var key = ('b' ++ i).asSymbol;
	B(key, path);
});
)

~b[0].play;
~b[1].play;
~b[2].play;
~b[3].play;

~b[0].node.stop;
~b[1].node.stop;
~b[2].node.stop;
~b[3].node.stop;

~b[0].stretch = 2;
~b[1].stretch = 3;

~b[2].stretch = 5;
~b[2].freqmode = 1;
~b[2].degree = Pwhite(0, 4);

TempoClock.default.tempo = 45/60;

Ndef(\mix2).play
Ndef(\mix2)[0] = \mix -> {~b[0].node.ar * SinOsc.ar(1/31).range(0.1, 1.0)};
Ndef(\mix2)[1] = \mix -> {~b[1].node.ar * SinOsc.ar(1/51).range(0.1, 1.0)};
Ndef(\mix2)[2] = \mix -> {~b[2].node.ar * SinOsc.ar(1/71).range(0.1, 1.0)};
Ndef(\mix2)[3] = \mix -> {~b[3].node.ar * SinOsc.ar(1/91).range(0.1, 1.0)};


Ndef(\mix)[90] = nil
Ndef(\mix)[100] = nil
Ndef(\mix)[110] = nil

Ndef(\mix2).filter(90, {arg in; PitchShift.ar(in, 2, [1.5, 2], 0.01, 0.01)}).set(\wet90, 0.6);
Ndef(\mix2).filter(100, {arg in; JPverb.ar(in, 5, 0, 5)}).set(\wet100, 0.7);
Ndef(\mix2).filter(110, {arg in; FbC({arg fb; fb.tanh * 0.79 + in}, 1, TempoClock.default.beatDur * [3/8, 4/8] )}).set(\wet110, 0.4);

App.saveWorkspace("wip7", rec:true);
Ndef(\mix2).play(vol:1.5);
Ndef(\mix2).stop(fadeTime:8);
s.stopRecording;


(
Ndef(\buf)[0] = {

	var buf = TChoose.kr(Dust.kr(0.5), ~bb);
	var sig = BufRd.ar(
        2,
        buf,
		phase: (
			LFDNoise3.ar(0.02).range(0, 1).lag(0.1) + // global movement
			SinOsc.ar(1/4).range(0, [0.003, 0.0032]) // local movement
		) * BufFrames.kr(buf),
		interpolation: 4
    ) * 0.5;
	sig = LeakDC.ar(sig) * LFDNoise3.ar(10).range(0, 1);
	Splay.ar(sig.flatten);
};
)

Ndef(\buf).filter(90, {arg in; JPverb.ar(in, 5, 0, 5)}).set(\wet90, 0.4)

Ndef(\buf).play(vol:0.5);
Ndef(\buf).stop;

App.saveWorkspace("wip7", rec:true);
s.stopRecording;




