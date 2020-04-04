TempoClock.default.tempo = 55/60;

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
~txefc.stretch = 1;
~txefc.set([\degree, \dur], [4, 2, -1, \, \, 0, \, \, \, \, \, \, \, \, \, \ ].dd );
~txefc.atk_(0.1).rel_(2);
~txefc.fatk_(0.2).frel_(2);
~txefc.octave = 4;
~txefc.harmonic = [1, 2];
~txefc.amp = 0.5;
~txefc.play(fadeTime:4, reset:true, out:0);
~txefc.stop(fadeTime:4);
~txefc.gui;


/////////////////////////////////////////
// name

~uaj = ~uaj ? S(\subtractr);

~uaj.fx(90, {arg in; AllpassC.ar(in, 1, TempoClock.default.tempo * 0.425, 3)});
~uaj.wet90 = 0.3;

~uaj.fx(100, \reverb).wet100 = 0;

~uaj.detune = 1;
~uaj.pulse_(0.4).saw_(1);
~uaj.pulsewidth = {SinOsc.kr(1/3).range(0.6, 0.8)};
~uaj.stretch = 0.5;
~uaj.cutoff = 369.76166826224;
~uaj.fvel = 5.0683141891892;
~uaj.res = 0.18243243243243;
~uaj.akt = 0.2;
~uaj.set([\degree, \dur], [0, 2, 0, 4].dd);

~uaj.rel = [0.5, 1, 2].pseq.latch({arg evt; evt[\degree].isRest.not });
~uaj.octave = [4,4,5].pseq.latch({arg evt; evt[\degree].isRest.not });
~uaj.harmonic = 1;//[1, 1.5];
~uaj.legato = Pkey(\rel);
~uaj.frel = Pkey(\rel);
~uaj.vel = 0.8
~uaj.play(out:0)
~uaj.stop;
~uaj.gui;




~ham = ~ham ? S(\subtractr);
~ham.fx(90, \delay).set(\wet90, 0.7);
~ham.fx(100, \reverb).set(\wet100, 0.35);
~ham.fx(120, \bufglitch).set(\wet120, 0.5);
~ham.rectrig_(1).run_(1);
~ham.fx(130, \reversedelay).set(\wet130, 0.4);
~ham.fx(140, \pitchshift, \windowSize, 2).set(\wet140, 0.4);

~ham.gui;
~ham.play;
~ham.stop;

~ham.props.asCompileString
/*
( 'fvel': 7.5622657534247, 'cutoff': 166.56277236493, 'saw': 0.48219178082192, 'sawfreqmul': 2.0 )
*/

(
Pdef(\ham, ~ham.pdef <> PtimeChain(
	Pbind(\dur, 0.5, \degree, Pseq([0, 2], inf)),
	Pbind(\dur, 2.1, \octave, Pseq([4, 5], inf)),
	Pbind(\dur, 4, \pan, Pseq([-1, 1], inf))
)
)
)
Pdef(\ham).play;
Pdef(\ham).stop;

(
Pdef(\ham2, Pbind(\vel, 0.6, \pulse, 1, \tri, 0) <> ~ham.pdef <> PtimeChain(
	Pbind(\dur, 0.25, \degree, Pseq([4, 6], inf)),
	Pbind(\dur, 1.1, \octave, Pseq([4, 5], inf)),
	Pbind(\dur, 2, \pulsewidth, Pseq([0.6, 0.9], inf))
)
)
)

Pdef(\ham2).play;
Pdef(\ham2).stop;


/////////////////////////////////////////
// record
App.saveWorkspace("wip5", rec:true);
s.stopRecording;








