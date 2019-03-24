Ndef(\droney).play(fadeTime:10, vol:0.2);
Ndef(\s2).play(fadeTime:20);
Ndef(\droney).stop;

Ndef(\droney).clear;
(
Ndef(\droney, {

	var trig = Impulse.kr([3,0.5]);
	var freq = 110 * ([0, 7, 12, 19] + LFPulse.kr(1/16).range(0,2)).midiratio * [1, 1.01];
	var env = Env.perc.kr(gate:trig);
	var sig = VarSaw.ar(Vibrato.kr(freq, 6, 0.01),
		0,
		SinOsc.ar(1/13).range(0.3, 0.7)
	);
	//sig = SVF.ar(sig, Env([4400,4400,2200],[0, 0.1], 0.1).kr(gate:trig), 0.3);
	sig = Splay.ar(sig) * env * \amp.kr(0.dbamp);
	sig;
});

Ndef(\droney).filter(4, {arg in;

	var sig;
	var speed = 1;
	var fb1 = FbNode(2, 1, 4);
	var del1 = {
		var sig = fb1.delay(speed * 6/8);
		sig = SoftClipAmp8.ar(sig, 1.5);
		sig = AllpassC.ar(sig);
		Splay.ar(sig) * 0.4;
	}.();

	var fb2 = FbNode(2, 1, 4);
	var del2 = {
		var sig = fb2.delay(speed * (5/8));
		sig = PitchShift.ar(sig, 0.5, LFPulse.kr(1/5).range(2,4)).tanh;
		sig = sig * Env.circle([0,1,0],[2,2,2],-4).kr();
		sig = AllpassC.ar(sig);Â
		sig = JPverb.ar(sig, 5, 0, SinOsc.kr(1/64).range(1,2));
		sig = Resonz.ar(sig, 440, 2);
		Splay.ar(sig);
	}.();

	fb1.write(del1 + (del2 * 0.5) + in);
	fb2.write(del2 + (del1 * 0.5) + in);

	sig = in + [
		del1,
		del2
	].sum;

	sig;
});

Ndef(\droney).filter(5, {arg in;
	var sig = FbC({arg fb; fb * 0.5 + in}, [3/8, 5/8]);
	Splay.ar(sig, 0.5);
}).set(\wet5, 0.7);

Ndef(\droney).filter(6, {arg in;
	var sig = JPverb.ar(in, 5, 0, 5);
	sig = BLowPass4.ar(sig, SinOsc.kr(1/32).range(440, 8800), 0.6);
	sig;
}).set(\wet6, 0.5);
)


(
Ndef(\s2, {

	var trig = Impulse.kr(4);
	var freq = Demand.kr(trig, 0, Dseq((57 + 12 + ([0] ++ Scale.dorian.degrees.rotate)).midicps, inf));
	var sig = SinOscFB.ar(Vibrato.kr(freq.lag(0.01) * LFNoise2.kr(1/16).range(0.901,1.01), 6, 0.005), 0.3);
	var env = Env.perc(releaseTime:0.5).kr(gate:trig);
	sig = DFM1.ar(sig, 4400, 0.8);
	sig = Splay.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-30.dbamp);
	sig = FbC({arg fb; fb * 0.4 + sig}, [3/8, 5/8]) * 0.7 + sig;
	sig = JPverb.ar(sig,2, 0, 2) * 0.5 + sig;
	sig;
})
)

Ndef(\s2).stop;
Ndef(\s2).clear;
Ndef(\s2).play(vol:1);


~buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/vox/apollo-lift-vector-issue2.wav");
~buf.duration/60
(
Ndef(\s3, {
	var sig = PlayBuf.ar(1, ~buf, 1, trigger: \trig.tr(1));
	sig = JPverb.ar(sig, 3, 0, 3) * 0.6 + sig;
	sig = Splay.ar(sig).tanh;
	sig;
})
)

(
{
	App.saveWorkspace("ws1", rec:true);
	Ndef(\droney).play(fadeTime:4, vol:1);
	Ndef(\s3).set(\trig, 1);
	Ndef(\s3).play(vol:0.2, fadeTime:64);
	222.wait;
	Ndef(\droney).stop(fadeTime:8);
	Ndef(\s3).stop(fadeTime:8);
	12.wait;
	s.stopRecording;

}.fork;
)

Ndef(\s3).play(vol:0.03, fadeTime:24);