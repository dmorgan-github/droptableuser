\oxjg
~oxjg = ~oxjg ? S(\subtractr2);

~oxjg.fx(35, \barrys).wet35_(0.1).kneepoint_(-25).decay_(10);
~oxjg.fx(37, \delay).wet37_(0.4);
~oxjg.fx(40, \nhhall).wet40_(0.1).rt60_(1);

~oxjg.lpf = 20000;
~oxjg.hpf = 800;

~oxjg.detunehz = 1;
~oxjg.scale = Scale.phrygian;
~oxjg.tri_(1).saw_(0).pulse_(0.2);
~oxjg.trifreqmul = 1;
~oxjg.pulsewidth = [0.1, 0.7].pseq.step(4);
~oxjg.cutoff = 800;
~oxjg.fvel = {SinOsc.ar(1/21).range(0.3, 4)};
~oxjg.res = [0.3, 0.5, 0.8].pseq.step(5);
~oxjg.dec = 0.01;
~oxjg.suslevel = 0.2;
~oxjg.legato = 0.1.incr(0.1).fold(0.1, 0.9);
~oxjg.rel = 0.2;
~oxjg.octave = 5;
~oxjg.atk = 0.01;
~oxjg.harmonic = 1;//[1, 2];
~oxjg.stretch = 0.5;
~oxjg.amp = [1, 0.5] * 0.2;
~oxjg.vel = 1;
~oxjg.set([\degree, \dur], [0, [\, 4], [0,0,1,2], -1].mirror2.shuf(4).dd);
~oxjg.play;
~oxjg.stop;


/////////////////////////////////////////
// record
App.saveWorkspace("wip7", rec:true);
s.stopRecording;
s.record("%_%.aiff".format(commit, Date.getDate.asSortableString));


~ps2 = PaulStretch("/Users/david/projects/droptableuser/samples/1channel/vox/oh-yeah-man-they-definitely-feel-it.wav");
~ps2.filter(10, {arg in; JPverb.ar(in, 10, 0, 10)}).set(\wet10, 0.4);
~ps2.filter(30, {arg in; FbC({arg fb; PitchShift.ar(fb, 2, 1.5, 0.01, 0.01) * 0.5 + in}, 3, 2 + [3/8, 5/8]) }).set(\wet30, 0);
~ps2.set(\stretch, 20);
~ps2.play(vol:0.1, fadeTime:12);
~ps2.stop;


~buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/angels.piano.mono.aiff");
//~buf.loadToFloatArray(action: {arg data; ~buf = Buffer.loadCollection(s, data.reverse)});

~ps = PaulStretch(~buf);
~ps.filter(10, {arg in; JPverb.ar(in, 10, 0, 10)}).set(\wet10, 0.4);
~ps.filter(20, {arg in; in ring1: SinOsc.ar(SinOsc.kr(1/11).range(0.1, 100)) }).set(\wet20, 0.25);
~ps.filter(30, {arg in; FbC({arg fb; PitchShift.ar(fb, 2, 1.5, 0.01, 0.01) * 0.5 + in}, 3, 2 + [3/8, 5/8]) }).set(\wet30, 0.7);
~ps.set(\stretch, 20);
~ps.play(vol:0.3);
~ps.stop(fadeTime:8);