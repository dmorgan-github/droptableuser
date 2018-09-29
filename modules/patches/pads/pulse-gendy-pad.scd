(
SynthDef(\pulse_pad, {

	var freq = Vibrato.kr(\freq.kr(432), \vrate.kr(6), \vdepth.kr(0.01));

	var env = Env.linen(
		\atk.kr(0.01),
		\sus.kr(0),
		\rel.kr(1),
		curve:\cub
	).kr(doneAction:Done.freeSelf);

	var osc1 = {arg i;
		var sig = Pulse.ar(freq * LFNoise2.kr(1/16).range(0.99, 1.01) * [1,2].choose,
			width: LFNoise2.kr(1/8).range(0.3, 0.7));
		var cutoff = \osc1_cutoff.kr(2200);
		var res = \osc1_res.kr(0.1);
		{ sig = SVF.ar(sig, cutoff, res) }.dup(2);
		sig;
	};

	var osc2 = {
		var sig = Gendy2.ar(minfreq:freq, maxfreq:freq);
		var cutoff = \osc2_cutoff.kr(2200);
		var res = \osc2_res.kr(0.1);
		{ sig = SVF.ar(sig, cutoff, res) }.dup(2);
		sig;
	};

	var sig = [
		osc1.dup(4).sum * \osc1_vol.kr(1),
		osc2.() * \osc2_vol.kr(0.07)
	].sum;

	sig = IIRFilter.ar(sig, \cutoff.kr(2200), \rq.kr(1));

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-20.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;
)


/////////////////////////////////////////
// ui
(
var specs = (
	\pulse_pad_osc1_vol: [0, 1, \lin, 0, 0.dbamp, "osc1_vol"],
	\pulse_pad_osc2_vol: [0, 1, \lin, 0, 0.dbamp, "osc2_vol"],
	\pulse_pad_osc1_cutoff: [20, 20000, \exp, 0, 2200, "osc1_cutoff"],
	\pulse_pad_osc1_res: [0.001, 1, \lin, 0, 0.1, "osc1_res"],
	\pulse_pad_osc2_cutoff: [20, 20000, \exp, 0, 2200, "osc2_cutoff"],
	\pulse_pad_osc2_res: [0.001, 1, \lin, 0, 0.1, "osc2_res"],
	\pulse_pad_vrate: [0, 6, \lin, 0, 6, "vrate"],
	\pulse_pad_vdepth: [0, 1, \lin, 0, 0, "vdepth"],
	\pulse_pad_cutoff: [20, 20000, \exp, 0, 2200, "cutoff"],
	\pulse_pad_rq: [0.001, 1, \lin, 0, 1, "rq"]
);

var view = View().layout_(VLayout()).minWidth_(400);
specs.keysValuesDo({arg k, v;
	var slider;
	var default = if (Pdefn(k).pattern.isNil.not) {
		Pdefn(k).pattern;
	}{
		v.asSpec.default;
	};
	var nb = NumberBox().value_(default).maxWidth_(50);
	view.layout.add(
		HLayout(
			StaticText().string_(v.asSpec.units),
			slider = Slider().orientation_(\horizontal)
			.action_({arg ctrl;
				var val = v.asSpec.map(ctrl.value);
				nb.value_(val);
				Pdefn(k, val)
			}).maxWidth_(200)
			.value_(v.asSpec.unmap(default)),
			nb.action_({arg ctrl;
				var val = v.asSpec.unmap(ctrl.value);
				slider.valueAction_(val);
			})
		);
	);
});
view.front;
)

/////////////////////////////////////////
// pattern

Pdef(\pulse_pad).clear;
(
var shared = Pbind(
	\amp, Pdefn(\pulse_pad_amp, 0.dbamp),
	\pan, Pdefn(\pulse_pad_pan, 0),
	\vrate, Pdefn(\pulse_pad_vrate, 6),
	\vdepth, Pdefn(\pulse_pad_vdepth, 0.01),
	\cutoff, Pdefn(\pulse_pad_cutoff, 22000),
	\rq, Pdefn(\pulse_pad_rq, 1),

	\osc1_cutoff, Pdefn(\pulse_pad_osc1_cutoff, 2200),
	\osc1_res, Pdefn(\pulse_pad_osc1_res, 0.1),

	\osc2_cutoff, Pdefn(\pulse_pad_osc2_cutoff, 2200),
	\osc2_res, Pdefn(\pulse_pad_osc2_res, 0.1),

	\osc1_vol, Pdefn(\pulse_pad_osc1_vol, 1),
	\osc2_vol, Pdefn(\pulse_pad_osc2_vol, 0.07),
);
Pdef(\pulse_pad, Ppar([
	Pbind(\instrument, \pulse_pad,
		\freq, Prand(['G#3', 'C#3'].namecps * 0.5, inf),
		\beatDur, Pfunc({thisThread.clock.beatDur}),
		\atk, 6 * Pkey(\beatDur) * 2,
		\rel, 6 * Pkey(\beatDur) * 2,
		\dur, 12 * 2,
	) <> shared,
	Pbind(\instrument, \pulse_pad,
		\freq, Prand(['F#3', 'B3'].namecps * 0.5, inf),
		\beatDur, Pfunc({thisThread.clock.beatDur}),
		\atk, 4 * Pkey(\beatDur) * 2,
		\rel, 5 * Pkey(\beatDur) * 2,
		\dur, 10 * 2,
	) <> shared,
	Pbind(\instrument, \pulse_pad,
		\freq, Prand(['A3', 'D#3'].namecps * 0.5, inf),
		\beatDur, Pfunc({thisThread.clock.beatDur}),
		\atk, 5 * Pkey(\beatDur) * 2,
		\rel, 5 * Pkey(\beatDur) * 2,
		\dur, 11 * 2,
	) <> shared
]))
)

/////////////////////////////////////////
// pulse_pad
~p[\pulse_pad].clear;
~p[\pulse_pad].mold;
~p[\pulse_pad][0] = Pdef(\pulse_pad);
(~p[\pulse_pad].filter(2, {arg in;
	var fx = in;
	AdCVerb2.ar(fx);
}).set(\wet2, 0.2))

~p[\pulse_pad].play(vol:-30.dbamp);
~p[\pulse_pad].stop(fadeTime:10);