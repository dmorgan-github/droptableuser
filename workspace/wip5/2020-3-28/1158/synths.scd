TempoClock.default.tempo = 45/60;

~txefc = ~txefc ? S(\subtractr);
~txefc.fx(90, \delay);
~txefc.fbL_(0.5).fbR_(0.7);
~txefc.wet90 = 0.7;

~txefc.fx(95, \pitchshift, \windowSize, 1);
~txefc.psRatioL_(2).psRatioR_(1.5);
~txefc.wet95 = 0.45;

~txefc.fx(100, {arg in; AllpassC.ar(in, 1, 0.3, 5)});
~txefc.wet100 = 0.3;

~txefc.fx(105, {arg in; Splay.ar(in, 0.5) });

~txefc.detunehz = 0.3;
~txefc.vdepth = 0.004;
~txefc.cutoff = { SinOsc.ar(1/17).range(100, 200) };
~txefc.fvel = 12.387577419355;
~txefc.res = 0.3; //0.50967741935484
~txefc.tri_(1).triwidth_({ SinOsc.ar(1/11).range(0.6, 0.8) });
~txefc.saw_(0.51612903225806);
~txefc.set([\degree, \dur], [4, 2, -1, \, \, 0, \, \ ].dd );
~txefc.octave = 4;
~txefc.harmonic = [1, 2];
~txefc.amp = 0.5;
~txefc.play(fadeTime:4, reset:true);
~txefc.stop(fadeTime:4);
~txefc.gui;



/////////////////////////////////////////
// record
App.saveWorkspace("wip5", rec:true);
~txefc.play(fadeTime:4, reset:true);

s.stopRecording;
