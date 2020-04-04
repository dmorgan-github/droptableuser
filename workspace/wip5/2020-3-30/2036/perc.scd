TempoClock.default.tempo = 90/60;

(
SynthDef(\amde, {
	var freq = \freq.kr(100);
	var freqmul = Line.ar(\fvel.kr(2), 1, \fdur.kr(0.01));
	var sig = SinOsc.ar(freq * freqmul, 0.5pi);
	var aeg = Env.perc(\atk.kr(0.001), \rel.kr(0.06), curve:\curve.kr(-4)).ar(doneAction:Done.freeSelf);
	sig = sig * aeg * \amp.kr(0.3);
	sig = Splay.ar(sig);
	OffsetOut.ar(\out.kr(0), sig);
 }).add;

SynthDef(\erajg, {
	var freq = \freq.kr(100);
	var modfreq = freq * \fratio.kr(2);
	var index = modfreq * Line.ar(\fvel.kr(2), 1, \fdur.kr(0.01));
	//var index = modfreq * Env.perc(0.01, \fdur.kr(0.01)).ar().linlin(0, 1, \fvel.kr(2), 1);
	var fm = SinOsc.ar(modfreq) * index;
	var sig = SinOsc.ar(freq + fm, 0.5pi);
	var aeg = Env.perc(\atk.kr(0.001), \rel.kr(0.06), curve:\curve.kr(-4)).ar(doneAction:Done.freeSelf);
	sig = sig * aeg * \amp.kr(0.3);
	sig = Splay.ar(sig);
	OffsetOut.ar(\out.kr(0), sig);
 }).add;
)


/////////////////////////////////////////
// high tom
~cti = S(\cti, \amde);
~cti.dur = Pbjorklund2(3, 8, inf) * 0.25;
~cti.root_(0).degree_(0).octave_(6);
~cti.stretch = 1;
~cti.play;
~cti.stop;

/////////////////////////////////////////
// med tom
~uxy = S(\uxy, \amde);
~uxy.fx(100, \delay);

~uxy.wet100 = 0.3;
~uxy.dur_(Pbjorklund2(5, 8, inf, 0.15))
~uxy.root_(0).degree_(Pwrand([0, 2, 4], [3, 2, 1].normalizeSum, inf));
~uxy.octave_(6);
~uxy.stretch = 0.25;
~uxy.fvel = 2;
~uxy.fratio = 2;
~uxy.amp = 0.1;
~uxy.play;
~uxy.stop;
~uxy.gui;

/////////////////////////////////////////
// kick
~ouit = S(\ouit, \amde);
~ouit.dur = 1;
~ouit.root_(0).degree_(0).octave_(3);
~ouit.amp = 0.2;
~ouit.rel = 0.06;
~ouit.fdur = 0.01;
~ouit.fvel = 2;
~ouit.stretch = 1;
~ouit.play;
~ouit.stop;
~ouit.gui;

/////////////////////////////////////////
// tweet
~ucroi = S(\ucroi, \erajg);
~ucroi.fx(100, {arg in; NHHall.ar(in, 2)});
~ucroi.wet100 = 0.1;
~ucroi.octave = 5;
~ucroi.stretch = 0.5;
~ucroi.dur_([3, 2, 1, 1, 0.5, 0.5].mirror2.pseq);
~ucroi.octave_([6,7].pseq).amp_(0.15).rel_(0.05).curve_(-14);
~ucroi.fratio = 3.1;
~ucroi.fvel = 20;
~ucroi.play;
~ucroi.stop;
~ucroi.amp = 0.04;


/////////////////////////////////////////
// axzwa
~axzwa = S(\axzwa, \erajg);
~axzwa.fx(80, \sat2);
~axzwa.fx(90, \delay);
~axzwa.fx(100, {arg in; NHHall.ar(in, 3) });
~axzwa.wet80 = 0.5;
~axzwa.wet90 = 0.2;
~axzwa.wet100 = 0.1;
~axzwa.fratio = 4;
~axzwa.fdur = 0.01;
~axzwa.root = 0;
~axzwa.octave = 4;
~axzwa.harmonic = [1, 1.5];
~axzwa.stretch = 0.5;
~axzwa.ddl([0, 0, 2!3, 3!4 ] ++ {\r}.dup(4));
~axzwa.amp = 0.001 * 0.25;

~axzwa.play;
~axzwa.stop;
~axzwa.gui;

/////////////////////////////////////////
// texture
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




