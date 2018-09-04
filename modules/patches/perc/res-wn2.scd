/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);


/////////////////////////////////////////
// wn2
~p[\wn2].clear;
~p[\wn2].mold;
(~p[\wn2][0] = {

	var trig = \trig.tr;
	var sig = WhiteNoise.ar;
	var env = Env.perc(releaseTime:0.05).kr(gate:trig);
	sig = HPF.ar(sig, 6400);

	sig = sig * env * \amp.kr(-20.dbamp);
	sig = sig + DelayC.ar(sig, 1, [1,2,3,4,5,6,7,8].normalizeSum * 1);

	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1]);
	sig;
};
//~p[\\wn2].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\wn2].play(vol:2, out:2);
~p[\wn2].stop(fadeTime:5);
~wn2_win = App.guiHelper(~p[\wn2], "wn2");
~wn2_win.front;

(~p[\wn2][2] = \set -> Pbind(
    \trig, 1,
	\dur, 1
));

/////////////////////////////////////////
// del : delay with feedback
~p[\del].clear;
(~p[\del][0] = {
	var tempo = TempoClock.default.beatDur;
	var in = \in.ar([0,0]);
	var fb = FbC({arg fb;
		fb * \fb.kr(0.7) + in;
	}, [\delayL.kr(3/8) * tempo, \delayR.kr(5/8) * tempo]);
	fb;
};
~p[\del].addSpec(\fb, [0.0, 1.0, \lin, 0.0, 0.2]);
~p[\del].addSpec(\delayL, [0.001, 5, \lin, 0.0, 3/8]);
~p[\del].addSpec(\delayR, [0.001, 5, \lin, 0.0, 5/8]);
);
~p[\del] <<> ~p[\wn2];
~p[\del].play(out:2)
~p[\del].stop(fadeTime:5)
~del_win = App.guiHelper(~p[\del], "del");
~del_win.front;


(
Fdef('noteOn/50', {
	~p[\wn2].set(\trig, 1)
})
)

TempoClock.default.tempo_(45/60)