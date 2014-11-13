(
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
	var preamp = 45;
	var sig = WhiteNoise.ar;
	sig = RLPF.ar(sig, [freq, freq + 1], 0.1);
	sig = RHPF.ar(sig, freq, 10);
	sig = BPF.ar(sig, freq, 0.001);
	sig = sig * LFNoise0.kr(200, 0.5, 0.5) * preamp !2;
	Out.ar(out, sig * env);
}
).add;

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
		\sustain: 3
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

	var freqs = [48.midicps];
	var phrase = (
		\freq: Pseq(freqs, inf),
		\dur: Pseq([0.25, 0.5], inf),
		\instrument: \b,
		\amp: 1,
		\sustain: 3
	);

	var strategies = (
		parent: ~strategies,
		stats: Dictionary.new()
	);

	var transforms = Pseq([
		{arg data;
			strategies.replaceEveryNth(\freq, [4, 5, 6, 7, 9, 10].choose, {(220 * Scale.zhi.ratios).choose;}, data)
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
			sp.wait([8, 12].choose);
			next = transforms.next();
			cnt = cnt + 1;
		});
	}).play(tempo);
};

r{
	var tempo = TempoClock(10/60);
	app.process2(tempo);
	tempo.sched(12, {
		app.process1(tempo);
	})
}.play;

);

