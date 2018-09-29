
/////////////////////////////////////////
// buffers
~bufs[\singing] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws2/180448__klankbeeld__ghana-woman-sing-traditional-song-dec-1986-2-007-01.wav");

/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// tgrains
~p[\tgrains].clear;
~p[\tgrains].mold;
(~p[\tgrains][0] = {

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

~p[\tgrains].addSpec(\posLo, [0.01, 0.99, \lin, 0.01, 0]);
~p[\tgrains].addSpec(\posHi, [0.01, 0.99, \lin, 0.01, 1]);
~p[\tgrains].addSpec(\posRate, [0.1, 2, \lin, 0.01, 1]);
~p[\tgrains].addSpec(\posDev, [0, 0.2, 5, 0, 0.01]);
~p[\tgrains].addSpec(\granDur, [0.01, 0.3, \lin, 0.01, 0.1]);
~p[\tgrains].addSpec(\trigRate, [1, 200, \lin, 0.01, 100]);
~p[\tgrains].addSpec(\rate, [0.1, 2, \lin, 0.01, 1]);
~p[\tgrains].addSpec(\panMax, [0.0, 1, \lin, 0.005, 0.8]);
~p[\tgrains].addSpec(\amp, [0.0, 0.5, \lin, 0.005, 0.25]);
);



~p[\tgrains].set(\buf, ~bufs[\singing]);
~p[\tgrains].play(vol:1, out:0);
~p[\tgrains].stop;
~tgrains_win = App.guiHelper(~p[\tgrains], "tgrains");
~tgrains_win.front;

(~p[\tgrains][2] = nil\set -> Pbind(
	\args, #[\amp],
	\amp, Pseg(Pseq([0, 0.2, 0],inf), Pseq([5],inf), \linear, inf),
	\dur, 0.125
));

/////////////////////////////////////////
// fb1
~p[\fb1].clear;
(~p[\fb1][0] = {

	var chain;
	var in = \in.ar([0,0]);
	var sig;
	var fblevel = \fblevel.kr(0.7);
	var fbNode = FbNode(2, 1, 4);
	var fb = fbNode.delay(0.01);// * fblevel + in;

	//fb = PitchShift.ar(fb, 0.2, 2, timeDispersion:0.1);
	//fb = FreqShift.ar(fb, [10,-10]);
	fb = SinOsc.ar(\freq.kr(88), in, 6);
	//chain = FFT(LocalBuf(2048, 2), fb);
	//chain = PV_MagAbove(chain, \above.kr(500));
	//chain = PV_BinScramble(chain, MouseX.kr , 0.1, MouseY.kr > 0.5 );
	//chain = IFFT(chain)!2;

	fb = DelayC.ar(fb, 0.2, SinOsc.kr(1/16).range(0.1, 0.2));
	//fb = SoftClipper8.ar(fb, 4);
	fb = JPverb.ar(fb, 5, 0, 5);

	sig = fb.reverse * fblevel + in;
	//fbNode.write( Limiter.ar(sig, 0.7) );
	fbNode.write( sig.tanh );

	//sig = BLowPass4.ar(sig, SinOsc.kr(0.1).range(440, 3200), 0.8);

	sig = XFade2.ar(JPverb.ar(sig, 5, 0, 5), sig);

	Splay.ar(sig);

};
~p[\fb1].addSpec(\fblevel, [0.0, 1.0, \lin, 0.0, 0.4]);
~p[\fb1].addSpec(\above, [50, 10000, \lin, 0.0, 500]);
);
~p[\fb1] <<> ~p[\tgrains];
~p[\fb1].play(vol:0, out:6);
~p[\fb1].stop;
~fb1_win = App.guiHelper(~p[\fb1], "fb1");
~fb1_win.front;


SwitchDelay

/////////////////////////////////////////
// sine
~p[\sine].clear;
~p[\sine].mold;
(~p[\sine][0] = {

	var trig = Dust.kr(1);
	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.0));

	var osc1 = {
		var sig = VarSaw.ar(freq);
		sig;
	};

	var env = Env(
		[0,\peakLevel.kr(1),\susLevel.kr(0.5),0],
		[\atk.kr(0.01), \decay.kr(0.3), \sus.kr(1), \rel.kr(1)],
		curve:\curve.kr(-4)
	).kr(gate:trig);

	var sig = [
		osc1.()
	].sum;

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig;
});

~p[\sine].set(\freq, (60).midicps)
~p[\sine].play;
~p[\sine].stop;
~p[\sine].gui;


/////////////////////////////////////////
// fb1
~p[\fb1].clear;
(~p[\fb1][0] = {
	var in = \in.ar([0,0]);
	var fbNode = FbNode(2, 5, 4);
	var fb = fbNode.delay(4);
	var sig = fb * 0.6 + in;
	sig = PitchShift.ar(sig, 0.5, 4);
	sig = FreqShift.ar(sig, [400, -100]);
	sig = (sig * 50).tanh * -30.dbamp;
	//sig = SoftClipAmp8.ar(in, 10) * -20.dbamp;
	sig = LPF.ar(sig.tanh, 4000);
	fbNode.write(sig);
});
~p[\fb1].play;
~p[\fb1].stop;
~p[\fb1].gui;

~p[\fb1] <<> ~p[\mix1];

/////////////////////////////////////////
// mix1
~p[\mix1].clear;
~p[\mix1][0] = \mix -> {~p[\sine]};
~p[\mix1][1] = \mix -> {~p[\tgrains]};
~p[\mix1].play;
~p[\mix1].stop;
~p[\mix1].gui;
~p[\mix1].set(\mix0, 1)


/////////////////////////////////////////
// filt1
~p[\filt1].clear;
(~p[\filt1][0] = {
	var in = \in.ar([0,0]);
	var fx = BLowPass4.ar(in, SinOsc.kr(0.1).range(200, 2000), 0.2, mul:2);
	fx
});
~p[\filt1].play;
~p[\filt1].stop;
~p[\filt1].gui;

~p[\filt1] <<> ~p[\fb1];


