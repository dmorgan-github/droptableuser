/////////////////////////////////////////
// bells
Ndef(\bells).clear;
Ndef(\bells).mold;
(Ndef(\bells)[0] = {

    var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).varlag(\lag.kr(0.1)), \vrate.kr(6), \vdepth.kr(0.0));

	var osc1 = {

		var fs=freq, t60=9, pitchy=1, amp=0.25;

		var exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate:trig);

		var sig = DynKlank.ar(
			`[
				[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
				[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
				[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60 // ring times
			],
			exciter,
			freqscale:fs*pitchy);
		sig;
	};

	var env = Env(
		[0,\peakLevel.kr(1),\susLevel.kr(0.5),0],
		[\atk.kr(0.01), \decay.kr(0.3), \sus.kr(1), \rel.kr(1)],
		curve:\curve.kr(-4)
	).kr(gate:trig);

	var sig = [
		osc1.()
	].sum;

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig;
});

(Ndef(\bells)[2] = \set -> Pbind(
    \trig, 1,
	\dur, Pseg(Pwhite(1/32, 1/2), Pwhite(0.1, 1), -4, inf),
	\amp,  Pseg(Pseq([0,1], inf), Pseq([4,8], inf), -4, inf) * -60.dbamp,//0.2
	\scale, Scale.minor,
	\degree, Pstutter(Prand([8,16,32], inf), Prand([0,2,5,7], inf)),
	\octave, Prand([5,6,7], inf)
));

Ndef(\bells).play(vol:1);
Ndef(\bells).stop;
Ndef(\bells).gui;


/////////////////////////////////////////
// fx1
Ndef(\fx1).clear;
(Ndef(\fx1)[0] = {
	var in = \in.ar([0,0]);
	var fx = in;// ring1: SinOsc.ar(440);
	fx = FbC({arg fb; fb * 0.3 + fx}, 3/8);
	fx;
});
Ndef(\fx1).play(vol:1);
Ndef(\fx1).stop;
Ndef(\fx1).gui;
Ndef(\fx1) <<> Ndef(\bells);

/////////////////////////////////////////
// fx2
Ndef(\fx2).clear;
(Ndef(\fx2)[0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 5, 0, SinOsc.kr(1/64).range(1, 2));
	fx;
});
Ndef(\fx2).play;
Ndef(\fx2).stop;
Ndef(\fx2).gui;

Ndef(\fx2) <<> Ndef(\fx1);

/////////////////////////////////////////
// fx3
Ndef(\fx3).clear;
(Ndef(\fx3)[0] = {
	var in = \in.ar([0,0]);
	var fx = FreqShift.ar(in, [200,-100], [0, 0.5]);
	fx = DelayC.ar(fx, 0.5, 0.5);
	fx
});
Ndef(\fx3).play;
Ndef(\fx3).stop;
Ndef(\fx3).gui;

Ndef(\fx3) <<> Ndef(\bells);

/////////////////////////////////////////
// fx4
Ndef(\fx4).clear;
(Ndef(\fx4)[0] = {
	var in = Ndef(\fx3).ar + Ndef(\bells).ar;
	var fx = in;
	fx = JPverb.ar(in, 3, 0, 3);
	fx;
});
Ndef(\fx4).play;
Ndef(\fx4).stop;
Ndef(\fx4).gui;


/////////////////////////////////////////
// fx5
Ndef(\fx5).clear;
(Ndef(\fx5)[0] = {
	var in = \in.ar([0,0]);
	var fbNode = FbNode(2, 10, 10);
	var fb = fbNode.delay(0.3);
	var sig = fb * 0.7;
	sig = PitchShift.ar(in, 0.5, SinOsc.kr(1/128).range(1.0, 2.0));
	sig = SoftClipAmp8.ar(sig, 3).tanh;
	fbNode.write(sig);
	sig;
});
Ndef(\fx5).play;
Ndef(\fx5).stop;
Ndef(\fx5).gui;

Ndef(\fx5) <<> Ndef(\fx4);

/////////////////////////////////////////
// fx6
Ndef(\fx6).clear;
(Ndef(\fx6)[0] = {
	var in = \in.ar([0,0]);
	var fx = BLowPass4.ar(in, SinOsc.kr(2).range(440, 2200), 0.5);
	fx
});
Ndef(\fx6).play;
Ndef(\fx6).stop;
Ndef(\fx6).gui;


Ndef(\fx6) <<> Ndef(\fx5);

App.saveWorkspace("beetle", rec:true);
s.stopRecording