(
ProxySynthDef(\oneshot, {

	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var start = \start.kr(0);
	var end = \end.kr(1);
	var curve = \curve.kr(0);

	var numFrames = BufFrames.kr(buf);
	var startFrame = start * numFrames;
	var endFrame = end * numFrames;

	var dur = (endFrame - startFrame)/BufSampleRate.kr(buf);
	var phasor = Line.ar(startFrame, endFrame, dur * rate.reciprocal);
	var sig = BufRd.ar(1, buf, phasor, loop:0, interpolation: 4);
	Splay.ar(sig);

}).add;
)

~gridkit = ProxySpace.new(s);
~gridkit.quant = 4.0;
~gridkit.clock = TempoClock.default;

(
~bufs = (
	\kik: Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/BassDrum/KickDrum0001.aif"),
	\sn: Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/SnareDrum/SnareDrum0001.aif"),
	\ch: Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Cls'd Hihat/Closed Hihat0001.aif"),
	\mc: Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Mid Conga/Mid Conga0001.aif")
);
)

(
~events = [
	(instrument:\oneshot, buf:~bufs[\kik]),
	(instrument:\oneshot, buf:~bufs[\sn]),
	(instrument:\oneshot, buf:~bufs[\ch]),
	(instrument:\oneshot, buf:~bufs[\mc])
];
)

(
~grid = [
	[1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0],
	[0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0],
	[0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0],
	[0,0,0,0, 0,0,0,0, 0,1,0,0, 0,0,0,0]
];
)

~dur = Pseq([0.25], inf);

(
~process = {arg count, time;

	Plazy({

		var rows = ~grid;
		var evts = rows.collect({arg item, row;

			var val;
			var event;
			var x = (count % item.size).asInt;
			val = item.wrapAt(count).value;

			event = (isRest:true);
			if (val > 0) {
				var myEvent = ~events.wrapAt(row);
				var node = ~gridkit[(\n ++ row).asSymbol];
				//node.play;
				myEvent[\group] = node.group;
				myEvent[\out] = node.bus;
				if (myEvent.isKindOf(Event) or: myEvent.isKindOf(Pattern)) {
					event = myEvent;
				};
			};

			Pn(event, 1);
		});

		Ppar(evts);
	})
};

~func = {

	var pattern;
	var seq = ~dur.asStream;

	Pspawner({arg sp;

		inf.do({arg i;

			var time = seq.next;
			var evt = ~process.(i.asInt, time);
			sp.par(evt);
			sp.wait(time);

		});
	});
};

)

~bobo = ~func.();
~bobo.play(quant:4, clock:TempoClock.default);
~bobo.stop;


~gridkit[\n1][4] = \filter -> {arg in; FbC({arg fb; fb * 0.5 + in}, 0.375)};
~gridkit[\n1].set(\wet4, 0.5)

~gridkit[\mix][0] = ~gridkit[\n0];
~gridkit[\mix][1] = ~gridkit[\n1];
~gridkit[\mix][2] = ~gridkit[\n2];
~gridkit[\mix][3] = ~gridkit[\n3];

(~gridkit[\mix][4] = \filter -> {arg in; JPverb.ar(in)});
~gridkit[\mix].set(\wet4, 0.4)

~gridkit[\mix].play;
~gridkit[\mix].stop;





