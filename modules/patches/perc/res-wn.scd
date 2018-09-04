/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);


/////////////////////////////////////////
// wn
~p[\wn].clear;
~p[\wn].mold;
(~p[\wn][0] = {

	var trig = \trig.tr;
	var sig = WhiteNoise.ar;
	var env = Decay2.kr(trig, decayTime:\decay.kr(0.5));
	sig = RLPF.ar(sig, Env([4400,4400,880],[0, 0.1], -4).kr(gate:trig), 0.8);

	sig = sig * env * \amp.kr(-20.dbamp);
	sig = sig + DelayC.ar(sig, 1, (0..7).normalizeSum * 1);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1]);
	sig;
};
//~p[\\wn].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\wn].play(vol:1);
~p[\wn].stop;
~wn_win = App.guiHelper(~p[\wn], "wn");
~wn_win.front;

(~p[\wn][2] = nil\set -> Pbind(
	\args, #[\trig],
    \trig, 1,
	\dur, Pbjorklund2(7, 11, inf) * 0.5
));

(~p[\wn][4] = nil\set -> Pbind(
	\args, #[\decay],
	\decay, Pseq([1,0.5], inf),
	\dur, 2
));

(
Fdef('noteOn/48', {
	~p[\wn].set(\trig, 1)
})
)

TempoClock.default.tempo_(45/60)