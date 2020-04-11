/////////////////////////////////////////
// sqt
~sqt = ~sqt ? S(\subtractr);
~sqt.fx(10, \delay).wet10_(0.4);
~sqt.legato = 0.1;
~sqt.stretch = 1;
~sqt.octave = 7;
~sqt.set([\degree, \dur], [ 0, 0, [0, [0, 0, [0, 0, 0, 0]]], 0 ].dd);
~sqt.lag = 0.5;
~sqt.play;
~sqt.stop;
~sqt.gui;

/////////////////////////////////////////
// qjhbu
~qjhbu = ~qjhbu ? S(\subtractr);
~qjhbu.fx(10, \delay).wet10_(0.4);
~qjhbu.tri_(0).pulse_(1);
~qjhbu.pulsewidth = { SinOsc.ar(1/11).range(0.3, 0.7) };
~qjhbu.legato = 0.4;
~qjhbu.atk_(4).rel_(4).fatk_(4).frel_(4);
~qjhbu.degree = [2, 3].pseq.stutter(2);
~qjhbu.dur = 13;
~qjhbu.vel = 0.8;
~qjhbu.play;
~qjhbu.stop;

/////////////////////////////////////////
// tdky
~tdky = ~tdky ? S(\subtractr);
~tdky.fx(10, \pitchshift, \windowSize, 2).wet10_(0.3);
~tdky.fx(20, \reverb).wet20_(0.8).t60_(5).size_(5);
~tdky.detunehz = 1;
~tdky.atk_(2).legato_(1).rel_(6).relcuve_(4);
~tdky.fatk_(2).frel_(6);
~tdky.octave = 3;
~tdky.degree = [0, 4, 7, 8];
~tdky.harmonic = [1, 2];
~tdky.dur = 4;
~tdky.vel = 0.2;
~tdky.tri_(0).pulse_(0).saw_(1);
~tdky.cutoff = 220;
~tdky.fvel = 6;
~tdky.res = 0.2;
~tdky.play;
~tdky.stop;
~tdky.gui;

/////////////////////////////////////////
// oojtc
~oojtc = ~oojtc ? S(\subtractr);
~oojtc.detunehz = 1;
~oojtc.fx(20, \reverb).wet20_(0.5).t60_(5).size_(5);
~oojtc.tri_(0).sine_(1);
~oojtc.degree_(4).octave_(7);
~oojtc.sustain = 0.1;
~oojtc.dur = 11;
~oojtc.lag = 0.25;
~oojtc.play;
~oojtc.stop;

/////////////////////////////////////////
// hcr
~hcr = ~hcr ? S(\subtractr);
~hcr.detunehz = 4;
~hcr.fx(10, \crush).wet10_(0.2).crush_(4);
~hcr.fx(20, \delay).wet20_(0.3);
~hcr.legato = 0.05;
~hcr.harmonic = [1, 1.5];
~hcr.stretch = 1;
~hcr.octave = 5;
~hcr.set([\degree, \dur], [ 1, 1, 1, 1, [1, [[1, 1, 1], 1]] ].dd);
~hcr.lag = 1;
~hcr.vel = 0.5;
~hcr.play;
~hcr.stop;

/////////////////////////////////////////
// mix
~zqvx = ~zqvx ? M(\zqvx);
~zqvx.stop(fadeTime:8);
~zqvx.play(fadeTime:8);

~zqvx.mix(~oojtc);
~zqvx.mix(~tdky);
~zqvx.mix(~qjhbu);
~zqvx.mix(~sqt);

~zqvx.fx(5, {arg in; PitchShift.ar(in, 2, 2, 0.01, 0.01)}).set(\wet5, 0.3);
~zqvx.fx(10, {arg in; Greyhole.ar(in, 2, 0, 5, feedback:0.5);}).set(\wet10, 0.4);
~zqvx.fx(20, {arg in; in ring1: SinOsc.ar(SinOsc.kr(1/31).range(10, 220)) }).set(\wet20, 0.3);

App.saveWorkspace("wip7", rec:true);
s.stopRecording;



