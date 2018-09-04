(
SynthDef(\oneshot, {

	var buf = \buf.kr(0);
	var rate = \rate.kr(1);

	var sig = PlayBuf.ar(1, buf, rate, loop:0, doneAction:2);
	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);

	OffsetOut.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////
// define player object
(
var grid_player = {

	var obj = (
		events: [],
		dur: 1,
		matrix: [],
		process: {arg self, count, time;

			Plazy({

				var rows = self.matrix;
				var evts = rows.collect({arg item, row;

					var val;
					var event;
					var x = (count % item.size).asInt;
					val = item.wrapAt(count).value;

					event = (isRest:true);
					if (val > 0) {
						var myEvent = self.events.wrapAt(row);
						if (myEvent.isKindOf(Event) or: myEvent.isKindOf(Pattern)) {
							event = myEvent;
						};
					};

					Pn(event, 1);
				});

				Ppar(evts);
			});

		},
		player: {arg self;

			var player = Pspawner({arg sp;

				inf.do({arg i;

					var time = self.dur.next;
					var evt = self.process(i.asInt, time);
					sp.par(evt);
					sp.wait(time);
				});
			});
			player;
		}
	);

	obj;
};

~volca_kit = grid_player.();
)


/////////////////////////////////
// patch
~volcakit = ProxySpace.new(s);
~volcakit.quant = 4.0;
~volcakit.clock = TempoClock.default;


/////////////////////////////////
// buffers
~bufs = ~bufs ? ();
~bufs[\volca_kik] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/bd/BD MPCVB Fat002.wav");
~bufs[\volca_ch] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/ch/HH MPCVB Fat2.wav");
~bufs[\volca_clav] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/cl/Clave MPCVB Fat2.wav");
~bufs[\volca_clap] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/cp/Clap MPCVB Fat3.wav");
~bufs[\volca_sn] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/sd/SD MPCVB Fat005.wav");
~bufs[\volca_hitom] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/tom/Tom MPCVB Fat006.wav");

/////////////////////////////////
// config player
//~perc = ~grid_player.();
~volca_kit.dur = Pseq([0.25], inf).asStream;
~volca_kit.dur = Pseg(Pseq([0.1,0.5,0.1], inf), Pseq([0.1,0.1], inf), -4, inf).asStream;


(
~volca_kit.events = [
	(instrument:\oneshot, buf:~bufs[\volca_kik], amp:0.5),
	(instrument:\oneshot, buf:~bufs[\volca_sn], amp:0.1),
	(instrument:\oneshot, buf:~bufs[\volca_clav], amp:0.1, pan: -0.3),
	(instrument:\oneshot, buf:~bufs[\volca_hitom], amp:0.0, pan: 0.3),
	(instrument:\oneshot, buf:~bufs[\volca_ch], amp:0.1)
];
)

(
~volca_kit.matrix = [
	[ 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0 ],
	[0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0],
	[ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0 ]
];
)




/////////////////////////////////
// play
~volcakit[\snd] = ~volca_kit.player;

(~volcakit[\snd][4] = \filter -> {arg in;

	var input, numsamp, power;
	var sig = in;

	sig = Decimator.ar(sig, 44100/8, 19);//}.dup(4).sum;
    numsamp = 300;
	power = 4;//SinOsc.kr(1/4).range(0.1, 4);
	//sig = RunningSum.ar(sig ** power, numsamp)/numsamp) ** (power.reciprocal);
	sig = RunningSum.rms(sig, 1);
	sig = FreqShift.ar(sig, 200);

	sig;
});

(~volcakit[\snd][6] = \filter -> {arg in; GVerb.ar(in, roomsize:100, revtime:30)})
(~volcakit[\snd][8] = \filter -> {arg in; DelayC.ar(in, (90/60) * (1.5/4), (90/60) * (1.5/4))})
~volcakit[\snd].set(\wet4, 0.0, \wet6, 0.1, \wet8, 0.0)

~volcakit[\snd].vol = 1;
~volcakit[\snd].play;
~volcakit[\snd].stop

// cool rhythm
[ [ 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0 ], [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0 ] ]



TempoClock.default.tempo_(90/60)

App.recordWorkspace("ws4");
s.stopRecording

App.defaultOut(s);
App.soundflowerOut(s);



NeuralNet

MIDIFile


m = SimpleMIDIFile()
m.noteSustainEvents


(

a = Pbind(

	\freq, Pshuf([203, 490, 231, 764, 234], inf),

	\dur, Pshuf([0.5, 0.5, 1.0, 0.25, 0.125, 0.5], inf)

);

)

(

a = Ptuple([
	Pseq([ 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0 ], inf),
	Pseq([0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0], inf),
	Pseq([ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], inf) ,
	Pseq([ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], inf) ,
	Pseq([ 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0 ], inf)
], inf);

m = MarkovSet.fill(20, Pevent(a, Event.default).asStream);

)

m.


m.dict.keysValuesDo { |key, val| postf("key: %\t\tvalue: %\n", key, val) }; ""



// compare:

b = Pchain(Pfsm2(m), (instrument: \mark));

c = Pchain(a, (instrument: \mark));



Ppar([b, c]).play;





