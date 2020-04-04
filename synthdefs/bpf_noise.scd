(
SynthDef(\bpf_noise, {

	// TODO:
	// https://github.com/markwheeler/passersby/blob/master/lib/Engine_Passersby.sc
	// https://github.com/markwheeler/molly_the_poly/blob/master/lib/Engine_MollyThePoly.sc
	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar.range(0.8, 1.2);

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

	var osc1 = {arg freq;
		var sig = WhiteNoise.ar;
		var rq = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var vol_comp = (rq ** -1) * (400 / freq ** 0.5);
		sig = BBandPass.ar(sig, freq, rq);
		sig * vol_comp;
	};

	var filter = {arg sig;
		LPF.ar(sig, \lpf.kr(880));
	};

	var aeg = adsr.();

	var sig = [
		osc1.(freq)
	].sum;

	sig = sig * aeg * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	sig = LeakDC.ar(sig);

	sig = filter.(sig);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = sig * \amp.kr(-3.dbamp);
	Out.ar(\out.kr(0), sig);
}).add;
)