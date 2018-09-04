/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// n2
~p[\n2].clear;
~p[\n2].mold;
(~p[\n2][0] = {

    var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.0));

	var osc1 = {
		var trig = Impulse.kr(2);
		var sig = Pulse.ar(10);// ring1: SinOsc.ar(10);
		var lfo = LFPulse.kr(20).range(0,1);
		var env = Env.perc(releaseTime:0.5).kr(gate:trig);
		var freq = Demand.kr(trig, 0, Dseq([0.01, 0.005], inf));

		sig = FbC({arg fb; FreqShift.ar(fb, [10, -10]) * 0.8 + sig}, 0.1).tanh;
		sig = sig + CombC.ar(sig, 0.1, freq);
		sig = BPeakEQ.ar(sig, 220, 1, 1.dbamp);

		sig = sig * lfo;
		sig = sig * env;
		sig;
	};

	var env = 1;

	var sig = [
		osc1.()
	].sum;

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig;
};
//~p[\n2].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\n2].play(vol:0.5);
~p[\n2].stop;
~n2_win = App.guiHelper(~p[\n2], "n2");
~n2_win.front;