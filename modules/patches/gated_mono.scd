/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// snd1
~p[\snd1].clear;
~p[\snd1].mold;
(~p[\snd1][0] = {

	var gate = \gate.kr(0);

	var freq = Vibrato.kr(
		\freq.kr(432).lag(\lag.kr(0.1)),
		\vrate.kr(6),
		\vdepth.kr(0.01)
	);

	var osc1 = {
		var sig = SinOscFB.ar(freq, 0.7);
		//var trig = Trig1.kr(gate, 0.01);
		sig;
	};

	var osc2 = {
		var sig = VarSaw.ar(freq);
		sig = SoftClipAmp8.ar(sig, 2);// * Env.circle([0,1,0], [0.1,0.05,2].normalizeSum, -4).kr(timeScale:0.5);
		sig;
	};

	var osc3 = {

		var fb;
		var fbNode = FbNode(1, 1, 4);
		var index = Env.circle([1,4,1], [1,1,1], -4).kr(timeScale:1);
		var ratio = Env.circle([0.5,1,0.5], [1,1,1].normalizeSum, -4).kr(timeScale:4);
		var ffreq = Env.circle([2000,3000,1000], [1,1,1].normalizeSum, -4).kr(timeScale:1);
		var sig = PMOsc.ar(freq, freq * 0.5, index);

		fb = fbNode.delay(0.5);
		sig = fb * 1 + sig;
		sig = PitchShift.ar(sig, 0.5, 12.midiratio);
		sig = DelayC.ar(sig, 0.2, SinOsc.kr(0.1).range(0.1, 0.2));
		sig = DFM1.ar(sig, SinOsc.kr(0.1).range(220, 1220), \res1.kr(0.5));

		fbNode.write((sig * 500 * 0.1).clip(-0.7, 0.7));

		sig = sig + BLowPass4.ar(sig, SinOsc.kr(5).range(880, 1200), \res2.kr(0.1));
		sig = AdCVerb2.ar(sig, \revTime.kr(3)).sum;
		sig * Env.asr(0.1).kr(gate:gate);
	};

	var env = Env.adsr(attackTime:\atk.kr(0.01),
		decayTime:\decay.kr(0.3),
		sustainLevel:\sus.kr(0.5),
		releaseTime:\rel.kr(1),
		curve:\curve.kr(-4)
	).kr(gate:gate);

	var sig = [
		osc1.() * 1,
		osc2.() * 0.5,
		osc3.() * 0.1
	].sum.dup(2);

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	//sig = Pan2.ar(sig, \pan.kr(0));
	sig = Splay.ar(sig);
	sig;
};
//~p[\snd1].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);

(~p[\snd1][2] = \set -> Pbind(
	\args, #[\gate, \freq],
	\gate, Pseq([1, 0], inf),
	\dur, Pseq([1, 1, 1, 1, 1, 1, 2.9, 0.1], inf),
	\scale, Scale.chromatic,
	\degree, Pstutter(Pseq([6, 2], inf), Pseq([10, 2], inf))
));


~p[\snd1].set(\gate, 1, \freq, 'G1'.namecps);

~p[\snd1].play(vol:0.3);
~p[\snd1].stop;
~snd1_win = App.guiHelper(~p[\snd1], "snd1");
~snd1_win.front;


(
~freq_func = {arg evt;

	var freq, note, midinote;
	var scale = evt[\scale] ? Scale.major;
	var stepsPerOctave = evt[\stepsPerOctave] ? 12.0;
	var degree = evt[\degree] ? 0.0;
	var mtranspose = evt[\mtranspose] ? 0.0;
	var gtranspose = evt[\gtranspose] ? 0.0;
	var root = evt[\root] ? 0.0;
	var ctranspose = evt[\ctranspose] ? 0.0;
	var harmonic = evt[\harmonic] ? 1.0;
	var octave = evt[\octave] ? 5.0;

	note = (degree + mtranspose).degreeToKey(scale, stepsPerOctave);
	midinote = ((note + gtranspose + root) / stepsPerOctave + octave) * 12.0;
	freq =  (midinote + ctranspose).midicps * harmonic;
	freq;
};

Fdef(\noteOn, {arg note;

	var degree = note - 48;
	var freq = ~freq_func.( (degree: degree, scale: Scale.chromatic) );
	~p[\snd1].set(\gate, 1, \freq, freq);
});
Fdef(\noteOff, {arg note;
	~p[\snd1].set(\gate, 0);
})
)

~keyboard.().front;

/////////////////////////////////////////
// fb1 : feedback
~p[\fb1].clear;
(~p[\fb1][0] = {

	var in = \in.ar([0,0]);
	var fbNode = FbNode(2, 1);
	var fb = fbNode.delay(\delay.kr(0.1));
	var sig = fb * \fb.kr(0.4) + in;

	// limit feedback
	//sig = WaveLoss.ar(sig);
	//sig = PitchShift.ar(in, 0.5, 2);
	sig = LPF.ar(sig.tanh, \lpf.kr(3200));
	fbNode.write(sig);
	Rotate2.ar(sig[0], sig[1], SinOsc.kr(\rotate.kr(1/16)).range(-1, 1));
};

~p[\fb1].addSpec(\fb, [0, 1, \lin, 0, 0.4]);
~p[\fb1].addSpec(\delay, [0, 1, \lin, 0, 0.1]);
~p[\fb1].addSpec(\lpf, [20, 20000, \lin, 0, 3200]);
~p[\fb1].addSpec(\rotate, [1/64, 10, \lin, 0, 1/16]);
);
~p[\fb1] <<> ~p[\snd1];
~p[\fb1].play;
~p[\fb1].stop;
~fb1_win = App.guiHelper(~p[\fb1], "fb1");
~fb1_win.front;

/////////////////////////////////////////
// tap1 : multi tap delay with feedback
~p[\tap1].clear;
(~p[\tap1][0] = {

	var in = \in.ar([0,0]);
	var tap1, tap2, tap3, tap4;
	var fbNode = FbNode(1, 6.5, 4);

	var tap1_delay = \tap1_delay.kr(0.2).lag(0.1);
	var tap2_delay = \tap2_delay.kr(0.5).lag(0.1);
	var tap3_delay = \tap3_delay.kr(0.7).lag(0.1);
	var tap4_delay = \tap4_delay.kr(1).lag(0.1);

	var tap1_mul = \tap1_mul.kr(1).lag(0.1);
	var tap2_mul = \tap2_mul.kr(0.7).lag(0.1);
	var tap3_mul = \tap3_mul.kr(0.5).lag(0.1);
	var tap4_mul = \tap4_mul.kr(0.2).lag(0.1);

	tap1 = fbNode.delay(tap1_delay);
	tap2 = fbNode.delay(tap2_delay);
	tap3 = fbNode.delay(tap3_delay);
	tap4 = fbNode.delay(tap4_delay);

	fbNode.write(Mix.ar(in)
		+ (tap1 * \tap1_fb.kr(0).lag(0.1))
		+ (tap2 * \tap2_fb.kr(0).lag(0.1))
		+ (tap3 * \tap3_fb.kr(0).lag(0.1))
		+ (tap4 * \tap4_fb.kr(0).lag(0.1))
	);

	Splay.ar([tap1 * tap1_mul, tap2 * tap2_mul, tap3 * tap3_mul, tap4 * tap4_mul],
		\spread.kr(1),
		center:\center.kr(0)
	);
};

~p[\tap1].addSpec(\tap1_delay, [0, 6, \lin, 0, 0.2]);
~p[\tap1].addSpec(\tap2_delay, [0, 6, \lin, 0, 0.5]);
~p[\tap1].addSpec(\tap3_delay, [0, 6, \lin, 0, 0.7]);
~p[\tap1].addSpec(\tap4_delay, [0, 6, \lin, 0, 1]);

~p[\tap1].addSpec(\tap1_mul, [0, 1, \lin, 0, 1]);
~p[\tap1].addSpec(\tap2_mul, [0, 1, \lin, 0, 0.7]);
~p[\tap1].addSpec(\tap3_mul, [0, 1, \lin, 0, 0.5]);
~p[\tap1].addSpec(\tap4_mul, [0, 1, \lin, 0, 0.2]);

~p[\tap1].addSpec(\tap1_fb, [0, 1, \lin, 0, 0]);
~p[\tap1].addSpec(\tap2_fb, [0, 1, \lin, 0, 0]);
~p[\tap1].addSpec(\tap3_fb, [0, 1, \lin, 0, 0]);
~p[\tap1].addSpec(\tap4_fb, [0, 1, \lin, 0, 0]);

~p[\tap1].addSpec(\spread, [0, 1, \lin, 0, 1]);
~p[\tap1].addSpec(\center, [-1, 1, \lin, 0, 0]);
);
~p[\tap1] <<> ~p[\snd1];
~p[\tap1].play;
~p[\tap1].stop;
~tap1_win = App.guiHelper(~p[\tap1], "tap1");
~tap1_win.front;


/////////////////////////////////////////
// mix1
~p[\mix1].clear;
~p[\mix1][0] = \mix -> {~p[\snd1]};
~p[\mix1][1] = \mix -> {~p[\tap1]};
~p[\mix1].play;
~p[\mix1].stop;
~p[\mix1].set(\mix0, 1);
~mix1_win = App.guiHelper(~p[\mix1], "mix1");
~mix1_win.front;


/////////////////////////////////////////
// rev1
~p[\rev1].clear;
(~p[\rev1][0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in,
        \t60.kr(1),
        \damp.kr(0),
        \size.kr(1),
        \earlyDiff.kr(0.707),
        \modDepth.kr(0.1),
        \modFreq.kr(1),
        \low.kr(1),
        \mid.kr(1),
        \hi.kr(1),
        \lowcut.kr(500),
        \hicut.kr(2000)
    );
    fx;
};
~p[\rev1].addSpec(\t60, [0.0, 60.0, \lin, 0.0, 1]);
~p[\rev1].addSpec(\damp, [0.0, 1, \lin, 0.0, 0]);
~p[\rev1].addSpec(\size, [1, 5, \lin, 0.0, 1]);
~p[\rev1].addSpec(\earlyDiff, [0.0, 1, \lin, 0.0, 0.707]);
~p[\rev1].addSpec(\modDepth, [0.0, 1, \lin, 0.0, 0.1]);
~p[\rev1].addSpec(\modFreq, [0, 10, \lin, 0.0, 2]);
~p[\rev1].addSpec(\low, [0, 1, \lin, 0.0, 1]);
~p[\rev1].addSpec(\mid, [0, 1, \lin, 0.0, 1]);
~p[\rev1].addSpec(\hi, [0, 1, \lin, 0.0, 1]);
~p[\rev1].addSpec(\lowcut, [100, 6000, \lin, 0.0, 500]);
~p[\rev1].addSpec(\hicut, [1000, 10000, \lin, 0.0, 1000]);
);
~p[\rev1] <<> ~p[\mix1];
~p[\rev1].play;
~p[\rev1].stop;
~rev1_win = App.guiHelper(~p[\rev1], "rev1");
~rev1_win.front;


/////////////////////////////////////////
// filt1
~p[\filt1].clear;
(~p[\filt1][0] = {
	var in = \in.ar([0,0]);
	var fx = BLowPass4.ar(in, SinOsc.kr(\rate.kr(0.5)).range(\lo.kr(20), \hi.kr(6000)), \rq.kr(1));
	fx
};
~p[\filt1].addSpec(\rate, [0.001, 10, \lin, 0.0, 0.5]);
~p[\filt1].addSpec(\lo, [20, 6000, \lin, 0.0, 220]);
~p[\filt1].addSpec(\hi, [2000, 8000, \lin, 0.0, 2000]);
~p[\filt1].addSpec(\rq, [0.001, 4, \lin, 0.0, 1]);
);
~p[\filt1] <<> ~p[\rev1];
~p[\filt1].play;
~p[\filt1].stop;
~filt1_win = App.guiHelper(~p[\filt1], "filt1");
~filt1_win.front;


/////////////////////////////////////////
// peak1 : peak eq
~p[\peak1].clear;
(~p[\peak1][0] = {
	var in = \in.ar([0,0]);
	var fx = BPeakEQ.ar(in, \freq.kr(1200), \rq.kr(1), \db.kr(0));
	fx;
};
~p[\peak1].addSpec(\freq, \freq.asSpec);
~p[\peak1].addSpec(\rq, [0.0001, 4.0, \lin, 0.0, 1]);
~p[\peak1].addSpec(\db, [-80.0, 10, \lin, 0.0, 0]);
);
~p[\peak1] <<> ~p[\rev1];
~p[\peak1].play;
~p[\peak1].stop;
~peak1_win = App.guiHelper(~p[\peak1], "peak1");
~peak1_win.front;

App.saveWorkspace("wip2");
s.stopRecording