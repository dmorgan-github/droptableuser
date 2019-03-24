/////////////////////////////////////////
// bassdrone
~p[\bassdrone].clear;
~p[\bassdrone].mold;
(~p[\bassdrone][0] = {

	var trig = \trig.kr(1);
	var freq = Vibrato.kr(\freq.kr(73.41).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.0));

	var osc1 = {
		var sig = Blip.ar(freq, 1000, 0.1);
		sig = Formlet.ar(sig, SinOsc.kr(1/16).range(freq, freq*5)/*MouseY.kr(73,2000,1)*/, 0.05, 0.01/*MouseX.kr(0.01,0.2,1)*/);
		sig * 6;
	};

	var osc2 = {
		var sig = Gendy2.ar(minfreq:freq, maxfreq:freq);
		sig
	};

	var env = Env.adsr.kr(gate:trig);

	var sig = [
		osc1.() * 1,
		osc2.() * 0.1
	].sum * 1;

	sig = SVF.ar(sig, SinOsc.kr(1/16).range(110, 2200), 0.2);

	sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr([1/16,1/8]).range(0.01, 0.05));

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);

	sig = Splay.ar(sig);
	sig;
};
//~p[\bassdrone].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\bassdrone].play(vol:2);
~p[\bassdrone].stop;
~bassdrone_win = App.guiHelper(~p[\bassdrone], "bassdrone");
~bassdrone_win.front;

