/////////////////////////////////////////
// sineblips
~p[\sineblips].clear;
~p[\sineblips].mold;
(~p[\sineblips][0] = {

    var trig = \trig.tr;

	var freq = 'C2'.namecps;

	var osc1 = {
		var sig = SinOsc.ar(freq).tanh;
		sig;
	};

	var osc2 = {
		var sig = SinOscFB.ar((freq.cpsmidi +7).midicps, SinOsc.kr(5).range(0.1, 0.8));
		sig;
	};

	var osc3 = {
		var sig = Saw.ar((freq.cpsmidi +12).midicps);
		sig;
	};

	var env = Env(
		[0,\peakLevel.kr(1),\susLevel.kr(0.5),0],
		[\atk.kr(0.01), \decay.kr(0.1), \sus.kr(0), \rel.kr(1)],
		curve:\curve.kr(-4)
	).kr(gate:trig);

	var sig = [
		osc1.(),
		osc2.() * 0.4,
		osc3.() * 0
	].sum;

	sig = sig * env * \amp.kr(-12.dbamp);

	sig = sig + DelayC.ar(PitchShift.ar(sig, 0.5, LFPulse.kr(1).range(12,24).midiratio), 1, [1,2,5,6], mul:0.2).sum;

	sig = Pan2.ar(sig, \pan.kr(0));
	sig;
};
//~p[\sineblips].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\sineblips].play(out:0);
~p[\sineblips].stop;
~sineblips_win = App.guiHelper(~p[\sineblips], "sineblips");
~sineblips_win.front;


(~p[\sineblips][2] = \set -> Pbind(
    \trig, 1,
	\dur, 2,
	\amp, -6.dbamp,
	\rel, 1,
	\sus, 1,
	\curve, 4,
	\susLevel, 0.5,
	\decay, 0.1
));
