(
SynthDef(\thwick, {arg trig=1.0,sfreqScale=1.0,sfreqOffset=0.0,stimeScale=1.0,foldAt=0.1, pan=0, atk=0.01, sustain=1, amp=1;

	var env = EnvGen.kr(Env.perc(atk, sustain, curve:-4), levelScale:amp, doneAction:2);
	var sig = Instr("klankperc.impulse.thwick").ar(trig, sfreqScale, sfreqOffset, stimeScale, foldAt);
	sig = sig * env;
	OffsetOut.ar(0, Pan2.ar(sig, pan));
}).add;

SynthDef(\kick1, {arg out = 0, pan = 0, amp=1;

	var env1 = Env([390, 59, 29], [0.05, 0.29], [-4, -5]);
    var envgen = EnvGen.ar(env1);

	var env = EnvGen.kr(Env.perc(0,1, amp), doneAction:2);
	var sig = LPF.ar( Ringz.ar( Impulse.ar(0), 60, 0.5 ), 500 ) + SinOsc.ar(envgen, 0.5pi);
	var cmp = CompanderD.ar(sig, thresh: -20.dbamp, slopeBelow: 1, slopeAbove: 0.3, clampTime: 0.003, relaxTime: 0.08);
    sig = (cmp * (10.dbamp * 0.25)) ! 2;
	OffsetOut.ar(out, Pan2.ar(sig * env, pan));

}).add;

SynthDef(\buf_grain, {arg amp = 1, len = 0.1, sndbuf, rate = 1, pos = 0.5, atk = 0.01, sustain = 0.1, pan = 0;

	var buf = Buffer.read(s, "/Users/dmorgan/supercollider/audio/practice/3.mono.aiff");
	var env = EnvGen.kr(Env.perc(atk, sustain), levelScale:amp, doneAction:2);
	var sig = GrainBuf.ar(2, Impulse.kr(1), len, buf, rate, pos, 4, 2);
	sig =  BPF.ar(sig, 1760, 1);
	sig = sig * env;
	OffsetOut.ar(0, Pan2.ar(sig, pan));

}).add;

SynthDef(\hat1, {arg out=0, freq=230, hpf=6500, release=0.15, amp=1, fxb=0, fxv=0, bbcb=0, bbcv=0;
    var pulse, sig, env, freqs;
    freqs = [freq, freq * 1.4471, freq * 1.617, freq * 1.9265, freq * 2.5028, freq * 2.6637];
    pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 0.15));
    sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
    env = EnvGen.kr(Env.perc(0, release), doneAction:2);
    sig = sig*env;
    Out.ar(out, Pan2.ar(sig * amp, 0));
}).add;

SynthDef(\clap1, {arg outBus=0, amp = 0.3;

	var env1, env2, out, noise1, noise2;

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	out = noise1 + noise2;
	out = out * 2;
	out = out.softclip * amp * 0.75;

	Out.ar(outBus, out.dup);
}).add;

);

(
~track = (

	track_reset: {arg self;
		Pdef.removeAll;
		Pdef.all;
	},

	track_rand: {arg self, seq, repeat;
		{ Prand(seq, repeat) };
	},

	track_seq: {arg self, seq, repeat;

		var f = seq;
		if (f.isKindOf(Event)) {
			f = {seq};
		};

		{ Pseq([f], repeat) };
	},

	track_new: {arg self, key, event, step;

		var id = key.asSymbol;
		Pdef(id).clear();
		{
			var track = (

				track_id: id,
				track_event: event,
				track_sections: {arg self, sections;
					var seq = Pseq(sections, 1);
					self.track_spawn(seq.asStream);
				},
				track_play: {arg self;

					Spawner({arg sp;
						sp.par( Pdef(self.track_id, Pbind(*self.track_event.getPairs())) )
					});
				},
				track_spawn: {arg self, sections;

					Spawner({arg sp;

						var sec = sections.next();
						while ( {sec.isNil.not}, {

							var events = sec.value.asStream;
							var next = events.next();
							while({next.isNil.not}, {

								var evt = self.track_event.copy();
								next.value.keysValuesDo({arg key, value;
									evt.put(key, value);
								});
								sp.seq ( Psync(Pdef(self.track_id, Pbind(*evt.getPairs())), step, step) );
								next = events.next();
							});
							sec = sections.next();
						});
					});
				}
			);
			track;
		}.value;
	}
);

{
	var app = app ? ();
	app.tempo = TempoClock(120/60);
	app.main = {arg self;

		/*********************
		track1
		**********************/

		var rhythm = [
			{ (instrument: \kick1, amp:1) },
			{ (instrument: \kick1, amp:1) },
			{ (instrument: \thwick, amp:2) },
			{ (instrument: \thwick, amp:2) },
			{ (instrument: \buf_grain, rate: 1.5, pos: 0.3, len:0.01,
				amp:1,
				atk: 0,
				sustain: 0.15,
				dur:Pxrand([0.125, 0.25], inf))},
			{ (instrument: \buf_grain, rate: 5.5, pos: 0.5, len:0.02, amp:1, atk: 0, sustain: 0.15)}
		];

		var track1 = ~track.track_new("track1", (
			dur: Pn(0.25, inf),
			pan:Pwhite(-1, 1, inf),
			amp:1
		), 0.25);

		var tp1 = track1.track_sections([
			~track.track_rand(rhythm, 16),
			~track.track_seq( (amp:0) , 4),
			~track.track_rand(rhythm, 16),
			~track.track_seq( (amp:0) , 6),
			~track.track_rand(rhythm, 128)
		]);

		var track2 = ~track.track_new("track2", (
			instrument: \buf_grain,
			dur: 0.25,
			amp:0.5,
			len: Pwhite(0.001, 0.1, inf),
			rate: Pxrand([1.5, 2.5, 3.5, 5.5, 6.5], inf),
			pos: Pxrand([0.3, 0.7], inf),
			atk: 0,
			sustain: 0.15
		), 0.25);

		var tp2 = track2.track_sections([
			~track.track_seq( (amp:0.3), 16),
			~track.track_seq( (amp:0), 4),
			~track.track_seq( (amp:0.3), 16),
			~track.track_seq( (amp:0), 6),
			~track.track_seq( (amp:0.3), 128),
		]);

		var track3 = ~track.track_new("track3", (
			instrument: \clap1,
			amp: 0.5,
			dur: Pseq([Rest(1), 1], inf)
		), 2);

		var tp3 = track3.track_sections([
			~track.track_seq(  (amp:0) , 10 ),
			~track.track_seq(  (amp:0.5) , 12 )
		]);

		var track4 = ~track.track_new("track4", (
			instrument: \thwick,
			dur: Pseq( (0.0625!4) ++ (0.25!12) ++ (0.125!6), 1)
		), 4);

		var tp4 = track4.track_sections([
			~track.track_seq((amp:0), 4),
			~track.track_seq((amp:4), 1),
			~track.track_seq((amp:4, dur:Pn(0.5,2)), 1)
		]);

		tp1.play(self.tempo);
		tp2.play(self.tempo);
		tp3.play(self.tempo);
		tp4.play(self.tempo)
	};

	s.waitForBoot({
		r{
			app.main();
		}.play;
	});
}.value;

);



