/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// gated_multi
~p[\gated_multi].clear;
~p[\gated_multi].mold;
(~p[\gated_multi][0] = {

	var gate = \gate.kr(0);

	var freq = Vibrato.kr(
		\freq.kr(432).lag(\lag.kr(0.1)),
		\vrate.kr(6),
		\vdepth.kr(0.01)
	);

	var sig = [
		// osc1
		{
			var oscfb = \osc1_fb.kr(0.7);
			var fbNode = FbNode(2, 1, 4);
			var osc = SinOscFB.ar(freq, SinOsc.kr(1/16).range(0.3, 0.7));
			var fb = fbNode.delay(0);
			var trig = Trig1.kr(gate, 0.01);
			var fshift = \fshift.kr(1);
			var delay=\delay.kr(0.1);
			var depth=\depth.kr(0.08);
			var rate = \rate.kr(0.06);

			var maxdelay = 0.013;
			var maxrate = 10.0;

			fb = FreqShift.ar(fb, [fshift, fshift.neg]);
			fb = AllpassC.ar(fb, 0.013 * 2,
				LFPar.kr(
				maxdelay * 2,
				rate * maxrate,
				0,
				depth * maxdelay,
				delay * maxdelay)
			);
			osc = fb * oscfb + osc;
			fbNode.write( Limiter.ar(osc, 1) );
			osc.asArray.sum;

		}.() * \osc1.kr(0.dbamp),

		// osc2
		{
			var osc = VarSaw.ar(freq * -12.midiratio);
			var pregain = \osc2_pregain.kr(2);
			osc = SoftClipAmp8.ar(osc, pregain);
			osc * Env.circle([0,1,0],[2,1,1],4).kr(gate:gate);

		}.() * \osc2.kr(-6.dbamp),

		// osc3
		{
			Silence.ar;

		}.() * \osc3.kr(-20.dbamp),

	].sum.dup(2);

	var env = Env.adsr(attackTime:\atk.kr(0.01),
		decayTime:\decay.kr(0.3),
		sustainLevel:\susLevel.kr(0.5),
		releaseTime:\rel.kr(1),
		curve:\curve.kr(-4)
	).kr(gate:gate, timeScale:\ts.kr(1));

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0));
	sig;
};
// adsr envelope controls
~p[\gated_multi].addSpec(\atk, [0.001, 1.0, \lin, 0.0, 0.01]);
~p[\gated_multi].addSpec(\decay, [0.001, 1.0, \lin, 0.0, 0.3]);
~p[\gated_multi].addSpec(\susLevel, [0.001, 1.0, \lin, 0.0, 0.5]);
~p[\gated_multi].addSpec(\rel, [0.001, 1.0, \lin, 0.0, 1]);
~p[\gated_multi].addSpec(\curve, [-24, 24, \lin, 0.0, -4]);
~p[\gated_multi].addSpec(\ts, [0.01, 10, \lin, 0.0, 1]);

// freq/vibrato controls
~p[\gated_multi].addSpec(\lag, [0.001, 1, \lin, 0.0, 0]);
~p[\gated_multi].addSpec(\vrate, [0.001, 6, \lin, 0.0, 6]);
~p[\gated_multi].addSpec(\vdepth, [0.001, 1, \lin, 0.0, 0]);

// stero controls
~p[\gated_multi].addSpec(\spread, [0.0, 1, \lin, 0.0, 1]);
~p[\gated_multi].addSpec(\center, [0.0, 1, \lin, 0.0, 0]);
~p[\gated_multi].addSpec(\pan, [-1.0, 1.0, \lin, 0.0, 0]);

// amp controls
~p[\gated_multi].addSpec(\osc1, [0.0, 1, \lin, 0.0, 1]);
~p[\gated_multi].addSpec(\osc2, [0.0, 1, \lin, 0.0, 1]);
~p[\gated_multi].addSpec(\osc3, [0.0, 1, \lin, 0.0, 1]);
~p[\gated_multi].addSpec(\amp, [0.0, 1, \lin, 0.0, 1]);

// synth controls
~p[\gated_multi].addSpec(\osc2_pregain, [1.0, 50, \lin, 0.0, 1]);
~p[\gated_multi].addSpec(\osc1_fb, [0.0, 1.0, \lin, 0, 0]);
~p[\gated_multi].addSpec(\fshift, [0.001, 1000, \lin, 0, 1]);

);

~p[\gated_multi].play(vol:1);
~p[\gated_multi].stop;
~gated_multi_win = App.guiHelper(~p[\gated_multi], "gated_multi");
~gated_multi_win.front;


/////////////////////////////////////////
// from touchosc
(
Fdef(\grid, {arg row, col, val;

	var offset = (7 * 2).neg;
	var degree = 7 * row + col + offset;
	var freq = ~freq_func.( (degree: degree, scale: Scale.dorian) );
	//[row, col, degree, freq.cpsname].postln;
	if (val == 1) {
		~p[\gated_multi].set(\gate, 1, \freq, freq);
	}{
		~p[\gated_multi].set(\gate, 0);
	}
})
)

~p[\gated_multi].set(\gate, 1, \freq, 440);
~p[\gated_multi].set(\gate, 0);

/////////////////////////////////////////
// midi note events
~keyboard.().front;
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
	~p[\gated_multi].set(\gate, 1, \freq, freq);
});
Fdef(\noteOff, {arg note;
	~p[\gated_multi].set(\gate, 0);
})
)



App.saveWorkspace("wip2");
s.stopRecording
