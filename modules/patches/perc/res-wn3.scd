/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);


/////////////////////////////////////////
// wn3
~p[\wn3].clear;
~p[\wn3].mold;
(~p[\wn3][0] = {

	var trig = Impulse.kr(2);
	var sig = WhiteNoise.ar;
	var env = Decay2.kr(trig, decayTime:LFPulse.kr(0.5).range(0.1, 0.5));
	sig = RLPF.ar(sig, Env([4400,4400,880],[0,0.1],-4).kr(gate:trig), 0.5);
	sig = sig + SinOsc.ar(env.range(2300,30), mul:0.3);

	sig = sig * env * \amp.kr(-20.dbamp);
	sig = DelayC.ar( SinOsc.ar(env.range(1300,30)) * env * \amp.kr, 0.5, 0.5) + sig;
	sig = sig + DelayC.ar(sig, 1, [1,2,3,4,5,6,7,8].normalizeSum * 1);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1]);
	sig;
};
//~p[\\wn3].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\wn3].play(vol:1);
~p[\wn3].stop;
~wn3_win = App.guiHelper(~p[\wn3], "wn3");
~wn3_win.front;

