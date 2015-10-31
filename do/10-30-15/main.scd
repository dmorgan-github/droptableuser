q = q ? ();
q.b = BufEnvir(s);
//q.b.read(\bd, "/Users/david/projects/droptableuser/samples/Roland TR-808 Normalised/BassDrum/KickDrum0018.aif");
q.b.read(\bd, "/Users/david/projects/droptableuser/samples/Roland TR-808 Normalised/BassDrum/KickDrum0019.aif");
q.b.read(\sd, "/Users/david/projects/droptableuser/samples/Roland TR-808 Normalised/SnareDrum/SnareDrum0011.aif");
q.b.read(\chh, "/Users/david/projects/droptableuser/samples/Roland TR-808 Normalised/Cls'd Hihat/Closed Hihat0003.aif");
q.b.read(\ohh, "/Users/david/projects/droptableuser/samples/Roland TR-808 Normalised/Open Hihat/Open Hihat0003.aif");
q.b.read(\man, "/Users/david/projects/droptableuser/samples/oh-yeah-man-they-definitely-feel-it.wav");
q.b.read(\mar, "/Users/david/projects/droptableuser/samples/Roland TR-808 Normalised/Misc/Maraca.aif");
q.b.read(\clp, "/Users/david/projects/droptableuser/samples/LinnDrum LM-2/Studer A800/Clap.Saturated.aif");

(
SynthDef(\samplr, {arg numChannels = 1, buf, trigger = 1, startPos = 0, loop = 0, out = 0, amp = 0.5;

	var sig = PlayBuf.ar(numChannels:1,
		bufnum:buf,
		rate:BufRateScale.kr(buf),
		trigger: trigger,
		startPos: startPos,
		loop: loop,
		doneAction:2);

	OffsetOut.ar(out, sig * amp);

}).add;

SynthDef(\s1, {arg freq = 440, lag = 0.1, phase = 0,
	out = 0, att = 0.1, rel = 1, curve = -4, ts = 1, t_gate = 1, doneAction = 0, amp = 0.5;

	var freqlag = freq.lag(lag);
	var env = Env.perc.kr(gate: t_gate, doneAction: doneAction);
	var sig = SinOsc.ar(freq, phase).fold(-1, 1).tanh;
	OffsetOut.ar(out, sig * env * amp * AmpCompA.kr(freq));

}).add;

SynthDef(\s2, {arg freq = 440, lag = 0.1, phase = 0,
	out = 0, att = 0.1, rel = 1, curve = -4, ts = 1, t_gate = 1, doneAction = 0, amp = 0.5;

	var freqlag = freq.lag(lag);
	var env = Env.linen.kr(gate: t_gate, doneAction: doneAction);
	var sig = SinOsc.ar(freq, SinOsc.ar(freq * 0.5, 0, Line.kr(3, 1, 1))).fold(Env([-1,-0.1],[1], -4).kr, 1).distort;
	OffsetOut.ar(out, sig * env * amp * AmpCompA.kr(freq));

}).add;

SynthDef(\delay, {arg in = 0, out = 0;

	var sig = NumChannels.ar(In.ar(in), 1);
	var fx = sig + DelayC.ar(sig, 0.2, 0.2);
	Out.ar(out, fx);

}).add;

SynthDef(\chorus, {arg in, out = 0;

	var sig = NumChannels.ar(In.ar(in), 1);
	var fx = DelayC.ar(sig, 1/200, SinOsc.kr(3, [0.5pi, 1.5pi]).range(1/300,1/200) );
	Out.ar(out, sig + fx);
}).add;

SynthDef(\fm, {arg in, out = 0, amp = 0.5;

	var sig = In.ar(in);
	var fx = DelayC.ar(sig, 1/200,
		SinOsc.ar(
			LFNoise2.kr(0.1).range(1440,4400), [0.5pi, 1.5pi]).range(1/300,1/200)
	);// * Env.linen.circle.kr * 0.3;
	//in + fx.wrap(-0.5, 1).clip(-0.5, 0.5).tanh;
	sig = sig + ( fx.wrap(-0.5, 0.5).tanh * 0.2);
	Out.ar(out, sig * amp);

}).add;

SynthDef(\dubecho,{|length = 0.375, fb = 0.8, sep = 0.012, in, out = 0|

	var input = In.ar(in, 2);
	var output = input + Fb({

		arg feedback; // this will contain the delayed output from the Fb unit

		var left,right;
		var magic = LeakDC.ar(feedback*fb + input);
		//magic = HPF.ar(magic, 400); // filter's on the feedback path
		//magic = LPF.ar(magic, 5000);
		//magic = magic.tanh; // and some more non-linearity in the form of distortion
		#left, right = magic; // let's have named variables for the left and right channels
		magic = [
			DelayC.ar(left, 1, Stepper.kr(Impulse.kr(2), 0, 0.2, 1, 0.1)),
			DelayC.ar(right, 1, LFNoise2.ar(12).range(sep,0))];

	},length);
	Out.ar(out, output);
}).add;

SynthDef(\moogff, {arg in, out = 0, wet = 0;

	var sig = In.ar(in);
	var fx = MoogFF.ar(sig, Env([220,10000,220],[2], -4).circle.kr);
	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet);
	);
}).add;

SynthDef(\flange, {arg in, out = 0, wet = 0;

	var sig = NumChannels.ar(In.ar(in), 1);
	var fx = sig + [
		CombC.ar(sig, 1, SinOsc.kr(0.01, 0, 0.002, 0.01), 0.05),
		CombC.ar(sig, 1, LFTri.kr(0.01, 0.5, 0.003, 0.01), 0.05),
		CombC.ar(sig, 1, LFCub.kr(0.01, 0.75, 0.005, 0.01), 0.05)
	].sum;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet);
	);

}).add;

)


(

~sd = ();
~sd.fx = ();
~sd.amp = 0.10;
~sd.bus = ~sd.bus ? Bus.new(index:16, numChannels:1);
~sd.events = Routine({

	~sd.grp = Group.new;

	~sd.fx[\freeverb] = Synth.tail(~sd.grp, \freeverb, [\in, ~sd.bus, \out, ~sd.bus, \wet, 0, \mix, 0.5, \room, 0.6, \damp, 0.5]);
	~sd.fx[\splay] = Synth.tail(~sd.grp, \splay, [\in, ~sd.bus]);

	inf.do({
		(\instrument: \samplr, \buf: q.b[\sd], \amp: ~sd.amp.value, \group: ~sd.grp, \out: ~sd.bus).yield;
	});
});

~bd = ();
~bd.fx = ();
~bd.amp = 0.07;
~bd.bus = ~bd.bus ? Bus.new(index:18, numChannels:1);
~bd.events = Routine({

	~bd.grp = Group.new;

	//~bd.fx[\flange] = Synth.tail(~bd.grp, \flange, [\in, ~bd.bus, \out, ~bd.bus, \wet, 0]);
	~bd.fx[\freeverb] = Synth.tail(~bd.grp, \freeverb, [\in, ~bd.bus, \out, ~bd.bus, \wet, 0, \mix, 0.5, \room, 0.6, \damp, 0.5]);
	~bd.fx[\splay] = Synth.tail(~bd.grp, \splay, [\in, ~bd.bus]);

	inf.do({
		(\instrument: \samplr, \buf: q.b[\bd], \group: ~bd.grp, \out: ~bd.bus, \amp: ~bd.amp.value).yield;
	});
});

~perc1 = ();
~perc1.fx = ();
~perc1.amp = {rrand(0.02, 0.05)};
~perc1.bus = ~perc1.bus ? Bus.new(index:20, numChannels:1);
~perc1.events = Routine({

	~perc1.grp = Group.new;

	~perc1.fx[\freeverb] = Synth.tail(~perc1.grp, \freeverb, [\in, ~perc1.bus, \out, ~perc1.bus, \wet, 0, \mix, 0.4, \room, 0.6, \damp, 0.5]);
	~perc1.fx[\rndpan] = Synth.tail(~perc1.grp, \rndpan, [\in, ~perc1.bus, \rate, 1]);

	inf.do({
		(\instrument: \samplr, \buf: q.b[\chh], \amp: ~perc1.amp.value, \group:~perc1.grp, \out: ~perc1.bus).yield;
	});
});

~perc2 = ();
~perc2.fx = ();
~perc2.amp = 0.011;
~perc2.bus = ~perc2.bus ? Bus.new(index:22, numChannels:1);
~perc2.events = Routine({

	~perc2.grp = Group.new;

	//~perc2.fx[\dubecho] = Synth.tail(~perc2.grp, \dubecho, [\in, ~perc2.bus, \out, ~perc2.bus]);
	~perc2.fx[\freeverb] = Synth.tail(~perc2.grp, \freeverb, [\in, ~perc2.bus, \out, ~perc2.bus, \wet, 0, \mix, 0.4, \room, 0.6, \damp, 0.5]);
	~perc2.fx[\rndpan] = Synth.tail(~perc2.grp, \rndpan, [\in, ~perc2.bus, \rate, 2]);

	inf.do({
		(\instrument: \samplr, \buf: q.b[\ohh], \amp: ~perc2.amp.value, \group: ~perc2.grp, \out: ~perc2.bus).yield;
	});
});

~perc3 = ();
~perc3.fx = ();
~perc3.amp = {rrand(0.03, 0.06)};
~perc3.bus = ~perc3.bus ? Bus.new(index:24, numChannels:1);
~perc3.events = Routine({

	~perc3.grp = Group.new;

	~perc3.fx[\freeverb] = Synth.tail(~perc3.grp, \freeverb, [\in, ~perc3.bus, \out, ~perc3.bus, \wet, 0, \mix, 0.4, \room, 0.6, \damp, 0.5]);
	~perc3.fx[\rndpan] = Synth.tail(~perc3.grp, \rndpan, [\in, ~perc3.bus, \rate, 5]);

	inf.do({
		(\instrument: \samplr, \buf: q.b[\mar], \amp: ~perc3.amp.value, \group: ~perc3.grp, \out: ~perc3.bus).yield;
	});
});

~s1 = ();
~s1.fx = ();
~s1.amp = 0.015;
~s1.bus = ~s1.bus ? Bus.new(index:26, numChannels:1);
~s1.events = Routine({

	var ptrn = Routine({

		var p1 = Pbrown.new(0, 4, 1).asStream;
		var p2 = Pwhite.new(0, 12, inf).asStream;
		var p3 = Pstandard.new.asStream;
		var reps = [rrand(1, 15), exprand(1, 50).round.asInteger];

		inf.do({

			var ptrn = [p1, p2].choose;
			var x, y;
			var val;
			reps.choose.do({

				#x, y = p3.next();
				val = ptrn.next();
				if (val == 8, {
					//"8".postln;
				});

				[ptrn.next(), y].yield;
			});
		});
	});

	~s1.grp = Group.new;

	~s1.fx[\moogff] = Synth.tail(~s1.grp, \moogff, [\in, ~s1.bus, \out, ~s1.bus]);
	~s1.fx[\chorus] = Synth.tail(~s1.grp, \chorus, [\in, ~s1.bus, \out, ~s1.bus]);
	~s1.fx[\dubecho] = Synth.tail(~s1.grp, \dubecho, [\in, ~s1.bus, \out, ~s1.bus]);
	~s1.fx[\freeverb] = Synth.tail(~s1.grp, \freeverb, [\in, ~s1.bus, \out, ~s1.bus, \wet, 0, \mix, 0.33, \room, 0.5]);
	~s1.fx[\splay] = Synth.tail(~s1.grp, \splay, [\in, ~s1.bus]);

	inf.do({

		var degree, amp;
		#degree, amp = ptrn.next();

		(\instrument: \s1,
			\octave: rrand(5,6),
			\group: ~s1.grp,
			\scale: Scale.phrygian,
			\gate: 1,
			\degree: degree,
			\amp: ~s1.amp.value,
			\out: ~s1.bus,
			\doneAction: 2
		).yield;
	});
});

~bass = ();
~bass.fx = ();
~bass.amp = 0.04;
~bass.bus = ~bass.bus ? Bus.new(index:28, numChannels:1);
~bass.events = Routine({

	~bass.grp = Group.new;

	~bass.fx[\freeverb] = Synth.tail(~bass.grp, \freeverb, [\in, ~bass.bus, \out, ~bass.bus]);
	~bass.fx[\splay] = Synth.tail(~bass.grp, \splay, [\in, ~bass.bus]);

	inf.do({

		(\instrument: \s2,
			\octave: 4,
			\group: ~bass.grp,
			\scale: Scale.phrygian,
			\gate: 1,
			\degree: rrand(0, 2),
			\amp: ~bass.amp.value,
			\out: ~bass.bus,
			\doneAction: 2,
		).yield;
	});
});

)

(

//s.prepareForRecord("/Users/david/projects/droptableuser/do/wip/10-30-15.aiff");
//s.record();
//s.stopRecording();

Task({

	var pattern = Pbjorklund(Pstutter(2, Pseq([3, 5], inf)), 8, inf).asStream;
	var cnt = 0;

	inf.do({arg i;

		var num = i % 16;
		var amp = pattern.next();

		var fill = 0.2;
		var bdOrSd = 0.3;

		// bd on the 1
		if(num == 0, {
			~bd.events.next().play;
			~bass.events.next().play;
			fill = 0;
		});

		// sd on the 2
		if (num == 8, {
			~sd.events.next().play;
			fill = 0;
		});


		~s1.events.next().play;
		~perc1.events.next().play;

		if (amp == 0, {

			if (fill.value.coin, {

				if (bdOrSd.value.coin, {

				}, {
					~bd.events.next().play;
				});

			}, {

			});
		}, {

			if (0.5.coin, {

					if (fill != 0, {

						if (0.1.coin, {
							~sd.events.next().play;
						}, {
							~perc2.events.next().play;
						});

					}, {
						~perc2.events.next().play;
					});

			}, {


				if (0.5.coin, {
					~perc3.events.next().play;

				}, {

				});
			});

		});
		cnt = cnt + 1;
		0.125.wait;

	});
}).play;


)


(

~recordBuses = {arg objs, path;

	var recHeaderFormat = "aiff";
	var recSampleFormat = "int24";

	var bufs = objs.collect({arg b, i;

		Buffer.alloc(s, 65536, 1, {arg buf;

			var chanNum = "", chanPath;
			chanNum = "_" ++ i;
			chanPath = path ++ chanNum ++ "." ++ recHeaderFormat;
			chanPath.debug("Preparing:");
			buf.writeMsg(chanPath,
				recHeaderFormat, recSampleFormat, 0, 0, true);
		});
	});

	SynthDef(\diskout, {

		bufs.collect({arg buf, i;

			var temp = objs[i];
			DiskOut.ar(buf, In.ar(temp.bus.index, 1));
		});

	}).play(target:s, addAction:\addToTail);

	bufs;
};

a = ~recordBuses.([~sd, ~bd, ~perc1, ~perc2, ~perc3, ~s1, ~bass], "/Users/david/projects/droptableuser/do/wip/wip");
//a.collect({arg buf; buf.close; buf.free;});
)


var recHeaderFormat = "aiff", recSampleFormat = "int24";
var obj = [
	~sd, ~bd, ~perc1, ~perc2, ~perc3, ~s1, ~bass
];
var path = "~/bobo".standardizePath;

a = obj.collect({arg b, i;

	Buffer.alloc(s, 65536, 1, {arg buf;

			var chanNum = "", chanPath;
			chanNum = "_" ++ i;
			chanPath = path ++ chanNum ++ "." ++ recHeaderFormat;
			chanPath.debug("Preparing:");
			buf.writeMsg(chanPath,
				recHeaderFormat, recSampleFormat, 0, 0, true);
		});
});


SynthDef(\diskout, {

	a.collect({arg buf, i;

		var temp = obj[i];
		DiskOut.ar(buf, In.ar(temp.bus.index,1));
	});

}).play(target:s, addAction:\addToTail);


a;

//w = a.collect({arg buf, i;
//	var temp = obj[i];
//	Synth.tail(temp.grp, "diskout", [\bufnum, buf, \bus, temp.bus.index]);
//});



)

w.collect({arg synth; synth.free;});
a.collect({arg buf; buf.close; buf.free;});




a.b = a.o.collect({arg b, i;

	Buffer.alloc(b.server, 65536, b.numChannels, {arg buf;

			var chanNum = "", chanPath;
			if(busses.size > 1,{ chanNum = "_" ++ i; });
			chanPath = path ++ chanNum ++ "." ++ recHeaderFormat;
			chanPath.debug("Preparing:");
			buf.writeMsg(chanPath,
				recHeaderFormat, recSampleFormat, 0, 0, true);
		});
});

m = MultiChanRecorder(b);
m.prepareForRecord("/Users/david/projects/droptableuser/do/wip");
m.record;
m.stop;


~prepareForRecord = {arg path, busses;

	var recordBufs;
	var recHeaderFormat = "aiff", recSampleFormat = "int24";

	recordBufs = busses.collect({arg b,i;

		Buffer.alloc(b.server, 65536, b.numChannels, {arg buf;

			var chanNum = "", chanPath;
			if(busses.size > 1,{ chanNum = "_" ++ i; });
			chanPath = path ++ chanNum ++ "." ++ recHeaderFormat;
			chanPath.debug("Preparing:");
			buf.writeMsg(chanPath,
				recHeaderFormat, recSampleFormat, 0, 0, true);
		});
	});
	recordBufs;
};


recordBufs.collect({ arg b,i;
	DiskOut.ar(b.bufnum, busses[i].ar );
});





~samples.ls()
~tappr.()
s.meter
s.queryAllNodes






b = Buffer.alloc(s, 65536, 1);
// create an output file for this buffer, leave it open
b.write("~/diskouttest.aiff".standardizePath, "aiff", "int16", 0, 0, true);

a = Synth.tail(~s1.grp, "help-Diskout", [\bufnum, b.bufnum, \bus, 26]);
a.free;
b.close;
// free the buffer
b.free;

