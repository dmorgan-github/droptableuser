(
SynthDef(\subtractr, {

	// support mono or poly mode
	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);
	//detuneSig = LFNoise1.kr(Rand(0.05,0.1)).bipolar(detune).midiratio;

	// bend by semitones...
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	//var freq = freqbend + [detune, detune.neg];
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));
	//var freq = Vibrato.ar([freqbend, freqbend * detuneratio], \vrate.ar(6), \vdepth.ar(0.0));

	var adsr = {
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0);
		var sus = \suslevel.kr(1);
		var rel = \rel.kr(1);
		var curve = \curve.kr(-4);
		Env.adsr(atk, dec, sus,  rel, curve: curve)
		.ar(gate:gate, doneAction:Done.freeSelf);
	};

	var filter = {arg in;
		var cutoff = \cutoff.kr(220);
		var fvel = \fvel.kr(10);
		var res = \res.kr(0.5);//.linlin(0, 1, 0, 4);
		var feg = Env.asr(
			\fatk.kr(0.01),
			\fsuslevel.kr(1),
			\frel.kr(1),
			\fcurve.kr(-4)
		).ar(gate:gate).linexp(0, 1, cutoff, cutoff * fvel).clip(20, 20000);
		//var sig = MoogVCF.ar(in, feg, res) * 2;
		//var sig = MoogFF.ar(in, feg, res.linlin(0, 1, 0, 4)) * 4;
		var sig = DFM1.ar(in, feg, res);
		//var sig = BLowPass4.ar(in, feg, res.linlin(0, 1, 1, 0.001));
		//var sig = RLPF.ar(in, feg, res.linlin(0, 1, 1, 0.001));
		sig;
	};

	var tri = {arg freq;
		var width = \triwidth.ar(0.5) + \triwidthlfo.ar(0);
		var sig = VarSaw.ar(freq, 0, width);
		var fold = \trifold.kr(1).max(1);
		sig = (sig * fold).fold(-1, 1) * fold.reciprocal.sqrt;
		sig = LeakDC.ar(sig);
		sig * AmpCompA.kr(freq, 32);
	};

	var saw = {arg freq;
		var sig = Saw.ar(freq);
		sig * AmpCompA.kr(freq, 32);
	};

	var pulse = {arg freq;
		var width = \pulsewidth.ar(0.5) + \pulsewidthlfo.ar(0);
		var sig = Pulse.ar(freq, width);
		sig = LeakDC.ar(sig);
		sig * AmpCompA.kr(freq, 32);
	};

	var sine = {arg freq;
		var skew = \sineskew.ar(0) + \sineskewlfo.ar(0);
		var sig = SinOscFB.ar(freq, skew.clip(-1, 1));
		var fold = \sinefold.kr(1).max(1);
		sig = (sig * fold).fold(-1, 1) * fold.reciprocal.sqrt.lag(0.01);
		sig = LeakDC.ar(sig);
		sig * AmpCompA.kr(freq, 32);
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

	var drive = \drive.kr(1).max(1);
	sig = Select.ar( (drive > 1), [
		sig,
		LeakDC.ar((sig * drive).softclip) * drive.sqrt.reciprocal
	]);
	sig = sig * aeg * \amp.kr(0.3) * \vel.kr(1);
	sig = filter.(sig);
	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);

}, metadata: (
	specs: (
		atk: [0, 1, \lin, 0, 0.01, "aeg"].asSpec,
		dec: [0, 1, \lin, 0, 0.2, "aeg"].asSpec,
		rel: [0, 8, \lin, 0, 0.29, "aeg"].asSpec,
		suslevel: [0, 1, \lin, 0, 1, "aeg"].asSpec,
		curve: [-8, 8, \lin, 0, -4, "aeg"].asSpec,
		ts: [0.001, 100, \lin, 0, 1, "aeg"].asSpec,

		cutoff: [20, 20000, \exp, 0, 100, "filter"].asSpec,
		fvel: [0.001, 20, \lin, 0, 10, "filter"].asSpec,
		res: [0, 1, \lin, 0, 0.5, "filter"].asSpec,
		fatk: [0, 1, \lin, 0, 0.01, "filter"].asSpec,
		frel: [0, 8, \lin, 0, 0.29, "filter"].asSpec,
		fsuslevel: [0, 1, \lin, 0, 1, "filter"].asSpec,
		fcurve: [-8, 8, \lin, 0, -4, "filter"].asSpec,

		tri: [0, 1, \lin, 0, 1, "osc1"].asSpec,
		trifreqmul: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "osc1"].asSpec,
		triwidth: [0, 1, \lin, 0, 0.5, "osc1"].asSpec,
		trifold: [1, 10, \lin, 0, 1, "osc1"].asSpec,

		saw: [0, 1, \lin, 0, 0, "osc2"].asSpec,
		sawfreqmul: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "osc2"].asSpec,

		pulse: [0, 1, \lin, 0, 0, "osc3"].asSpec,
		pulsefreqmul: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "osc3"].asSpec,
		pulsewidth: [0, 1, \lin, 0, 0.5, "osc3"].asSpec,

		sine: [0, 1, \lin, 0, 0, "osc4"].asSpec,
		sinefreqmul: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "osc4"].asSpec,
		sineskew: [-1, 1, \lin, 0, 0, "osc4"].asSpec,
		sinefold: [1, 10, \lin, 0, 1, "osc4"].asSpec,

		noise: [0, 1, \lin, 0, 0, "osc5"].asSpec,

		glis: [0, 1, \lin, 0, 0, "freq"].asSpec,
		detunehz: [0, 10, \lin, 0, 0, "freq"].asSpec,
		bend: [-12, 12, \lin, 0, 0, "freq"].asSpec, // semitones
		vrate: [0, 440, \lin, 0, 6, "freq"].asSpec,
		vdepth: [0, 1, \lin, 0, 0, "freq"].asSpec,
		spread: [0, 1, \lin, 0, 1, "stereo"].asSpec,
		center: [0, 1, \lin, 0, 0, "stereo"].asSpec,
		vel: [0, 1, \lin, 0, 1, "vol"].asSpec,
		amp: [0, 1, \lin, 0, -10.dbamp, "vol"].asSpec,
		drive: [1, 100, \lin, 0, 1, "vol"].asSpec
	)
)
).add
)

