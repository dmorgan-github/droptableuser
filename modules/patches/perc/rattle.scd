/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// rattle
~p[\rattle].clear;
~p[\rattle].mold;
(~p[\rattle][0] = {

    var sig = SinOsc.ar({rrand(330, 990) }.dup(8)).sum;
	var env = Env.perc(releaseTime:0.1).kr(gate:Impulse.kr(0.25));
	sig = sig * env;
	sig = FreqShift.ar(sig, [1110, -110] * LFPulse.kr(0.125).range(1, 2));
	sig = sig + DelayC.ar(sig, 1, [1,2,3,4,5,6,7,8].normalizeSum * LFPulse.kr(0.25).range(1, 2));
	sig = sig * \amp.kr(-20.dbamp);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1]);
	sig;
};
//~p[\rattle].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\rattle].play(vol:0.5);
~p[\rattle].stop;
~rattle_win = App.guiHelper(~p[\rattle], "rattle");
~rattle_win.front;
