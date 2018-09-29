/////////////////////////////////////////
// tgrains_live
~p[\tgrains_live].clear;
~p[\tgrains_live].mold;
(~p[\tgrains_live][0] = {

	var in = \in.ar([0,0]).sum;
	var bufNum = \buf.kr(0);
	var posLo = \posLo.kr(0.0);
	var posHi = \posHi.kr(1.0);
	var posRate = \posRate.kr(1);
	var posDev = \posDev.kr(0.01);
	var trigRate = \trigRate.kr(100);
	var granDur = \granDur.kr(0.1);
	var rate = \rate.kr(1.0);
	var panMax = \panMax.kr(1);
	var amp = \amp.kr(-12.dbamp);
	var interp = \interp.kr(4);

	var foo = {
		RecordBuf.ar(in, bufNum);
	}.();

	var posDif = posHi - posLo;
	var bufDur = BufDur.kr(bufNum);
	var bufDurSection = bufDur * posDif;
	var trig = Impulse.kr(trigRate);
	var pos = posLo * bufDur +
	(
		Phasor.ar(0, BufRateScale.kr(bufNum) * posRate / SampleRate.ir, posLo * bufDur, posHi * bufDur) +
		(TRand.kr(-0.5 * posDev, 0.5 * posDev, trig) * bufDur)
	).mod(bufDurSection);

	var pan = Demand.kr(trig, 0, Dseq([panMax, panMax.neg],inf) * 0.999);

	var sig = TGrains.ar(2, trig, bufNum, rate, pos, granDur, pan, 1, interp) * amp;

	sig * Env.circle([0,1,0],[8,8,16],-4).kr(gate:1);
};

~p[\tgrains_live].addSpec(\posLo, [0.01, 0.99, \lin, 0.01, 0]);
~p[\tgrains_live].addSpec(\posHi, [0.01, 0.99, \lin, 0.01, 1]);
~p[\tgrains_live].addSpec(\posRate, [0.1, 2, \lin, 0.01, 1]);
~p[\tgrains_live].addSpec(\posDev, [0, 0.2, 5, 0, 0.01]);
~p[\tgrains_live].addSpec(\granDur, [0.01, 0.3, \lin, 0.01, 0.1]);
~p[\tgrains_live].addSpec(\trigRate, [1, 200, \lin, 0.01, 100]);
~p[\tgrains_live].addSpec(\rate, [0.1, 2, \lin, 0.01, 1]);
~p[\tgrains_live].addSpec(\panMax, [0.0, 1, \lin, 0.005, 0.8]);
~p[\tgrains_live].addSpec(\amp, [0.0, 0.5, \lin, 0.005, 0.25]);
);

/////////////////////////////////////////
// 10 second buffer
~bufs[\glitch] = Buffer.alloc(s, 44100 * 10, 1);

~p[\tgrains_live] <<> ~p[\delay];
~p[\tgrains_live].set(\buf, ~bufs[\glitch], \rate, 1, \trigRate, 200, \granDur, 2);

~p[\tgrains_live].play(vol:1);
~p[\tgrains_live].stop;
~tgrains_live_win = App.guiHelper(~p[\tgrains_live], "tgrains_live");
~tgrains_live_win.front;


/////////////////////////////////////////
// greyhole
~p[\greyhole].clear;
(~p[\greyhole][0] = {
	var in = \in.ar([0,0]);
	var fx = Greyhole.ar(in);
	fx;
};
//~p[\greyhole].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\greyhole] <<> ~p[\tgrains_live];
~p[\greyhole].play(vol:0.7);
~p[\greyhole].stop;
~greyhole_win = App.guiHelper(~p[\greyhole], "greyhole");
~greyhole_win.front;

