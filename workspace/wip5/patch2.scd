(
Ndef(\qxeuv)[0] = {

	var trig = \trig.tr(0);

    var saw = {arg freq;
        var sig = Saw.ar(freq);
        sig;
    };

	var noise = {arg freq;
		var sig = PinkNoise.ar();
		BPF.ar(sig, freq, 0.001) * 20.dbamp;
	};

    var adsr = {arg trig, da=Done.none;
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
        var fcurve = \fcurve.kr(-4);
		var res = \res.kr(0.5);
        var feg = aeg.lincurve(0, 1, cutoff, cutoff * fvel, fcurve);
        sig = DFM1.ar(sig, feg, res);
        sig;
    };

	var sat = {arg sig, gain = 1;
		(sig * gain).tanh;
	};

	var compress = {arg sig;
		CompanderD.ar(in: sig, thresh: 0.7, slopeBelow: 1, slopeAbove: 0.4, clampTime: 0.008, relaxTime: 0.2);
	};

    var numvoices = 4;
    var detune = LFNoise2.kr(\drate.kr(0.1).dup(numvoices)).bipolar(\ddepth.kr(0.2)).midiratio;
    var freq = Vibrato.ar(\freq.ar(432).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0));
	var sig = [
		saw.(freq * detune) * 0.5,
		saw.(freq * detune * 1.5) * 0.15,
		saw.(freq * detune * 4) * 0.05,
		saw.(freq * detune * 0.5) * 0.5,
		noise.(freq * detune * 5.1),
	].sum;
	var aeg = adsr.(trig);
    sig = LeakDC.ar(sig);
    sig = sig * aeg;
    sig = filter.(sig, aeg);
	sig = sat.(sig, 1.2);
    sig = Splay.ar(sig);
	sig = sig.blend(NHHall.ar(sig, 3), 0.1);
	sig = sig.blend(AllpassC.ar(sig.reverse, 3/4, [3/4, 5/8], [5,3]), 0.3);
	sig = compress.(sig);
	sig = Splay.ar(sig, \spread.kr(0.5), center:\center.kr(0)) * \amp.kr(-3.dbamp);
	sig;//.softclip;
};
)

(
Ndef(\qxeuv)[10] = \set -> Pbind(
	\trig, 1,

	// freq
	\root, 4,
	\octave, Pbjorklund(3, 5).linlin(0, 1, 5, 6),
	\scale, Scale.chromatic.tuning_(\just),
	\degree, Pseq([0, 5, Pseq([2,3], 1), Pseq([7, 10], 1)], inf),

	// filter
	\cutoff, 1000,
	\fvel, Pwhite(4.0, 5.0),
	\fcurve, 4,//Pwhite(-4.0, 4.0),

	// amp
	\dur, 0.25,
	\dec, 0.2,
	\curve, -4, //Pwhite(-4.0, 4.0)
	\amp, Pbjorklund(5, 8).linlin(0, 1, 0.7, 1) * -20.dbamp,

	\foo, Pseries(0, 1, inf).mod(4).linlin(0, 4, -4.0, 4.0)
);
)

Ndef(\qxeuv).quant_(1.0);
Ndef(\qxeuv).play;
Ndef(\qxeuv).stop(fadeTime:4);

App.saveWorkspace("patches2", rec:true);
Ndef(\qxeuv).play;

s.stopRecording;