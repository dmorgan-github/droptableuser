(
~tf = Signal.newClear(1025).waveFill({arg x, old, i;
	sin(x)
}, -pi/2, pi/2);
~tf = ~tf.waveFill({arg x, old, i;
	old * ((cos(x*0.08) / 4) + 0.3);
}, 0, 50pi).normalize;
~tf.plot;
~tfBuf = Buffer.loadCollection(s, ~tf.asWavetableNoWrap);
)

(
Ndef(\vagolor).put(0, {

	var beatdur = \beatdur.kr(1);
	var trig = \trig.tr(0);

    var osc1 = {arg freq;

		var sig;
		var curve = LFNoise1.kr(0.5!8).bipolar(1);
		var input = LFTri.ar({freq * Rand(-0.1,0.1).midiratio * [0, 12].midiratio}!8);
		input = input.lincurve(-1, 1, -1, 1, curve);
		sig = Shaper.ar(~tfBuf, input);
        sig * AmpCompA.kr(freq)
    };

    var adsr = {arg da=Done.none;
        var atk = \atk.kr(0.001);
        var sus = \sus.kr(0);
		var dec = \dec.kr(0.1);
        var rel = \rel.kr(0.1);
        var curve = \curve.kr(-4);
		var suslevel = \suslevel.kr(0.5);
		var ts = \ts.kr(1);
		var env = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			curve
		).ar(doneAction:da, gate:trig, timeScale:ts);
        env;
    };

    var filter = {arg sig, aeg;
        var cutoff = \cutoff.kr(1000);
        var fvel = \fvel.kr(4);
        var fcurve = \fcurve.kr(0);
        var res = \res.kr(0.5);
        var feg = aeg.lincurve(0, 1, cutoff, cutoff * fvel, fcurve);
        sig = DFM1.ar(sig, feg, res);
        sig;
    };

    var numvoices = 2;
    var detune = LFNoise2.kr(\drate.kr(0.1).dup(numvoices)).bipolar(\ddepth.kr(0.2)).midiratio;
    var freq = Vibrato.ar(\freq.ar(432).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.001));
    var sig = osc1.(freq);
	var aeg = adsr.();
    sig = LeakDC.ar(sig);
    sig = sig * aeg;
    sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	sig = sig.blend(JPverb.ar(sig.reverse, 5, 0, 5), 0.4);
    sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = LPF.ar(sig, 440);
	sig = sig * \amp.kr(-3.dbamp);
	Splay.ar(sig.flatten);
});

Ndef(\ivqec).put(0, {

	var beatdur = \beatdur.kr(1);
	var trig = \trig.tr(0);

    var osc1 = {arg freq;
		var mod2 = SinOsc.ar(freq * 3, 0, 0.2);
		var mod = SinOsc.ar(freq * [2, 4], mod2.mod(2pi)) * SinOsc.kr(SinOsc.kr(1/16).range(1/8, 1)).range(0.1, 3);
		var sig = SinOsc.ar(freq * [0, 7].midiratio, mod.mod(2pi));
		Splay.ar(sig) * AmpCompA.kr(freq);
    };

    var adsr = {arg da=Done.none;
        var atk = \atk.kr(0.001);
        var sus = \sus.kr(0);
		var dec = \dec.kr(0.1);
        var rel = \rel.kr(0.1);
        var curve = \curve.kr(-4);
		var suslevel = \suslevel.kr(0.5);
		var ts = \ts.kr(1);
		var env = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			curve
		).ar(doneAction:da, gate:trig, timeScale:ts);
        env;
    };

    var numvoices = 2;
    var detune = LFNoise2.kr(\drate.kr(0.1).dup(numvoices)).bipolar(\ddepth.kr(0.2)).midiratio;
    var freq = Vibrato.ar(\freq.ar(432).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.001));
    var sig = osc1.(freq);
	var aeg = adsr.();
    sig = LeakDC.ar(sig);
    sig = sig * aeg;
    sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0));
	sig = sig.blend(JPverb.ar(sig.reverse, 5, 0, 5), 0.4);
	sig = sig.blend(AllpassC.ar(sig, 1, 3/4, [5, 3]), 0.3);
    sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = LPF.ar(sig, 440);
	sig = sig * \amp.kr(-3.dbamp);
	Splay.ar(sig.flatten);
})
)


(
Pdef(\vagolor, {
	var node = Ndef(\vagolor);
	if (node.isMonitoring.not) {
		node.play;
	};

	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\freq, \trig, \sus, \rel, \amp],
		\trig, 1,
		\mtranspose, Pseq([0, 5], inf).stutter(20),
		\degree, Pseq([0, \, 2, 3, \,\,\,\], inf),
		\dur, (1/2) * 2,
		\sus, Pkey(\dur),
		\rel, 1,
		\octave, 5,
		\amp, -11.dbamp * 2
	)
});

Pdef(\ivqec, {

	var node = Ndef(\ivqec);
	if (node.isMonitoring.not) {
		node.play;
	};

	Pbind(
		\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\freq, \trig, \sus, \rel, \amp],
		\trig, 1,
		\mtranspose, Pseq([0, -2], inf).stutter(20),
		\degree, Pseq([-5, \, 4, \, 6, \,\,\,\,\], inf),
		\dur, (1/5) * 2,
		\sus, Pkey(\dur),
		\rel, 1,
		\octave, 6,
		\amp, -3.dbamp * 2
	)
});
)

(
Pdef(\a, Ppar(
	[
		Pdef(\vagolor),
		Pdef(\ivqec)
	]
))
)

Pdef(\a).play(doReset:true);
Pdef(\a).stop;


App.recAtCommit("wip5", "568da71");
Pdef(\a).play;
s.stopRecording;




