/*
review: https://github.com/itsyourbedtime/takt/blob/master/lib/Engine_Timber_Takt.sc
*/

(
var func = {arg numchannels = 2;

	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar.range(0.8, 1.2);
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
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

	// either constant pitch
	// or keytrack
	var freqmode = \freqmode.kr(0);
	var rate = Select.kr(freqmode, [1, freq/base]);
	var start = \start.kr(0).lag(0.001) * BufFrames.kr(buf);
	var rev = \rev.kr(0);
	var loop = \loop.kr(0);
	var dir = TWChoose.kr(trig, [-1, 1], [rev, 1-rev]);
	var sig = PlayBufCF.ar(numchannels, buf, BufRateScale.kr(buf) * rate * dir, trig, start, loop);

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

	/*
	var filter = {arg sig;
		var famt = \freqamt.kr(0).lag(ctrllag);
		var ffreq = \cutoff.kr(100).lag(ctrllag) + (freq * famt);
		var fvel = max(\fvel.kr(10).lag(ctrllag), 0.001);
		var fres = 1-\res.kr(0.5).lag(ctrllag);

		var f1, f2;
		var fatk = \fatk.kr(0.01).lag(ctrllag);
		var fdec = \fdec.kr(0.21).lag(ctrllag);
		var fsuslevel = \fsuslevel.kr(1).lag(ctrllag);
		var frel = \frel.kr(0.1).lag(ctrllag);
		var atkcurve = \fatkcurve.kr(-4).lag(ctrllag);
		var deccurve = \fdeccurve.kr(-4).lag(ctrllag);
		var relcurve = \frelcurve.kr(-4).lag(ctrllag);
		var ts = \fts.kr(1).lag(ctrllag);
		var feg = Env(
			[0, 1, fsuslevel, 0],
			[fatk, fdec, frel],
			[atkcurve, deccurve, relcurve],
			releaseNode:2
		).ar(gate:gate, timeScale:ts)
		.linlin(0, 1, ffreq, ffreq * fvel);

		feg = feg * \feglfo.kr(1);
		feg = feg.clip(20, 20000);
		sig = RLPF.ar(sig, feg, fres.clip(0.001, 1.0));
		sig;
	};
	*/

	# detected, hasFreq = Tartini.kr(sig);
	Poll.kr(Impulse.kr(10) * debug, detected, \samplr_freq);

	//sig = filter.(sig);
	sig = LeakDC.ar(sig);
	sig = sig * adsr.() * AmpCompA.kr(freq) * \vel.kr(1);
	sig = sig * \amp.kr(-3.dbamp);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	Out.ar(\out.kr(0), sig);
};

var specs = (
	\root: ControlSpec(-12, 12, \lin, 1, 0),
	\glis: ControlSpec(0, 1, \lin, 0, 0),
	\loop: ControlSpec(0, 1, \lin, 1, 1),
	\freqmode: ControlSpec(0, 1, \lin, 1, 0),
	\rev: ControlSpec(0, 1, \lin, 1, 0),
	\start: ControlSpec(0, 1, \lin, 0, 0),
	\rate: ControlSpec(0.1, 4.0, \lin, 0, 1)
);

SynthDef(\smplr_2chan, {
	func.(2)
}, metadata: (
	\specs: specs
)).add;

SynthDef(\smplr_1chan, {
	func.(1)
}, metadata: (
	\specs: specs
)).add;
)