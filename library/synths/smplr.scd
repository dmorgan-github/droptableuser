/*
review: https://github.com/itsyourbedtime/takt/blob/master/lib/Engine_Timber_Takt.sc
*/

(
var func = {arg numchannels = 2;

	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	//var detune = \detunehz.kr(0.6) * PinkNoise.ar.range(0.8, 1.2);
	var detuneratio = \detuneratio.kr(1) * PinkNoise.ar(0.007).range(0.9, 1.1);
	var ctrllag = 0.005;
	var debug = \debug.kr(0);
	var detected, hasFreq;
	var buf = \buf.kr(0);
	var numframes = BufFrames.kr(buf);
	var root = \root.kr(0).midiratio;
	var base = \basefreq.kr(261) * root;

	// bend by semitones...
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	//var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));
	var freq = Vibrato.ar([freqbend, freqbend * detuneratio], \vrate.ar(6), \vdepth.ar(0.0));

	// either constant pitch
	// or keytrack
	var freqmode = \freqmode.kr(0);
	var rate = Select.kr(freqmode, [1, freq/base]);
	var start = \start.kr(0).lag(0.001) * BufFrames.kr(buf);
	var rev = \rev.kr(0);
	var loop = \loop.kr(0);
	var dir = TWChoose.kr(trig, [-1, 1], [rev, 1-rev]);
	var sig = PlayBufCF.ar(numchannels, buf, BufRateScale.kr(buf) * rate * dir, 1, start, loop);

	var adsr = {
		var da = Done.none;
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0.1);
		var rel = \rel.kr(0.1);
		var suslevel = \suslevel.kr(1);
		var ts = \ts.kr(1);
		var atkcurve = \atkcurve.kr(-4);
		var deccurve = \deccurve.kr(-4);
		var relcurve = \relcurve.kr(-4);
		var env = Env.adsr(
			attackTime:atk, decayTime:dec, sustainLevel:suslevel, releaseTime:rel,
			curve:[atkcurve, deccurve, relcurve]
		);
		var aeg = env.kr(doneAction:da, gate:gate, timeScale:ts);
		aeg = aeg * \aeglfo.kr(1);
		// control life cycle of synth
		env.kr(doneAction:Done.freeSelf, gate:\gate.kr, timeScale:ts);

		aeg;
	};

	# detected, hasFreq = Tartini.kr(sig);
	Poll.kr(Impulse.kr(10) * debug, detected, \samplr_freq);
	sig = LeakDC.ar(sig);
	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.3) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);
};

var specs = (
	root: ControlSpec(-12, 12, \lin, 1, 0),
	glis: ControlSpec(0, 1, \lin, 0, 0),
	loop: ControlSpec(0, 1, \lin, 1, 1),
	freqmode: ControlSpec(0, 1, \lin, 1, 0),
	rev: ControlSpec(0, 1, \lin, 1, 0),
	start: ControlSpec(0, 1, \lin, 0, 0),
	rate: ControlSpec(0.1, 4.0, \lin, 0, 1),
	sat: ControlSpec(1, 100, \lin, 0, 1, "dist")
);

SynthDef(\smplr_2chan, {
	func.(2)
}, metadata: (
	specs: specs
)).add;

SynthDef(\smplr_1chan, {
	func.(1)
}, metadata: (
	specs: specs
)).add;
)