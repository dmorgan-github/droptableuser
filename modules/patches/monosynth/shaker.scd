~p[\shaker].clear;
(~p[\shaker][0] = {

	var trig = \trig.tr;
	var noise = WhiteNoise.ar;
	var sig = BPF.ar(noise, 4200, 0.1);
	var env = Env.perc(curve:-4).kr(gate:trig);

	// feedback loop
	sig = sig + LocalIn.ar(2).reverse;
	sig = GrainIn.ar(1, Impulse.kr([8,10]), SinOsc.kr(4).range(0.01, 0.1), sig);
	sig = FreqShift.ar(sig, 1500).tanh;
	LocalOut.ar(sig);

	sig = sig * env * \amp.kr(-6.dbamp);
	Splay.ar(sig);
})
~p[\shaker][2] = nil\set -> Pbind(\trig, 1, \dur, 1)
~p[\shaker].play;
~p[\shaker].stop;


(
var node = ~p[\shaker].quant_(0);
Pdef(\shaker, {arg out = 0;
	node.play(fadeTime:0, out:out);
	Pbind(\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \amp],
		\trig, Pseq([1,0,1,0], inf),
		\dur, 0.25,
		\amp, -15.dbamp
	)
});
)

Pdef(\shaker).play;
App.saveWorkspace("ws1", rec:true);
s.stopRecording;
