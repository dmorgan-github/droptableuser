(
Library.put(\voices, \benjolin, {

	/*
	https://scsynth.org/t/benjolin-inspired-instrument/1074

	Instrument inspired from Rob Hordijk's Benjolin, it requires sc3-plugins (PulseDPW, SVF and DFM1)

	outSignal:
	1-triangle osc1,
	2-square osc1,
	3-triangle osc2,
	4-pulse osc2,
	5-XOR output,
	6-Filter output

	Enjoy! Alejandro Olarte

	// add ranges for controlling with a GUI
	(
	Spec.add(\freq1, ControlSpec( 20.0, 14000.0, \exp, 0, 70, "Hz") );
	Spec.add(\freq2, ControlSpec( 0.1, 14000.0, \exp, 0, 4, "Hz") );
	Spec.add(\filtFreq, ControlSpec( 20.0, 20000.0, \exp, 0, 40, "Hz") );
	Spec.add(\q, ControlSpec( 0.0, 1.0, \lin, 0, 0.82) );
	Spec.add(\gain, ControlSpec( 0.0, 3.0, \lin, 0, 1) );
	Spec.add(\filterType, ControlSpec( 0.0, 3.0, \lin, 1, 0) );
	Spec.add(\rungler1, ControlSpec( 0.0, 1.0, \lin, 0, 0.16) );
	Spec.add(\rungler2, ControlSpec( 0.0, 1.0, \lin, 0, 0) );
	Spec.add(\runglerFilt, ControlSpec( 0.0, 1.0, \lin, 0, 9) );
	Spec.add(\loop, ControlSpec( 0.0, 1.0, \lin, 0, 1) );
	Spec.add(\scale, ControlSpec( 0.0, 1.0, \lin, 0, 1) );
	Spec.add(\outSignal, ControlSpec( 0.0, 6.0, \lin, 1, 6) );
	);
	*/

	{
		var freq1 = \freq1.kr(40);
		var freq2 = \freq2.kr(4);
		var scale = \scale.kr(1);
		var rungler1 = \rungler1.kr(0.16);
		var rungler2 = \rungler2.kr(0.0);
		var runglerFilt = \runglerFilt.kr(9);
		var loop = \loop.kr(0);
		var filtFreq = \filtFreq.kr(40);
		var q = \q.kr(0.82);
		var gain = \gain.kr(1);
		var filterType = \filterType.kr(0);
		var outSignal = \outSignal.kr(6);
		var amp = \amp.kr(1);

		var osc1, osc2, tri1, tri2, sh0, sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8=1, rungler, pwm, filt, output;
		var sr;
		var osc2freq, buf, bufR;

		bufR = LocalIn.ar(2,0);
		rungler = bufR.at(0);
		buf = bufR.at(1);

		sr = SampleDur.ir;
		//sr = ControlDur.ir;
		tri1 = LFTri.ar((rungler*rungler1)+freq1);
		tri2 = LFTri.ar((rungler*rungler2)+freq2);
		osc1 = PulseDPW.ar((rungler*rungler1)+freq1);
		osc2 = PulseDPW.ar((rungler*rungler2)+freq2);

		//pwm = tri1 > tri2;
		pwm = BinaryOpUGen('>', (tri1 + tri2),(0));

		osc1 = ((buf*loop)+(osc1* (loop* -1 +1)));
		sh0 = BinaryOpUGen('>', osc1, 0.5);
		sh0 = BinaryOpUGen('==', (sh8 > sh0), (sh8 < sh0));
		sh0 = (sh0 * -1) + 1;

		sh1 = DelayN.ar(Latch.ar(sh0,osc2),0.01,sr);
		sh2 = DelayN.ar(Latch.ar(sh1,osc2),0.01,sr*2);
		sh3 = DelayN.ar(Latch.ar(sh2,osc2),0.01,sr*3);
		sh4 = DelayN.ar(Latch.ar(sh3,osc2),0.01,sr*4);
		sh5 = DelayN.ar(Latch.ar(sh4,osc2),0.01,sr*5);
		sh6 = DelayN.ar(Latch.ar(sh5,osc2),0.01,sr*6);
		sh7 = DelayN.ar(Latch.ar(sh6,osc2),0.01,sr*7);
		sh8 = DelayN.ar(Latch.ar(sh7,osc2),0.01,sr*8);

		//rungler = ((sh6/8)+(sh7/4)+(sh8/2)); //original circuit
		//rungler = ((sh5/16)+(sh6/8)+(sh7/4)+(sh8/2));

		rungler = ((sh1/2.pow(8))+(sh2/2.pow(7))+(sh3/2.pow(6))+(sh4/2.pow(5))+(sh5/2.pow(4))+(sh6/2.pow(3))+(sh7/2.pow(2))+(sh8/2.pow(1)));

		buf = rungler;
		rungler = (rungler * scale.linlin(0,1,0,127));
		rungler = rungler.midicps;

		LocalOut.ar([rungler,buf]);

		filt = Select.ar(filterType, [
			RLPF.ar(pwm,(rungler*runglerFilt)+filtFreq,q* -1 +1,gain),
			//BMoog.ar(pwm,(rungler*runglerFilt)+filtFreq,q,0,gain),
			RHPF.ar(pwm,(rungler*runglerFilt)+filtFreq,q* -1 +1,gain),
			SVF.ar(pwm,(rungler*runglerFilt)+filtFreq,q,1,0,0,0,0,gain),
			DFM1.ar(pwm,(rungler*runglerFilt)+filtFreq,q,gain,1)
		]);

		output = Select.ar(outSignal, [
			tri1, osc1, tri2, osc2, pwm, sh0, filt

		]);

		LeakDC.ar(output) * amp ! 2
	}
});

Library.put(\voices, \warp, {arg cb={arg sig; sig};

	{
		var sig = Warp0.ar(numChannels: 1,
			buffer: \buf.kr(0),
			warpFactor: \warp.kr(10).reciprocal,
			freqScale: ([0, 5, 7]).midiratio,
			windowSize: \windowsize.kr(0.2),
			envbufnum: -1,
			overlaps: \overlaps.kr(10),
			windowRandRatio: \winrandrate.kr(0.1),
			interp: 4);

		sig = 4.collect({
			AllpassC.ar(sig, 0.2, rrand(0.1, 0.2), rrand(1.0, 2.0));
		}).flatten;

		// not sure how to get rid of some of the artifacts
		// need some eq
		sig = LeakDC.ar(sig);
		sig = HPF.ar(sig, 80);
		sig = CompanderD.ar(in: sig,
			thresh: 0.7,
			slopeBelow: 1,
			slopeAbove: 0.4,
			clampTime: 0.008,
			relaxTime: 0.2);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});

Library.put(\voices, \swarm, {arg cb={arg sig; sig};

	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var mul = [0.5, 1, 2, 1.5, 1.12, 1.33];
		var sig = 50.collect({arg num;
			var detune = LFNoise1.kr(0.1).bipolar(0.2).midiratio;
			VarSaw.ar(freq * detune * mul.choose, 0,
				width:LFNoise1.kr(1).range(0.1, 0.9))
			* Env.circle([0, 1, 0], [rrand(1, 24), rrand(10, 50)], rrand(-4, 4)).kr();
		});

		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});

Library.put(\voices, \grainer, {arg cb={arg sig; sig}, numchannels=2;
	"numchannels %".format(numchannels).debug(\grainer);
	{
		var buf = \buf.kr(0);
		var trig = \trig.kr(0);
		var pos = \pos.kr(0);
		var graindur = \graindur.kr(0.5);
		var rate = \rate.kr(1);
		var envbuf = \envbuf.kr(-1).lag(0.01);
		var pan = \grainpan.kr(0);
		var grainamp = \grainamp.kr(1);
		var loop = \loop.kr(1);

		var amp = Dwhite(grainamp.clip(0,1), 1, inf);
		var panValue = Dwhite(pan.neg, pan, inf);
		var reverse = \reverse.kr(0);
		var rev = Dwrand([-1,1], [reverse,1-reverse], inf);

		var sig = GrainBufJ.ar(numchannels,
			trig,
			dur: graindur,
			sndbuf: buf,
			rate: rate * rev,
			pos: pos,
			loop: loop,
			interp: 4,
			grainAmp: amp,
			pan: panValue,
			envbufnum: envbuf
		);

		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0)) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	};
});

Library.put(\voices, \formlet, {arg cb={arg sig; sig}, numvoices=2;
	"numvoices %".format(numvoices).debug(\osc);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(0.001);
		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr({rrand(0.05, 0.2)}.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var which = \which.kr(0);
		var focus = \focus.kr(1);
		var atk = \atk.kr(0.01);
		var decay = \dec.kr(1);
		var noise = SelectXFocus.kr(which,
			[WhiteNoise.ar(1), BrownNoise.ar(1), PinkNoise.ar(1)],
			focus,
			wrap:true);

		var ex = Latch.ar(noise, Trig1.kr(trig, sus));
		var sig = Formlet.ar(ex, freq * detune, atk, decay);
		sig = cb.(sig);
		sig = LeakDC.ar(Limiter.ar(sig, 0.8)) * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-12.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});

Library.put(\voices, \osc, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\osc);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
        ).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr({rrand(0.05, 0.2)}.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var sig = Osc.ar(\buf.kr(0), freq * detune, \phase.ar(0).mod(2pi));

		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \varsaw, {arg cb={arg sig; sig}, numvoices=2;
	"numvoices %".format(numvoices).debug(\varsaw);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var width = \width.kr(0.5);
		var sig = VarSaw.ar(freq * detune, width:width);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \pulse, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\pulse);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var width = \width.kr(0.5);
		var sig = Pulse.ar(freq * detune, width:width);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \sine, {arg cb={arg sig; sig}, numvoices=2;
	"numvoices %".format(numvoices).debug(\sine);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var sig = SinOsc.ar(freq * detune, \phase.ar([0,0]).mod(2pi));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});

Library.put(\voices, \percsine, {arg cb={arg sig; sig}, poly=0, doneAction=Done.none, numvoices=2;
	"numvoices %".format(numvoices).debug(\percsine);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		// gate has to be initialized as 1 to work with polyphonic Pbinds
		var glide = \gate.kr(poly);
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1), doneAction:doneAction);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var sig = SinOsc.ar(freq * detune * Env([1.5,1.5,1],[0,0.001], -4).kr(gate:trig), trig);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});

Library.put(\voices, \saw, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\saw);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var sig = Saw.ar(freq * detune);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \klang, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\klang);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var sig = DynKlang.ar(
			`[
				[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
				[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
				[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
			],
			freq * detune
		);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \sinoscfb, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\sinoscfb);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var sig = SinOscFB.ar(freq * detune, \feedback.kr(0));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \klank, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\klank);
	{
		var trig = \trig.tr;
		var which = \which.kr(0);
		var focus = \focus.kr(1);
		var noise = SelectXFocus.kr(which,
			[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
			focus,
			wrap:true);

		var in = noise * Decay2.kr(trig, \atk.kr(0.01), \decay.kr(1));
		var numFreqs = 6;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432).varlag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var ffreqs = (0..numFreqs-1).collect({arg i;
			(\f ++ i).asSymbol.kr(1);
		}) + detune;

		var amps = (0..numFreqs-1).collect({arg i;
			(\a ++ i).asSymbol.kr(1/numFreqs);
		});

		var rings = (0..numFreqs-1).collect({arg i;
			(\r ++ i).asSymbol.kr(1);
		});

		var sig = DynKlank.ar(`[ffreqs, amps, rings], in, freq * detune);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-12.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \res, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\res);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0), delay:\vdelay.kr(0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var res = \res.kr(0.1);
		var sig = LeakDC.ar(RLPF.ar(PinkNoise.ar(0.3), freq * detune, res));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \syncsaw, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\syncsaw);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var sig = SyncSaw.ar(freq * detune, freq * \sync.kr(1.5));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \fm7, {arg overlap=2, cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;

		// rudimentary voice stealing, round robin
		var index = Stepper.kr(trig, 0, 0, overlap-1);
		var trigs = overlap.collect({arg i;
			InRange.kr(index, i-0.5, i+0.5);
		});

		var gate = Trig1.kr(trigs, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;

		var ctrls = Array.fill(6, {arg i;
			[freq * ('r' ++ i).asSymbol.kr(1), 0, ('c' ++ i).asSymbol.kr(0).lag(0.01)]
		});

		var mods = Array.fill2D(6, 6, {arg r, c;
			var key = ('m' ++ '_' ++ r ++ '_' ++ c);
			key.asSymbol.kr(0).lag(0.01);
		});

		var sig = FM7.ar(ctrls, mods) * (0..5).collect({arg i; ('chan' ++ i).asSymbol.kr(0)});
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * AmpCompA.kr(freq) * env * \vel.kr(1) * \amp.kr(-6.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \noise, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var noises = [
			WhiteNoise.ar,
			PinkNoise.ar,
			BrownNoise.ar,
			GrayNoise.ar
		];

		var sig = SelectXFocus.ar(\which.kr(0), noises, \focus.kr(1));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \pluck, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\pluck);
	{
		var which = \which.kr(2);
		var focus = \focus.kr(1);
		var noise = SelectXFocus.kr(
			which,
			[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
			focus,
			wrap:true
		);

		var trig = \trig.tr;
		var freqmul = \freqmul.kr(1).clip(0.1, 20);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0))), \vrate.kr(6), \vdepth.kr(0.001)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;
		var temp = freq * detune;
		var sig = Pluck.ar(RLPF.ar(noise, \nfreq.kr(20000), \nres.kr(0).linlin(0, 1, 1, 0.00001)),
			trig:trig,
			maxdelaytime:100.reciprocal,
			delaytime:temp.reciprocal,
			decaytime:\decay.kr(1),
			coef:\coef.kr(0.5)
		);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-6.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});

Library.put(\voices, \fm, {arg cb={arg sig; sig}, numvoices=4;
	"numvoices %".format(numvoices).debug(\fm);
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.1),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(0.3),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate, timeScale:\ts.kr(1));

		var index = \index.kr(1);
		var ivel = \ivel.kr(1);
		var isuslevel = \isuslevel.kr(0.5);
		var ienv = Env(
			[1, ivel, ivel * isuslevel, ivel * isuslevel, 1],
			[\iatk.kr(0.01), \idec.kr(0.1), \isus.kr(1), \irel.kr(1)],
			[\icurve1.kr(-4), \icurve2.kr(-4), \icurve3.kr(-4)]
		).kr(gate:trig) * index;

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = LFNoise1.kr(0.1.dup(numvoices)).bipolar(\dtune.kr(0.1)).midiratio;

		//modulator/carrier
		var mratio = \mratio.kr(1);
		var mod = SinOscFB.ar(freq * mratio, \feedback.kr(0)) * freq * mratio * ienv;
		var sig = SinOsc.ar(freq * detune + mod);

		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
Library.put(\voices, \playbuf, {arg numchannels=2, cb={arg sig; sig};
	"numchannels %".format(numchannels).debug(\playbuf);
	{
		var trig = \trig.tr;
		var buf = \buf.kr(0);
		var frames = BufFrames.kr(buf);
		var start = \start.kr(0) * frames;
		var rate = BufRateScale.kr(buf) * \rate.kr(1) * \dir.kr(1);
		var loop = \loop.kr(0);
		var suslevel = \suslevel.kr(1);
		var atk = \atk.kr(0);
		var sus = \sus.kr(1);
		var rel = \rel.kr(0.1);
		var curve = \curve.kr(-1);

		var env = Env(
			[0, suslevel, suslevel, 0],
			[atk, sus, rel],
			curve
		).kr(gate:trig, timeScale:\ts.kr(1));

		var sig = PlayBufCF.ar(numchannels, bufnum:buf, rate:rate, trigger:trig, startPos:start, loop:loop, lag:0.01, n:2);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * \vel.kr(1) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
		sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
		sig;
	}
});
)