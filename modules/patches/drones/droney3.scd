
~send = Bus.alloc(\audio, Server.default, 2);
~return = Bus.alloc(\audio, Server.default, 2);

/////////////////////////////////////////
// fb
Ndef(\fb).play;
(
Ndef(\fb, {

	var return;
	var in = \in.ar([0,0]);
	var fb = FbNode(2, 1, 4);
	var sig = fb.delay(\delay.kr(0.2).lag(0.1)) * \fb.kr(0.5).lag(0.1);

	// send and return
	Out.ar(~send, sig);
	sig = Ndef(\test).ar;

	fb.write(sig + in);
	Splay.ar(sig, \spread.kr(1));
});
Ndef(\fb).addSpec(\fb, [0,1,\lin,0,0.1]);
Ndef(\fb).addSpec(\spread, [0,1,\lin,0,0.1]);
Ndef(\fb).addSpec(\delay, [0,4,\lin,0,0.2]);
);
Ndef(\fb).gui;

/////////////////////////////////////////
// fx
(
Ndef(\test, {
	var in = InFeedback.ar(~send, 2);
	var fb = SoftClipAmp8.ar(in, \pregain.kr(1.3));
	fb = BLowPass4.ar(fb, SinOsc.kr(1/8).range(440, 1800), 0.5);
	fb = FreqShift.ar(fb, [-100, 100]);
	fb = fb * Env.circle([0,1,1,0],[2,8,1,2],-4).kr(gate:1);
	//fb = fb * Env.circle([0,1,1,0],[3,10,1,1],4).kr(gate:1);
	fb = JPverb.ar(fb, 10, 0, 3);
	Splay.ar(fb.tanh);
});
Ndef(\test).addSpec(\pregain, [0,4,\lin,0,1]);
)
Ndef(\test).mold;
Ndef(\test).play;
Ndef(\test).stop;
Ndef(\test).gui;

/////////////////////////////////////////
// signal
(
Ndef(\sig, {
	var trig = \trig.tr(0);
	var freq = \freq.kr(432);
	var sig = SinOsc.ar(freq) * [1,1.01] * Env.perc.kr(gate:trig);
	Splay.ar(sig, \spread.kr(1));
});
)
Ndef(\sig).play(vol:1);
Ndef(\sig).stop;
Ndef(\sig).set(\trig, 1, \freq, rrand(110, 1200));

Ndef(\fb) <<> Ndef(\sig);
Ndef(\fb).play;
Ndef(\fb).stop;



(
Ndef(\droney3, {

	var trig = \trig.tr(0);
	var sig;
	var freq = Demand.kr(trig, 0, Drand(210 * ([0, 5, 9, 14]).midiratio, inf));

	var fb1 = FbNode(2, 1, 4);
	var sig1 = {
		Pulse.ar(freq) * [1,1.01] * Env.perc.kr(gate:trig);
	}.();

	var del1 = {
		var sig = fb1.delay( Array.fill(3, {rrand(0.2, 0.8)} ) );
		sig = sig * \fb1.kr(0.3);
		sig = FreqShift.ar(sig, [-100, 100]);
		sig = sig.flatten;
		sig = SoftClipAmp8.ar(sig, 1.5);
		sig = LPF.ar(sig, 2200);
		Splay.ar(sig);
		//Splay.ar(sig.tanh);
	}.();

	fb1.write(del1 + sig1);

	sig = [
		del1
	] * [1].normalizeSum;

	//sig = PitchShift.ar(sig, 0.5, [7, 9].midiratio) + sig;
	sig = sig.flatten;
	sig = BLowPass4.ar(sig, SinOsc.kr(1/32).range(880, 4400), 0.5);
	sig = JPverb.ar(sig, 10, 0, SinOsc.kr(1/64).range(1, 2)) * 0.5 + sig;
	sig = Splay.ar(sig, 0.7) * -12.dbamp;
	sig = Limiter.ar(sig, -3.dbamp);
	sig = BPeakEQ.ar(sig, 7000, 1, -30);
	sig = Rotate2.ar(sig[0], sig[1], LFSaw.kr(0.06));
	sig;

}).play
)

Ndef(\droney3).play(vol:0.3);
Ndef(\droney3).stop(fadeTime:30);
Ndef(\test).stop(fadeTime:10);


(Ndef(\test, {

	var in = Ndef(\droney3).ar;
	in = PitchShift.ar(in, 0.5, 12.midiratio);
	in = WaveLoss.ar(in);
	Greyhole.ar(in) + in;

}).play(vol:0.3))

(
var view = View().layout_(VLayout());
view.layout.add(Knob().action_({arg ctrl;
	Ndef(\droney3).set(\fb1, ctrl.value.postln);
}));
view.layout.add(Button().action_({arg ctrl; Ndef(\droney3).set(\trig, 1) }));
view.front;
)

App.saveWorkspace("ws1", rec:true);
s.stopRecording