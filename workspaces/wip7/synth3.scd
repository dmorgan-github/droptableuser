\iaezv
~iaezv = ~iaezv ? S(\pluck);
~iaezv.fx(10, \delay).wet10_(0.4);
~iaezv.stretch = 0.5;
~iaezv.scale = Scale.phrygian;
~iaezv.set([\degree, \dur], [0, [0, [0, 1, 2]], 0, [[3,9].pseq.limit(1), [2, 8].pseq.limit(1), 1, -1]].dd);
~iaezv.octave = 4.peuclid(9).linlin(0, 1, 4, 5) + 1;
~iaezv.legato = 0.1;
~iaezv.harmonic = 1;//[1, 2];
~iaezv.decay = 2;
~iaezv.coef = 0.5;
~iaezv.amp = 0.5;
~iaezv.vel
~iaezv.play;
~iaezv.stop;

\mig
~mig = ~mig ? S(\subtractr2);
~mig.fx(10, \delay).wet10_(0.6).fbL_(0.7).fbR_(0.7);
~mig.scale = Scale.phrygian;
~mig.set([\degree, \dur], [0, 1, 2, 3].dd);
~mig.tri_(0).pulse_(1);
~mig.cutoff = { SinOsc.ar(1/13).range(400, 4000) }
~mig.fvel = 2;
~mig.res = 0.7;
~mig.pulsewidth = { SinOsc.ar(1/3).range(0.3, 0.7) }
~mig.legato = 0.3;
~mig.harmonic = [1, 0.5];
~mig.play;
~mig.stop;
~mig.gui;

\vuo
~vuo = ~vuo ? S(\subtractr2);
~vuo.fx(5, \saturate).wet5_(0.4).gain_(15);
~vuo.fx(10, \nhhall).wet10_(0.7).rt60_(3);
~vuo.fx(20, {arg in; BLowPass4.ar(in, SinOsc.ar(1/11).range(220, 2800) )});
~vuo.fx(20, nil);
~vuo.scale = Scale.phrygian;
~vuo.degree = [0, 1, 2, -2].pseq;
~vuo.tri_(0.5).pulse_(0.2).sine_(1);
~vuo.sineskew = 0.7;
~vuo.trifreqmul = 2;
~vuo.pulsefreqmul = 1.5;
~vuo.detunehz = 0;
~vuo.pulsewidth = { SinOsc.ar(1/11).range(0.3, 0.7) };
~vuo.legato = 0.9;
~vuo.atk = 2;
~vuo.atkcurve = 2;
~vuo.rel = 1;
~vuo.octave = 3;
~vuo.cutoff = 150;
~vuo.fvel = 8;
~vuo.res = 0.6;
~vuo.dec = 0.5;
~vuo.suslevel = 0.8;
~vuo.harmonic = 1;//[1, 1.5];
~vuo.dur = 4;
~vuo.amp = 0.3;
~vuo.vel = 0.2;
~vuo.play(mono:true);
~vuo.stop;
~vuo.gui;

\juul
(
~juul = S(\juul, {arg freq, gate;

	var osc1 = {
		var index = \index.kr(2);
		var ivel = \ivel.kr(4);
		var idur = \idur.kr(0.1);
		var mod = SinOsc.ar(freq * \modratio.kr(2)) * Line.ar(index, index * ivel, idur);
		var sig = SinOsc.ar(freq, mod.mod(2pi) );
		sig;
	};

	var sig = osc1.();

	sig;

});
);

~juul.fx(10, \delay).wet10_(0.4);
~juul.fx(20, \nhhall).wet20_(0.3).rt60_(4);
~juul.fx(20, {arg in; LPF.ar(in, 1280)});
~juul.dur = [0.25, 0.5, 1].prand;
~juul.modratio = Pwhite(0.5, 10.0);
~juul.index = Pwhite(1, 8);
~juul.octave = 4;
~juul.legato = 0.1.incr(0.1).fold(0.1, 1.0);
~juul.vel = 0.3;
~juul.play;
~juul.stop;


/////////////////////////////////////////
// record
App.saveWorkspace("wip7", rec:true);
s.stopRecording;
s.record("%_%.aiff".format(commit, Date.getDate.asSortableString));

~kik = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/tr909/bd/BT0A0D0.WAV");
~kik = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/tr808/bd/BD0010.WAV");
~kik = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/bd/BD MPCVB Fat002.wav");
~ch = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/ch/HH MPCVB Fat2.wav");
~oh = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/oh/HHo MPCVB Fat2.wav");
~sd = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/sd/SD MPCVB Fat002.wav");

~fbaer = B(\fbaer, ~ch);
~fbaer.fx(10, \nhhall).wet10_(0.3);
~fbaer.amp = 1;
~fbaer.vel = 0.6;
~fbaer.stretch = 0.5;
~fbaer.set([\buf, \dur], [ [~kik, [~ch, ~ch]], ~sd ].dd);
~fbaer.play;
~fbaer.stop;




