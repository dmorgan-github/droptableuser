\oxjg
~oxjg = ~oxjg ? S(\subtractr2);
//~oxjg.fx(10, \reversedelay).wet10_(0).delay_(1).feedback_(0.7).crossfade_(1);
//~oxjg.fx(20, \disintigrator).wet20_(0).prob_(0.3).mult_(0);
//~oxjg.fx(30, \decimator).wet30_(0).rate_(4).bits_(10);

~oxjg.fx(35, \barrys).wet35_(0.5).kneepoint_(-45).decay_(10);
~oxjg.fx(37, \delay).wet37_(0.4);
~oxjg.fx(40, \nhhall).wet40_(0.3).rt60_(2);

~oxjg.lpf = 20000;
~oxjg.hpf = 800;

~oxjg.detunehz = 1;
~oxjg.scale = Scale.phrygian;
~oxjg.tri_(0.5).saw_(0.5);
~oxjg.trifreqmul = 2;
~oxjg.cutoff = 100;
~oxjg.fvel = 8;
~oxjg.res = 0.1;
~oxjg.dec = 0.1;
~oxjg.suslevel = 0.7;
~oxjg.rel = 0.1;
~oxjg.octave = 5;
~oxjg.atk = 0.1;
~oxjg.harmonic = [1, 2];
~oxjg.stretch = 0.5;
~oxjg.vel = 1;
~oxjg.set([\degree, \dur], [0, [\, 4], [0,0,1,2], -1].mirror2.scramble.dd);
//~oxjg.prob = { SinOsc.ar(1).range(0.2, 0.8) };

~oxjg.play;
~oxjg.stop;

(1..8).powerset.select{| c | c.size == 3 }

/////////////////////////////////////////
// record
App.saveWorkspace("wip7", rec:true);
s.stopRecording;
s.record("%_%.aiff".format(commit, Date.getDate.asSortableString));

~buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/angels.piano.mono.aiff");
~buf.loadToFloatArray(action: {arg data; ~buf = Buffer.loadCollection(s, data.reverse)});

~ps = PaulStretch(~buf);
~ps.filter(10, {arg in; JPverb.ar(in, 10, 0, 10)}).set(\wet10, 0.4);
~ps.filter(20, {arg in; in ring1: SinOsc.ar(SinOsc.kr(1/11).range(0.1, 100)) }).set(\wet20, 0.25);
~ps.filter(30, {arg in; FbC({arg fb; PitchShift.ar(fb, 2, 1.5, 0.01, 0.01) * 0.5 + in}, 3, 2 + [3/8, 5/8]) }).set(\wet30, 0.7);
~ps.set(\stretch, 50);
~ps.play;
~ps.stop(fadeTime:8);