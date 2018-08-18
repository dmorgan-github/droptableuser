~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 1.0;
~p.fadeTime = 1;
~p.makeTempoClock;

(~p[\seq][0] = {
	var pitch = \pitch.kr([0,0,0]).lag(2);
	pitch;
});

(
var circle = Library.at(\circle);
~p[\seq][2] = \set -> Pbind(

	\delta, 8,
	\scale, Scale.dorian,
	\degree, Pseq([
		Pn(circle[\first], 1),
		Pn(circle[\fifth], 1),
		Pn(circle[\second], 1)
	], inf),
	\octave, 4,
	\pitch, Pfunc({arg evt;
		var freq, note, midinote;
		var scale = evt[\scale] ? Scale.major;
		var stepsPerOctave = evt[\stepsPerOctave] ? 12.0;
		var degree = evt[\degree] ? 0.0;
		var mtranspose = evt[\mtranspose] ? 0.0;
		var gtranspose = evt[\gtranspose] ? 0.0;
		var root = evt[\root] ? 0.0;
		var ctranspose = evt[\ctranspose] ? 0.0;
		var harmonic = evt[\harmonic] ? 1.0;
		var octave = evt[\octave] ? 5.0;

		note = (degree + mtranspose).degreeToKey(scale, stepsPerOctave);
		midinote = ((note + gtranspose + root) / stepsPerOctave + octave) * 12.0;
		freq =  (midinote + ctranspose).midicps * harmonic;
		freq
	}).collect(`_)
));

(~p[\s1][0] = {
	var freq = ~p[\seq].kr()[0];
	var sig = Pulse.ar(freq * 2);
	sig = RLPF.ar(sig, LFTri.kr(1/16).range(440, 2200), 0.5);
	sig;
});
~p[\s1].play;
~p[\s1].stop;

(~p[\s2][0] = {
	var freq = ~p[\seq].kr()[1];
	var sig = PMOsc.ar(freq, freq * SinOsc.kr(1/16).range(2.1, 4.1),
		LFNoise2.kr(1/16).range(3, 8)
	);
	sig;
});
~p[\s2].play;
~p[\s2].stop;

(~p[\s3][0] = {
    var freq = ~p[\seq].kr()[2];
	var sig = VarSaw.ar(freq, 0, SinOsc.kr(1/8).range(0.4, 0.6));
	sig = BLowPass4.ar(sig, LFTri.kr(1/8).range(440, 2200), 0.8);
	sig;
});
~p[\s3].play;
~p[\s3].stop;

~p[\mix][0] = \mix -> {~p[\s1]};
~p[\mix][1] = \mix -> {~p[\s2]};
~p[\mix][2] = \mix -> {~p[\s3]};
~p[\mix].play;
~p[\mix].stop;
~p[\mix].set(\mix0, 0, \mix1, 0, \mix2, 0)
~p[\mix].gui


(~p[\fb][0] = {

	var in = \in.ar([0]);
	var fbNode = FbNode(1, 10);
	var fb = fbNode.delay(0.3);

	var sig = (in * 3).tanh;
	sig = sig + PitchShift.ar(sig, 0.4, 2, mul:0.3).softclip;
	sig = sig + DelayC.ar(sig, 8, 8);
	sig = LPF.ar(fb * 0.4, SinOsc.kr(1/16).range(488, 2440)).tanh + sig;

	fbNode.write(sig);

	sig = sig * 0.7 + RLPF.ar(sig, SinOsc.kr(1/16).range(880, 2200), 0.8);
	Splay.ar(sig);
});
~p[\fb] <<> ~p[\mix];
~p[\fb].play;
~p[\fb].stop;


(~p[\jpverb][0] = {
	var in = \in.ar([0]);
	var fx = JPverb.ar(in,
		\t60.kr(1),
		\damp.kr(0),
		\size.kr(1),
		\earlyDiff.kr(0.707),
		\modDepth.kr(0.1),
		\modFreq.kr(2)
	);
	Splay.ar(fx);
});
~p[\jpverb] <<> ~p[\fb];
~p[\jpverb].play;
~p[\jpverb].stop;

~p[\jpverb].set(\t60, 5, \size, 5, \modDepth, 0.7);

(~p[\jpverb2][0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in,
		\t60.kr(1),
		\damp.kr(0),
		\size.kr(1),
		\earlyDiff.kr(0.707),
		\modDepth.kr(0.1),
		\modFreq.kr(2)
	);
	Splay.ar(fx);
});
~p[\jpverb2] <<> ~p[\jpverb];
~p[\jpverb2].play;
~p[\jpverb2].stop;

~p[\jpverb2].set(\t60, 15, \size, 10, \modDepth, 0.2);


App.recordWorkspace("ws14");
s.stopRecording

Volume(s, 0, 2).gui

