(
//~bus = Bus.audio(s,2);

~strategies = (

	fooId: 0,
	stats: Dictionary.new(),
	replaceEveryNth: {arg self, key, n, func, phrase;

		var cnt = 1;
		var pattern = phrase[key.asSymbol];
		var list = List.new();

		if (self.stats.at(key.asSymbol).isNil, {
			self.stats.put(key.asSymbol, list)
		}, {
			list = self.stats[key.asSymbol];
		});

		phrase[key.asSymbol] = Pcollect({arg val;
			var result = val;
			if (cnt % n == 0) {
				result = func.value(cnt, result);
			};
			cnt = cnt + 1;
			list.add(result);
			result;
		}, pattern);
		phrase;
	},
	onEveryNth: {arg self, n, func, phrase;

		var cnt = 1;
		var id = self.fooId = self.fooId + 1;

		id = "foo" ++ id;
		phrase[id.asSymbol] = Pfunc({arg pbind;

			if (cnt % n == 0) {
				func.value(cnt, pbind);
			};
			cnt = cnt + 1;
		});
		phrase;
	}
);
);

(
// synths
SynthDef(\b, {arg out = 0, freq = 440, amp = 1, sustain = 1;

	var amp2 = AmpComp.ir(freq.max(50)) * 0.5 * amp;
	var env = EnvGen.kr(Env.new([0.5, amp2, 0], [0.1, sustain]), doneAction:2);
	var preamp = 50;
	var sig = WhiteNoise.ar;
	sig = RLPF.ar(sig, [freq, freq + 1], 0.1);
	sig = RHPF.ar(sig, freq, 10);
	sig = BPF.ar(sig, freq, 0.001);
	sig = sig * LFNoise0.kr(200, 0.5, 0.5) * preamp !2;
	Out.ar(out, sig * env);
}
).add;

SynthDef(\c, {arg out, amp=0.1, freq=440, sustain=0.01, pan, click=0;

	var snd = FSinOsc.ar(freq, click * 0.5pi);
	var amp2 = AmpComp.ir(freq.max(50)) * 0.5 * amp;
	var env = XLine.ar(amp2, amp2 * 0.001, sustain, doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir ! 5).add;

SynthDef(\reverb_ef, {arg amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;

	var sig, verbSig, totalSig, outSig;
	mix = mix.clip(0,1);
	sig = In.ar(in, 2);
	verbSig = DelayN.ar(sig, preDel, preDel);

	totalSig = 0;
	12.do{
		verbSig = AllpassN.ar(verbSig, 0.06, {Rand(0.001,0.06)}!2, revTime);
		verbSig = LPF.ar(verbSig, 4500);
		totalSig = totalSig + verbSig;
	};

	//dry/wet mix
	totalSig = XFade2.ar(sig, totalSig, mix.linlin(0,1,-1,1));

	outSig = totalSig * amp;
	Out.ar(out, outSig);
}).add;

SynthDef(\delay, {arg out = 0, in;

    var sig = In.ar(in, 2) + LocalIn.ar(2);
    LocalOut.ar(DelayL.ar(sig, 0.5, 0.1)*0.8);
    Out.ar(out, sig);
}).add;

);

(
var app = ();
app.process1 = {arg self, tempo;

	var freqs = [68.midicps];
	var phrase = (
		\freq: Pseq(freqs, inf),
		\dur: Pseq([0.25, 0.5], inf),
		\instrument: \b,
		\amp: 1,
		\sustain: 2
	);

	var strategies = (
		parent: ~strategies,
		stats: Dictionary.new()
	);

	var transforms = Pseq([
		{arg data;
			strategies.replaceEveryNth(\freq, [4, 5, 6, 7, 9, 10].choose, {(440 * Scale.zhi.ratios).choose;}, data)
		},
		{arg data;
			var notes = strategies[\stats][\freq].as(Set).as(Array);
			strategies[\stats][\freq] = List.new();
			notes = [(notes.pyramid(2)), (notes.stutter(2))].choose;
			data[\freq] = Pseq(notes, inf);
			data;
		},
		{arg data;
			strategies.replaceEveryNth(\dur, [3, 4, 7, 8].choose, {[0.75, 1, 0.125].choose;}, data)
		}
	], inf).asStream;

	Spawner({arg sp;
		var data = phrase.copy();
		var cnt = 0;
		var next = transforms.next();
		while({next.isNil == false}, {

			data = next.value(data);
			sp.par(
				Pfindur(24, Pbind(*data.getPairs()))
			);
			sp.wait([6, 8].choose);
			next = transforms.next();
			cnt = cnt + 1;
		});
	}).play(tempo);
};

app.process2 = {arg self, tempo;

	var freqs = [88.midicps, 89.midicps, 80.midicps];
	var phrase = (
		\freq: Pseq(freqs, inf),
		\dur: Pseq([0.125, 0.125, 0.0625, 0.03125, 0.03125, 0.25], inf),
		\instrument: \c,
		\amp: 0.03,
		\sustain: 2,
		\out: ~bus
	);

	var strategies = (
		parent: ~strategies,
		stats: Dictionary.new()
	);

	var transforms = Pseq([
		{arg data;
			strategies.replaceEveryNth(\freq, [4, 5, 6, 7, 9, 10].choose, {(1220 * Scale.zhi.ratios).choose;}, data)
		},
		{arg data;
			var notes = strategies[\stats][\freq].as(Set).as(Array);
			var durs = strategies[\stats][\dur];
			if (durs.isNil == false) {
				durs.mean.postln;
			};
			strategies[\stats][\freq] = List.new();
			notes = [(notes.pyramid(2)), (notes.stutter(2))].choose;
			data[\freq] = Pseq(notes, inf);
			data;
		},
		{arg data;
			strategies.replaceEveryNth(\dur, [3, 4, 7, 8].choose, {[0.0625, 1, 0.125].choose;}, data)
		}
	], inf).asStream;

	Spawner({arg sp;

		var data = phrase.copy();
		var next = transforms.next();

		while({next.isNil == false}, {

			data = next.value(data);
			sp.par(
				Pfindur(24, Pbind(*data.getPairs()))
			);
			sp.wait([4, 6].choose);
			next = transforms.next();
		});
	}).play(tempo);
};

s.waitForBoot({

	var tempo = TempoClock(10/60);
	Synth(\reverb_ef, [\in, ~bus, \out, 0, \mix, 0.7]);
	Synth(\delay, [\in, ~bus, \out, 0]);
	//s.stopRecording();
	r{
		//s.prepareForRecord('/Users/dmorgan/5.aiff');
		//s.record();

		app.process1(tempo);
		tempo.sched(4, {
			app.process2(tempo);
		});
	}.play;
});


);
[1,2,3].mean