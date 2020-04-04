TempoClock.default.tempo = 45/60;

~txefc = ~txefc ? S(\subtractr);

// delay
~txefc.fx(90, \delay);
~txefc.fbL_(0.5).fbR_(0.7);
~txefc.wet90 = 0.4;

// pitchshift
~txefc.fx(95, \pitchshift, \windowSize, 1);
~txefc.psRatioL_(2).psRatioR_(1.5);
~txefc.wet95 = 0.45;

// allpass
~txefc.fx(100, {arg in; AllpassC.ar(in, 1, 0.3, 5)});
~txefc.wet100 = 0.3;

// stereo
~txefc.fx(105, {arg in; Splay.ar(in, 0.5) });

// properties
~txefc.detunehz = 0.2;
~txefc.vdepth = 0.005;
~txefc.cutoff = 200;//{ SinOsc.ar(1/17).range(100, 150) };
~txefc.fvel = 4;//
~txefc.res = 0.3; //0.50967741935484
~txefc.tri_(1).triwidth_({ SinOsc.ar(1/11).range(0.6, 0.8) });
~txefc.saw_(0.51612903225806);
~txefc.set([\degree, \dur], [4, 2, -1, \, \, 0, \, \ ].dd );
~txefc.atk_(0.1).rel_(2);
~txefc.fatk_(0.2).frel_(2);
~txefc.octave = 4;
~txefc.harmonic = [1, 2];
~txefc.amp = 0.3;
~txefc.play(fadeTime:4, reset:true);
~txefc.stop(fadeTime:4);
~txefc.gui;


/////////////////////////////////////////
// name
(
~emum = S(\emum, {arg freq, gate;

	var mod = {arg freq, ratio=2, fb=0, index=1, ivel=1, idur=1;
		var idx = Line.ar(index, index * ivel, idur);
		var modfreq = freq * ratio;
		var sig = SinOsc.ar(modfreq) * idx;
		sig;
	};

	var car = {arg freq;
		var modfreq = freq * 2;
		var index = 2;
		var ivel = 0.1;
		var idur = \sustain.kr(1);
		var ieg = Env.asr(\atk.kr, releaseTime:\rel.kr).ar(gate:gate).linlin(0, 1, index, ivel);
		var mod = SinOsc.ar(modfreq) * ieg;
		var sig = SinOsc.ar(freq, mod);
		sig;
	};

	var sig = [
		car.( freq )
	].sum;

	sig = LeakDC.ar(sig);
	sig;
});
)

~emum.fx(90, {arg in; AllpassC.ar(in, 1, 0.5, 10)});
~emum.wet90 = 0.6;

~emum.stretch = 1;
~emum.set([\degree, \dur], [0].dd);
~emum.dur_(4)
~emum.atk = 1;
~emum.rel = 2;
~emum.degree = Pwhite(0, 4);
~emum.harmonic = [1, 2];
~emum.octave = 3;
~emum.play;
~emum.amp = 0.4;


/////////////////////////////////////////
// record
App.saveWorkspace("wip5", rec:true);
s.stopRecording;


