~d1 = ProxySpace.new(s);
(~d1[\snd][0] = {

	var trig = \trig.tr;
	var freq = \freq.kr(432);
	var sig = SinOscFB.ar(freq * [1, 1.01], 0.7);
	var env = Decay2.kr(trig, decayTime:2);

	var d1, d2, d3, d4;
	var fb1, s1;

	sig = sig * env;


	fb1 = FbNode(2, 0.25);
	d1 = fb1.delay;
	d1 = sig + DelayC.ar(JPverb.ar(d1, t60:1, size:1, modDepth:0.5, modFreq:4), 0.25, 0.25);
	fb1.write(d1 * 0.6);

	d1 = XFade2.ar(d1, JPverb.ar(d1), 0);

	//AudioMSG.ar(d1 * 0.1, 1pi) * 0.1;
	SmoothClipS.ar(d1 * 2) * 0.1;

})

~d1[\snd].play
~d1[\snd].set(\trig, 1)

(~d1[\snd][4] = \set -> Pbind(\trig, 1, \dur, Pseq([0.25, 3.75], inf), \degree, Pbrown(0, 4, 1, inf), \octave, 5 ))

(
~d1[\snd].filter(12, {arg in;

	SVF.ar(in, SinOsc.kr(111).range(220,2200), 0.5);
})
)

~d1[\snd][12] = nil


App.recordWorkspace("ws4");
s.stopRecording


SmoothClipS

