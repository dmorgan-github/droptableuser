(
SynthDef(\subtractr, {

	// TODO:
	// https://github.com/markwheeler/passersby/blob/master/lib/Engine_Passersby.sc
	// https://github.com/markwheeler/molly_the_poly/blob/master/lib/Engine_MollyThePoly.sc
	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar.range(0.8, 1.2);
	var ctrllag = 0.005;

	// bend by semitones...
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

	var adsr = {
		var da = Done.none;
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0.1);
		var rel = \rel.kr(0.1);
		var suslevel = \suslevel.kr(0.5);
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

	var filter = {arg sig;
		var famt = \freqamt.kr(0).lag(ctrllag);
		var ffreq = \cutoff.kr(100).lag(ctrllag) + (freq * famt);
		var fvel = max(\fvel.kr(10).lag(ctrllag), 0.001);
		var fres = \res.kr(0.5).lag(ctrllag);

		var f1, f2;
		var which = \fwhich.kr(0).lag(ctrllag);
		var focus = \ffocus.kr(1).lag(ctrllag);
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
		f1 = MoogFF.ar(sig, feg, fres.linlin(0, 1, 0.001, 4)) * 4;
		f2 = DFM1.ar(sig, feg, fres.clip(0.001, 1.0));
		sig = SelectXFocus.ar(which, [f1, f2], focus);
		sig;
	};

	var tri = {arg freq;
		var width = \triwidth.ar(0.5) + (\triwidth.ar * \triwidthlfo.ar(0));
		var sig = VarSaw.ar(freq, 0, width);
		var fold = \trifold.kr(1);
		sig = (sig * fold).fold(-1, 1) * fold.reciprocal.sqrt;
		sig = LeakDC.ar(sig);
		sig * AmpCompA.kr(freq) * 1.5;
	};

	var saw = {arg freq;
		var sync = \sawsync.ar(1);
		var sig = SyncSaw.ar(freq, freq * sync);
		sig * AmpCompA.kr(freq);
	};

	var pulse = {arg freq;
		var width = \pulsewidth.ar(0.5) + (\pulsewidth.ar * \pulsewidthlfo.ar(0));
		var sig = Pulse.ar(freq, width);
		sig * AmpCompA.kr(freq);
	};

	var sine = {arg freq;
		//var mod = fm.(freq) * \sinefm.kr(0);
		var skew = \sineskew.ar(0) + (\sineskew.ar * \sineskewlfo.ar(0));
		var sig = SinOscFB.ar(freq, skew.clip(-1, 1));
		var fold = \sinefold.kr(1);
		sig = (sig * fold).fold(-1, 1) * fold.reciprocal.sqrt;
		sig = LeakDC.ar(sig);
		sig * AmpCompA.kr(freq);
	};

	var noise = {
		var sig = PinkNoise.ar;
		sig;
	};

	var aeg = adsr.();

	var vols = [\tri.kr(1), \saw.kr(0), \pulse.kr(0), \sine.kr(0)].normalizeSum.max(0);

	var sig = [
		tri.(freq * \trifreqmul.kr(1)) * vols[0],
		saw.(freq * \sawfreqmul.kr(1)) * vols[1],
		pulse.(freq * \pulsefreqmul.kr(1)) * vols[2],
		sine.(freq * \sinefreqmul.kr(1)) * vols[3],
		noise.() * \noise.kr(0)
	].sum;

	sig = LeakDC.ar(sig);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));

	sig = filter.(sig);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = sig * aeg * \vel.kr(1);
	sig = sig * \amp.kr(-10.dbamp);
	Out.ar(\out.kr(0), sig.softclip);

}, metadata: (
	specs: (
		atk: [0, 1, \lin, 0, 0.01, "aeg"].asSpec,
		dec: [0, 1, \lin, 0, 0.2, "aeg"].asSpec,
		rel: [0, 8, \lin, 0, 0.29, "aeg"].asSpec,
		suslevel: [0, 1, \lin, 0, 0.7, "aeg"].asSpec,
		atkcurve: [-8, 8, \lin, 0, -4, "aeg"].asSpec,
		deccurve: [-8, 8, \lin, 0, -4, "aeg"].asSpec,
		relcurve: [-8, 8, \lin, 0, -4, "aeg"].asSpec,
		ts: [0.001, 100, \lin, 0, 1, "aeg"].asSpec,

		\cutoff: [20, 20000, \exp, 0, 100, "filter"].asSpec,
		\fvel: [0.001, 20, \lin, 0, 10, "filter"].asSpec,
		\res: [0, 1, \lin, 0, 0.5, "filter"].asSpec,
		\fwhich: [0, 1, \lin, 0, 0, "filter"].asSpec,
		\ffocus: [0, 1, \lin, 0, 1, "filter"].asSpec,
		\freqamt: [0, 4, \lin, 0, 0, "filter"].asSpec,

		\fatk: [0, 1, \lin, 0, 0.01, "feg"].asSpec,
		\fdec: [0, 1, \lin, 0, 0.2, "feg"].asSpec,
		\frel: [0, 8, \lin, 0, 0.29, "feg"].asSpec,
		\fsuslevel: [0, 1, \lin, 0, 1, "feg"].asSpec,
		\fatkcurve: [-8, 8, \lin, 0, -4, "feg"].asSpec,
		\fdeccurve: [-8, 8, \lin, 0, -4, "feg"].asSpec,
		\frelcurve: [-8, 8, \lin, 0, -4, "feg"].asSpec,
		\fts: [0.001, 100, \lin, 0, 1, "feg"].asSpec,

		\tri: [0, 1, \lin, 0, 1, "osc1"].asSpec,
		\trifreqmul: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "osc1"].asSpec,
		\triwidth: [0, 1, \lin, 0, 0.5, "osc1"].asSpec,
		\trifold: [1, 10, \lin, 0, 1, "osc1"].asSpec,

		\saw: [0, 1, \lin, 0, 0, "osc2"].asSpec,
		\sawfreqmul: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "osc2"].asSpec,
		\sawsync: [1, 5, \lin, 0, 1, "osc2"].asSpec,

		\pulse: [0, 1, \lin, 0, 0, "osc3"].asSpec,
		\pulsefreqmul: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "osc3"].asSpec,
		\pulsewidth: [0, 1, \lin, 0, 0.5, "osc3"].asSpec,

		\sine: [0, 1, \lin, 0, 0, "osc4"].asSpec,
		\sinefreqmul: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "osc4"].asSpec,
		\sineskew: [-1, 1, \lin, 0, 0, "osc4"].asSpec,
		\sinefold: [1, 10, \lin, 0, 1, "osc4"].asSpec,

		\noise: [0, 1, \lin, 0, 0, "osc5"].asSpec,

		\glis: [0, 1, \lin, 0, 0, "freq"].asSpec,
		\detunehz: [0, 10, \lin, 0, 0, "freq"].asSpec,
		\bend: [-12, 12, \lin, 0, 0, "freq"].asSpec, // semitones
		\vrate: [0, 440, \lin, 0, 6, "freq"].asSpec,
		\vdepth: [0, 1, \lin, 0, 0, "freq"].asSpec,
		\spread: [0, 1, \lin, 0, 1, "stereo"].asSpec,
		\center: [0, 1, \lin, 0, 0, "stereo"].asSpec,
		\pan: [-1, 1, \lin, 0, 0, "stereo"].asSpec,
		\vel: [0, 1, \lin, 0, 1, "vol"].asSpec,
		\amp: [0, 1, \lin, 0, -10.dbamp, "vol"].asSpec
	)
)
).add
)

