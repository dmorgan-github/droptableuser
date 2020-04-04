(
Ndef(\ifjog).put(0, {

	var beatdur = \beatdur.kr(1);
	var trig = \trig.tr(0);

    var osc1 = {arg freq;
		var sig = Blip.ar(freq * [0, 7, 12, 14].midiratio, SinOsc.kr(1/16).range(10, 50));
        sig * AmpCompA.kr(freq);
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

    var numvoices = 4;
    var detune = LFNoise2.kr(\drate.kr(0.1).dup(numvoices)).bipolar(\ddepth.kr(0.2)).midiratio;
    var freq = Vibrato.ar(\freq.ar(432).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0));
    var sig = osc1.(freq * detune);
	var aeg = adsr.();
    sig = LeakDC.ar(sig);
    sig = sig * aeg;
    //sig = filter.(sig, aeg);
    sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
    sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = sig.blend(NHHall.ar(sig, 5), 0.3);
	sig = RLPF.ar(sig, SinOsc.kr(1/16).range('C3'.namecps, 'C5'.namecps), 0.6);
	sig = sig.blend(NHHall.ar(sig, 5), 0.4);
	sig = LPF.ar(sig, 'C5'.namecps);
	sig = sig.blend(PitchShift.ar(sig, 4, [2, 1.5], 0.01, 0.01), 0.5);
	sig = sig.blend(NHHall.ar(sig, 10), 0.4);
	sig = sig * \amp.kr(-3.dbamp);
	sig;
})
)

(
Ndef(\ifjog).put(10, \set -> Pbind(
	\trig, 1,
	\dur, 4,
	\sus, Pkey(\dur),
	\octave, 3,
	\degree, 0,
	\fvel, 8,
	\amp, -18.dbamp
))
)

Ndef(\ifjog).play(fadeTime:10);
Ndef(\ifjog).stop;


App.recAtCommit("wip5", "6cdf88d");
s.stopRecording;