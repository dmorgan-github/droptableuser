TempoClock.default.tempo = 55/60;


/////////////////////////////////////////
// name
~pbkfu = ~pbkfu ? S(\subtractr);
~pbkfu.fx(90, \delay).wet90_(0.5);
~pbkfu.stretch = 0.25;
~pbkfu.legato = 0.1;
~pbkfu.dur = [3, 3, 3, 3, 4, 2, 4].pseq;
~pbkfu.degree = [0, -1, -2].pseq;
~pbkfu.play;
~pbkfu.stop;

/////////////////////////////////////////
// \esi
~esi = ~esi ? S(\subtractr);
~esi.fx(90, \reverb).wet90_(0.3);
~esi.stretch = 0.25;
~esi.dur = [6, 4, 6, 6].pseq;
~esi.degree = 2;
~esi.octave = 6;
~esi.legato = 0.1;
~esi.play;
~esi.stop;

/////////////////////////////////////////
// \fuuwa
~fuuwa = ~fuuwa ? S(\subtractr);
~fuuwa.fx(90, \crush).crush_(4).wet90_(0.3);
~fuuwa.fx(95, \delay).wet95_(0.6);
~fuuwa.fx(100, \reverb).wet100_(0.3);
~fuuwa.octave = 3.peuclid(8).linlin(0, 1, 4,5);
~fuuwa.stretch = 0.25;
~fuuwa.dur = [3, 3, 3, 2, 3, 3, 3, 2].pseq;
~fuuwa.degree = 4;
~fuuwa.harmonic = [1, 2];
~fuuwa.legato = 0.2;
~fuuwa.play;
~fuuwa.stop;

/////////////////////////////////////////
// \pec
(
~pec = S(\pec, {arg freq, gate;

	var ieg = Env.adsr(\iatk.kr(0.01), \idec.kr(0.3), \irel.kr(1)).ar(gate:gate).linlin(0, 1, \index.kr(2), 1);
	var mod = SinOsc.ar(freq * \freqmod.kr(2)) * ieg;
	var sig = SinOsc.ar(freq, mod.mod(2pi));
	sig;

});
)

~pec.fx(90, \reverb).wet90_(0.4).t60_(5).size_(5);
~pec.fx(100, \pitchshift, \windowSize, 2).wet100_(0.6).psRatioL_(2).psRatioR_(1.5);
~pec.fx(110, {arg in; AllpassC.ar(in, 1, TempoClock.default.beatDur * 0.2, 5)}).wet110_(0.4);
~pec.fx(120, {arg in; LPF.ar(in, 640)});

~pec.index = 2;
~pec.freqmod = 4;
~pec.iatk = 3;
~pec.irel = 2;
~pec.atk = 2;
~pec.rel = 3;
~pec.dur = 8;
~pec.octave = 3;
~pec.harmonic = [1, 2, 4];
~pec.degree = [ [0, 2, 4], [-3, 5, 8] ].pseq
~pec.play;
~pec.stop;
~pec.amp = 0.4;

/////////////////////////////////////////
// ~wek
~wek = ~wek ? S(\subtractr);
~wek.fx(80, {arg in; LPF.ar(in, 770)});
~wek.fx(90, \delay).wet90_(0.4);
~wek.fx(100, \reverb).wet100_(0.4).t60_(5).size_(5);

~wek.detunehz = 1;
~wek.atk = 0.02;
~wek.tri_(0).sine_(1);
~wek.legato = 0.3;
~wek.sineskew_(0.7);
~wek.stretch = 0.5;
~wek.octave = 5;
~wek.set([\degree, \dur], [ [0, 1, 2], 3, 0, `[2,4], 0, 3, \, -1 ].dd);
~wek.amp = 0.35;
~wek.harmonic = 1;//[1, 2];
~wek.play;
~wek.stop;
~wek.gui

