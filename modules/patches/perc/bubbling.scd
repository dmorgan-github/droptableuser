/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// n1
~p[\n1].clear;
~p[\n1].mold;
(~p[\n1][0] = {

    var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.0));

	var osc1 = {

		var rate = Demand.kr(Impulse.kr(16), 0, Dseq([0.5, 1, 2, 4], inf));
		var trigs = Impulse.kr(rate);
		var sig = WhiteNoise.ar;
		var env = Decay2.kr(trigs, decayTime:0.05);
		var freq = Demand.kr(trigs, 0, Dseq([440, 880, 660], inf));
		sig = RLPF.ar(sig, freq, SinOsc.kr(1/16).range(0.01, 0.1));
		sig = sig * env;

		sig = sig +
		DelayC.ar(
			FreqShift.ar(sig,
				[1,2,4,8,16] * SinOsc.kr(0.5).range(1,SinOsc.kr(1/8).range(100,500))
			),
			1,
			{rrand(0.1,0.8)}.dup(5)
		).sum;
		sig;
	};

	var env = Env.circle([0,1,0],[4,8,4],-4).kr(gate:1);

	var sig = [
		osc1.()
	].sum;

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig;
};
//~p[\n1].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\n1].play(vol:1);
~p[\n1].stop;
~n1_win = App.guiHelper(~p[\n1], "n1");
~n1_win.front;


