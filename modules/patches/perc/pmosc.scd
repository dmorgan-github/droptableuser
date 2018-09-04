/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// pmosc
~p[\pmosc].clear;
~p[\pmosc].mold;
(~p[\pmosc][0] = {

	var trig = \trig.tr;//Impulse.kr(0.5);
	var freq = 120;
	var index = Env([16,16,0], [0,0.1], -4).kr(gate:trig);
	var sig = PMOsc.ar(freq, freq * 1.1, index);
	var env = Env.perc(releaseTime:0.5).kr(gate:trig);
	sig = sig * env;
	sig = sig + DelayC.ar(sig, 1, [1,2,3,4,5,6,7,8].normalizeSum);
	sig = sig * \amp.kr(-20.dbamp);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1]);
	sig
};
//~p[\pmosc].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\pmosc].play(vol:1, out:0);
~p[\pmosc].stop;
~pmosc_win = App.guiHelper(~p[\pmosc], "pmosc");
~pmosc_win.front;

~p[\pmosc].set(\trig, 1, \amp, 0.dbamp);

s.meter(2,2).window.alwaysOnTop_(true);

(
Fdef('noteOn/51', {
	~p[\pmosc].set(\trig, 1)
})
)