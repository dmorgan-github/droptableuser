/////////////////////////////////////////
// pulse
~p[\pulse].clear;
~p[\pulse].mold;
(~p[\pulse][0] = {

    var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.0));

	var env = Env(
		[0,\peakLevel.kr(1),\susLevel.kr(0.5),0],
		[\atk.kr(0.01), \decay.kr(0.3), \sus.kr(1), \rel.kr(1)],
		curve:\curve.kr(-4)
	).kr(gate:trig);

	var osc1 = {
		var sig = Pulse.ar(freq, width:LFNoise2.kr(1/16).range(0.4, 0.7));
		sig = SoftClipAmp8.ar(sig, \osc1_gain.kr(2));
		sig = BLowPass4.ar(sig, env.exprange(220, 1200), 0.7);
		sig;
	};

	var osc2 = {
		var sig = PMOsc.ar(freq, freq * env.exprange(2,2), env.exprange(0.1, 12));
		sig;
	};

	var sig = [
		osc1.dup(2).sum,
		osc2.dup(2).sum * 0.02
	].sum;

	sig = SVF.ar(sig, env.exprange(880, 4200), 0.3);

	sig = [sig, DelayC.ar(sig, 0.05, SinOsc.kr(1/8).range(0.001, 0.005))];

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig;
};
//~p[\pulse].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);

(~p[\pulse][2] = \set -> Pbind(
    \trig, 1,
	\degree, Ppatlace([
		2, 1,
		Pstutter(4, Pseq([3,4], inf)),
		0
	], inf),
	\mtranspose, 0,
	\scale, Scale.ritusen,
	\octave, 5,
	\delta, 0.25,
	\decay, 0.1,
	\sus, 0.2,
	\rel, 1
));


~p[\pulse].play(vol:0.7);
~p[\pulse].stop;
~pulse_win = App.guiHelper(~p[\pulse], "pulse");
~pulse_win.front;

/////////////////////////////////////////
// delay
~p[\delay].clear;
(~p[\delay][0] = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; (fb * 2).tanh * 0.3 + in}, [3/8,5/8]);
	fx;
};
//~p[\delay].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\delay] <<> ~p[\pulse];
~p[\delay].play(vol:0.5);
~p[\delay].stop;
~delay_win = App.guiHelper(~p[\delay], "delay");
~delay_win.front;

/////////////////////////////////////////
// reverb
~p[\reverb].clear;
(~p[\reverb][0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 1, 0, 2, modDepth:0.4);
	fx;
};
//~p[\reverb].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\reverb] <<> ~p[\pulse];
~p[\reverb].play(vol:0.4);
~p[\reverb].stop;
~reverb_win = App.guiHelper(~p[\reverb], "reverb");
~reverb_win.front;
