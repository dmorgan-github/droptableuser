/////////////////////////////////////////
// axzwa
~axzwa = S(\axzwa, \erajg);

~axzwa.fx(100, {arg in; JPverb.ar(in, 3, 0, 3) });
~axzwa.wet100 = 0.1;

~axzwa.detunehz = 0;
~axzwa.legato = 0.1;
~axzwa.fratio = 50;
~axzwa.root = 0;
~axzwa.octave = 6;
~axzwa.harmonic = [1, 1.5];
~axzwa.stretch = 0.5;
~axzwa.ddl([0, 0, 2!3, 3!5 ] ++ {\r}.dup(4));
~axzwa.vel = 0.1;

~axzwa.play;
~axzwa.stop;
~axzwa.gui;


/////////////////////////////////////////
// gae
~gae = S(\gae, \subtractr);

~gae.fx(90, \delay);
~gae.fx(95, {arg in; PitchShift.ar(in, 4, -5.midiratio, 0.01, 0.01)})
~gae.fx(100, {arg in; JPverb.ar(in, 3, 0, 3) });
~gae.wet90 = 0.6;
~gae.wet95 = 0.4;
~gae.wet100 = 0.4;

~gae.detunehz = 0;
~gae.root = 0;
~gae.legato = 0.5;
~gae.octave = 7;
~gae.stretch = 0.25;
~gae.ddl([0, [7, 6, 5, 4], 1, -1]);
~gae.vel = 0.7;

~gae.play;
~gae.stop;
~gae.gui;


/////////////////////////////////////////
// record
App.saveWorkspace("wip3", rec:true);
s.stopRecording;