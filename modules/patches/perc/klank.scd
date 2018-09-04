/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);


/////////////////////////////////////////
// klank
~p[\klank].clear;
~p[\klank].mold;
(~p[\klank][0] = {

	var trig = \trig.tr;//Impulse.kr(2);
	var sig = DynKlank.ar(`[
		{rrand(110.0, 240.0)}.dup(10),
		nil,
		{rrand(0.1,1.0)}.dup(10)
	], WhiteNoise.ar,
	freqscale: 20
	);
	var env = Decay2.kr(trig, decayTime:0.05);
	sig = sig * env * \amp.kr(-20.dbamp);
	//sig = sig + DelayC.ar(sig, 1, [1,2,3,4,5,6,7,8].normalizeSum * 1);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1]);
	sig;
};
//~p[\klank].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\klank].play(vol:0.07);
~p[\klank].stop;
~klank_win = App.guiHelper(~p[\klank], "klank");
~klank_win.front;

(~p[\klank][2] = nil\set -> Pbind(
    \trig, 1,
	\dur, Pbjorklund2(7,11) * 0.25,
	\amp, -25.dbamp
));

(
Fdef('noteOn/49', {
	~p[\klank].set(\trig, 1)
})
)