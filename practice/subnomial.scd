(
// define synths
SynthDef(\c, {arg out, amp=0.1, freq=440, sustain=0.01, pan, click=0;

	var snd = FSinOsc.ar(freq, click * 0.5pi);
	var amp2 = AmpComp.ir(freq.max(50)) * 0.5 * amp;
	var env = XLine.ar(amp2, amp2 * 0.001, sustain, doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir ! 5).add;

SynthDef(\f, { |out, amp=0.1, freq=440, sustain=0.01, pan|
	var snd = FSinOsc.ar(freq).fold(-1,1).distort;
	var amp2 = amp * AmpComp.ir(freq.max(50)) * 0.5;
	var env = EnvGen.ar(
		Env.perc(0.1, 0.9, amp2),
			timeScale: sustain,
			doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir ! 5).add;

SynthDef(\fx, {arg out = 0, in, trig = 0, lag = 0.1, grid = 1/2;

    var sig, del;
	sig = In.ar(in,2)*0.5 + LocalIn.ar(2);
	sig = sig + GVerb.ar(sig.fold(-1, 1).softclip) * LFNoise0.ar(1, 0.1, 0.3);
    del = DelayL.ar(sig, 1.0, Lag.kr(grid, lag));
    LocalOut.ar(HPF.ar(del.reverse * (trig.clip(0, 1)), 880));
    Out.ar(out, Pan2.ar(sig[0] * 0.01, TRand.kr(-0.5, 0.5, trig)*trig));

}).add;
)

(
var app = ();
app.bps = 60/60;
app.tempo = TempoClock(app.bps);
app.main = {arg self;

	//~bus2 = Bus.audio(s,3);

	var sp;

	Pmono(\fx, *[\trig : Pwrand([0, 1, 2], [0.4, 0.3, 0.3], inf),
		\grid: Prand([1/2, 1/4, 1/8, 1/16], inf),
		\lag: Pwhite(0, 0.1, inf),
		\in: ~bus2,
		\dur: 1/8]
	).play(quant: 4);

	sp = Pspawner({arg sp;

		sp.par(
			Pbind(\instrument, \c,
				\dur, 0.015625,
				\midinote, 52,
				\click, Pxrand([0, 0.7], inf),
				\amp, 0.05
			);
		);

		sp.par(
			Ppar([
				Pbind(\instrument, \c,
					\dur, Pxrand( (0.25!8) ++ (0.125!8) ++ [Pseq([0.0625, 0.0625], 2)] , inf),
					\midinote, 88,
					\click, 1,
					\sustain, 0.001,
					\amp, Prand([0.6, 0.9], inf),
					\pan, Pwhite(-1, 1, inf)
				),
				Pbind(\instrument, \c,
					\dur, Prand( (0.5!8) ++ (0.25!8) ++ [Pseq([0.125, 0.125], 1)] , inf),
					\midinote, 45,
					\click, 0.5,
					\sustain, 0.02,
					\amp, 0.4
				)
			], inf);
		);

		sp.seq(
			Pseq([
				Ppar(Array.fill(25, {
					Pbind(\instrument, \f,
						\dur, Pseq([1, 0.25, 0.5, 2.25], 1),
						\root, Prand([28, 43, 52], inf),
						\scale, Scale.partch_o6,
						\degree, Pwhite(0, 24, inf),
						\click, Pwhite(0, 1, inf),
						\sustain, Pwhite(0.01, 0.1, inf),
						\amp, 0.2,
						\out, Prand([0, ~bus2], inf),
						\pan, Pwhite(-1, 1, inf)
					);
				}), 4),
				Pbind(\type, \rest, \dur, Pn(8, 1))
			], 3),
		);

		~events.trigger('done');

	}).play(self.tempo, quant:1);

	~events.on('done', { sp.stop();});

	nil;
};

s.waitForBoot({

	//s.prepareForRecord('/Users/dmorgan/4.aiff');
	//s.record();
	//s.stopRecording();
	app.main()
});

)

(
var win = Window("test", Rect(100,100,300, 300)).front ;
var textView = TextView(win, Rect(0,0,300, 300)) ;
textView.keyUpAction_{arg view, char, modifiers, unicode, keycode;
	switch(keycode,
		51, {
			//"delete".postln;
		}, {
			if ( (keycode >= 18) && (keycode <= 29), {
				var pb = ("pb" ++ char).asSymbol;
				Pbindef(pb).play;
			});
		}
	);
};
)