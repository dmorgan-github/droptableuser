/*
var start = Ndef(\start).kr(1),
	end = Ndef(\end).kr(1),
	// in the synth, '+' is analogous to 'or'
	trig = (Changed.kr(start) + Changed.kr(end)) > 0,
	gate1 = ToggleFF.kr(trig),
	gates = [gate1, 1.0 - gate1],
	// phasor ranges should update on trigger but not otherwise
	starts = Latch.kr(start, gates),
	ends = Latch.kr(end, gates),
	phasors = Phasor.ar(
		trig: 0,
		rate: Ndef(\rate).kr(1),
		start: starts,
		end: ends
	),
	bufs = BufRd.ar(1, b, phase: phasors, loop: 1),
	egs = EnvGen.kr(Env.asr(0.01, 1, 0.01), gates);
	Mix(bufs * egs).dup
*/

(
Fdef(\smplr1, {arg key, path;

	var buf = Library.at(\bufs, key);

	var load = {arg buf;

		var numChannels = buf.numChannels;
		var bufnum = buf.bufnum;
		var sampleRate = buf.sampleRate;

		Ndef(key)[0] = {

			var trig = \trig.tr(0);
			var buf = \buf.kr(bufnum);
			var rate = \rate.kr(1);
			var frames = BufFrames.kr(buf);
			var start = \start.kr(0) * frames;
			var end = \end.kr(1) * frames;
			var dur = ((end-start)/sampleRate) * rate.reciprocal;

			var hipass = {arg sig;
				var center = \hpf.ar(1200);
				var res = \hpf_res.kr(0).linlin(0,1,1,0);
				var rate = \hpf_rate.kr(1);
				var range = \hpf_range.kr(1);
				var min = center * range.reciprocal;
				var max = center * range;
				BHiPass.ar(sig, SinOsc.kr(rate).range(min, max).clip(20, 20000), res)
			};

			var lopass = {arg sig;
				var center = \lpf.ar(1200);
				var res = \lpf_res.kr(0).linlin(0,1,1,0);
				var rate = \lpf_rate.kr(1);
				var range = \lpf_range.kr(1);
				var min = center * range.reciprocal;
				var max = center * range;
				BLowPass.ar(sig, SinOsc.kr(rate).range(min, max).clip(20, 20000), res)
			};

			var phase = Env([0, start, end],[0, dur], \warp.kr(0)).ar(gate:trig);

			var sig = BufRd.ar(numChannels, buf, phase, interpolation:4);

			/*

			//var env = Env.linen(0, 1, 0).kr(gate:trig, timeScale:dur);
			sig = sig.blend(FreqShift.ar(sig, [\fshift_freq_l.kr(0), \fshift_freq_r.kr(0)]), \fshift_wet.kr(0));

			sig = sig.blend(sig ring1: SinOsc.ar(1800), \ring_wet.kr(0));

			sig = sig.blend(SoftClipAmp8.ar(sig, \pregain.kr(1)), \dist_wet.kr(0));

			sig = sig.blend(Decimator.ar(sig, \dec_rate.kr(44100), \dec_bits.kr(24)), \dec_wet.kr(0));

			*/

			sig = sig.blend(
				FbC({arg fb; fb * \del_fb.kr(0.3) + sig},
					2,
					[\del_l.kr(3/4), \del_r.kr(4/4)] * \beat_dur.kr(1)
				),
				\del_wet.kr(0)
			);

			/*
			sig = sig.blend(Squiz.ar(sig, \pitchratio.kr(2), \zcperchunk.kr(1)), \squiz_wet.kr(0));

			sig = sig.blend(lopass.(hipass.(sig)), \filt_wet.kr(0));
			*/

			sig = sig.blend(JPverb.ar(sig, \rev_t60.kr(1), 0, \rev_size.kr(1)), \rev_wet.kr(0));

			sig = sig * \amp.kr(-12.dbamp);

			Splay.ar(sig, \spread.kr(1), 1, \center.kr(0));
		};

		Pdef(key,
			Pdef(\nbind) <> (node:Ndef(key))
			<> Pbind(\buf, Pfunc({buf}))
			<> Pbind(*Ndef(key)
				.controlNames
				.reject({arg ctrl; (ctrl.name == \freq) || (ctrl.name == \trig)})
				.collect({arg ctrl; [ctrl.name, ctrl.defaultValue]}).flatten)
		)
	};

	var init = {

		if (buf.isNil) {
			Buffer.read(s, path, action:{arg buffer;
				Library.put(\bufs, key, buffer);
				load.(buffer);
			});
		} {
			if (buf.path != path) {
				if (buf.path.isNil.not) {
					buf.free;
				};
				Buffer.read(s, path, action:{arg buffer;
					Library.put(\bufs, key, buffer);
					load.(buffer);
				});
			} {
				load.(buf);
			}
		};
	};

	init.();

});
)