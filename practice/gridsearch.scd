(
b = Buffer.read(s, "/Users/dmorgan/supercollider/audio/practice/3.mono.aiff");
)

(
SynthDef(\buf_grain, {arg amp = 1, len = 0.1, sndbuf, rate = 1, pos = 0.5, atk = 0.01, sustain = 0.1, pan = 0;

	var env = EnvGen.kr(Env.perc(atk, sustain), levelScale:amp, doneAction:2);
	var sig = GrainBuf.ar(2, Impulse.kr(1), len, sndbuf, rate, pos, 4, 2);
	sig =  BPF.ar(sig, 1760, 1);
	sig = sig * env;
	OffsetOut.ar(0, Pan2.ar(sig, pan));

}).add;

SynthDef(\bass, {arg freq = 55, phase = 0, atk = 0.01, sustain = 1, amp = 1, drive=2.0, post=1.0, pan=0;

	var env = EnvGen.kr(Env.perc(atk, sustain), levelScale:amp, doneAction:2);
	var sig = FSinOsc.ar(freq, phase);
	sig = sig + LFSaw.ar(freq, 0.5pi, 0.07);
	sig = (sig * drive ).softclip * post;
	sig = sig * env;
	OffsetOut.ar(0, Pan2.ar(sig, pan));
}).add;

SynthDef(\wn_resonaz, {arg ffreq = 440, bwr = 0.1, atk = 0.01, sustain = 1, pan = 0, amp = 1;

	var env = EnvGen.kr(Env.perc(atk, sustain), levelScale:amp, doneAction:2);
	var sig = WhiteNoise.ar;
	sig = Resonz.ar(sig, ffreq, bwr).tanh;
	sig = sig * env;
	OffsetOut.ar(0, Pan2.ar(sig, pan));

}).add;

SynthDef(\thwick, {arg trig=1.0,sfreqScale=1.0,sfreqOffset=0.0,stimeScale=1.0,foldAt=0.1, pan=0, atk=0.01, sustain=1, amp=1;

	var env = EnvGen.kr(Env.perc(atk, sustain, curve:-4), levelScale:amp, doneAction:2);
	var sig = Instr("klankperc.impulse.thwick").ar(trig, sfreqScale, sfreqOffset, stimeScale, foldAt);
	sig = sig * env;
	OffsetOut.ar(0, Pan2.ar(sig, pan));
}).add;

)

(
~track = (

	track_reset: {arg self;
		Pdef.removeAll;
		Pdef.all;
	},
	track_new: {arg self, key, event;

		var id = key.asSymbol;
		Pdef(id).clear();

		{
			var track = (
				track_id: id,
				track_event: event,
				track_cue: {arg self, parms;
					var beats = parms.value(self.track_event);
					Psync(Pdef(self.track_id, Pbind(*self.track_event.getPairs())), beats, beats);
				},
				track_player: {arg self, seq;
					var funcs = Pseq(seq, 1).asStream;
					Spawner({arg sp;

						var func = funcs.next();
						while( { func.isNil.not }, {
							sp.seq(self.track_cue ( func ) );
							func = funcs.next();
						});
						postf("% done.", id);
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
		bass
		**********************/
		var bass = ~track.track_new("bass", (
			\instrument: \bass,
			\freq: [55,56],
			\sustain: 0.5,
			\dur: Pxrand([0.25, 0.25, Rest(0.25)], inf),
			\pan: Pwhite(-1, 1, inf),
			\amp: Pwhite(0.3, 0.5, inf),
			\phase: 0.5pi,
			\drive: 1.5,
			\atk: 0
		));
		var bass_player = bass.track_player([
			{arg event;
				event.amp = 0;
				4;
			},
			{arg event;
				event.amp = Pwhite(0.3, 0.5, inf);
				76;
			}
		]);

		/*********************
		noise
		**********************/
		var noise = ~track.track_new("noise", (
			instrument: \buf_grain,
			dur: 0.25,
			sndbuf: b,
			amp: 1,
			len: Pwhite(0.001, 0.1, inf),
			rate: Pxrand([1.5, 2.5, 3.5, 5.5, 6.5], inf),
			pos: Pxrand([0.3, 0.7], inf),
			atk: 0,
			sustain: 0.15
		));
		var noise_player = noise.track_player([
			{arg event;
				68;
			},
			{arg event;
				event.dur = Pxrand([0.21, 0.11, 0.35], inf);
				event.sustain = Pwhite(0.1, 0.7, inf);
				12;
			}
		]);

		/*********************
		white noise
		**********************/
		var wn = ~track.track_new("wn", (
			instrument: \wn_resonaz,
			ffreq: [440,880],
			sustain: Pwhite(0.001, 0.01, inf),
			bwr: Pwhite(0.008, 0.01, inf),
			dur: Pxrand([0.25, 0.25, Rest(0.25)], inf),
			pan: Pwhite(-1, 1, inf),
			amp: Pwhite(2, 4, inf),
			atk: 0.1
		));
		var wn_player = wn.track_player([
			{arg event;
				event.amp = 0;
				20;
			},
			{arg event;
				event.amp = Pwhite(2, 4, inf);
				64;
			}
		]);

		/*********************
		thwick
		**********************/
		var thwick = ~track.track_new("thwick", (
			instrument: \thwick,
			dur: Pn(1, inf)
		));
		var thwick_player = thwick.track_player([
			{arg event;
				event.amp = 0;
				32;
			},
			{arg event;
				event.amp = 10;
				event.dur = Pseq( (0.0625!4) ++ Prand([0.25, Rest(0.25)], 12) ++ (0.125!6) );
				4;
			},
			{arg event;
				event.dur = Pn(1, inf);
				event.amp = 10;
				28;
			},
			{arg event;
				event.dur = Pseq( (0.0625!4) ++ (0.25!12) ++ (0.125!6), 1);
				4;
			},
			{arg event;
				event.dur = Pn(1, inf);
				8;
			},
			{arg event;
				event.dur = Pseq( (0.125!6) ++ (0.25!12) ++ (0.0625!4), 1);
				4;
			}
		]);

		/*********************
		clap
		**********************/
		var clap = ~track.track_new("clap", (
			instrument: \clap1,
			amp: 0.5,
			dur: Pseq([Rest(1), 1], inf)
		));
		var clap_player = clap.track_player([
			{arg event;
				event.amp = 0;
				36;
			},
			{arg event;
				event.amp = 0.5;
				48;
			}
		]);

		noise_player.play(self.tempo);
		bass_player.play(self.tempo);
		wn_player.play(self.tempo);
		thwick_player.play(self.tempo);
		clap_player.play(self.tempo);
	};

	s.waitForBoot({
		r{
			//s.prepareForRecord('/Users/dmorgan/supercollider/audio/practice/inst4_5.aiff');
			//s.record();
			//s.stopRecording();
			app.main();
		}.play;
	});
}.value;

);
