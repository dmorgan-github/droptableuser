~wlmrs = ~wlmrs ? S(\subtractr);
~wlmrs.fx(90, \crush).wet90_(0.4);
//~wlmrs.fx(100, {arg in; LPF.ar(in, 1040)});
~wlmrs.fx(100, {arg in; LPF.ar(in, 20000)});
~wlmrs.fx(105, \waveloss).wet105_(0.5);
~wlmrs.fx(110, \delay).wet110_(0.4).fbL_(0.7).fbR_(0.7);

~wlmrs.detunehz = 0.5;
~wlmrs.tri = { SinOsc.ar(1/13).range(0, 1) };
~wlmrs.pulse = { SinOsc.ar(1/21).range(0, 1) };
~wlmrs.legato = 0.7;
~wlmrs.cutoff = 800;
~wlmrs.rel = 1;//{ SinOsc.ar(1/11).range(1, 4) };
~wlmrs.fvel = { LFSaw.ar(1/17).range(4, 12) };
~wlmrs.res = { LFDNoise3.ar(1/13).range(0.3, 0.6) };
~wlmrs.stretch = 0.25;
~wlmrs.set([\degree, \dur], [ 0, [0, 0, [0, 3, 2]], 2, 4 ].dd);
~wlmrs.triwidth = [0.6, 0.9].pseq.step(3);
~wlmrs.pulsewidth = [0.6, 0.9].pseq.step(5);
~wlmrs.octave = 3.peuclid(8).linlin(0, 1, 5, 6);
~wlmrs.harmonic = [1, 1.5];
~wlmrs.mtranspose = [0, 1, 2, -1].pseq.step(8);
~wlmrs.play;
~wlmrs.stop;
~wlmrs.gui;


/////////////////////////////////////////
// record
App.saveWorkspace("wip5", rec:true);
~wlmrs.play;

~wlmrs.stop(fadeTime:8);
s.stopRecording;