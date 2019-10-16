/////////////////////////////////////////
// synth
(
SynthDef(\subtrsynth, {

	var gate = \gate.kr(1);
	var numvoices = 2;
	var ddepth = \ddepth.kr(0.1);
	var drate = \drate.kr(0.1);
	var detune = LFNoise2.ar(drate.dup(numvoices)).bipolar(ddepth).midiratio;
    var freq = \freq.ar(261);

	var fm = {arg freq;
		var index = \index.kr(0);
		var ivel = \ivel.kr(0.1);
		var idur = \idur.kr(0.1);
		var ratio = \ratio.kr(2);
		var iline = Line.ar(index, index * ivel, idur) * freq * ratio;
		var mod = SinOsc.ar(freq * ratio) * iline;
		mod;
	};

    var adsr = {
		var da = Done.freeSelf;
        var atk = \atk.kr(0.01);
		var dec = \dec.kr(0.1);
        var rel = \rel.kr(0.1);
        var curve = \curve.kr(-4);
		var suslevel = \suslevel.kr(0.5);
		var ts = \ts.kr(1);
		var env = Env.adsr(atk, dec, suslevel, rel, curve:curve).ar(doneAction:da, gate:gate, timeScale:ts);
        env;
    };

    var filter = {arg sig, aeg, cutoff=1200, vel=1, res=0, freqamt=0, curve=(-4);
		var famt = \freqamt.kr(freqamt);
		var ffreq = \cutoff.kr(cutoff) + (freq * famt);
        var fvel = max(\fvel.kr(vel), 0.001);
		var fcurve = K2A.ar(\fcurve.kr(curve));
		var fres = \res.kr(res);
		var feg = aeg.lincurve(0, 1, ffreq, ffreq * fvel, curve:fcurve).clip(20, 20000);
		//var feg = Env.perc(0.01, \dec.kr, fcurve).kr(gate:trig, timeScale:\ts.kr(1))
		//.linlin(0, 1, ffreq, ffreq * fvel).clip(20, 20000);
		//var feg = Env([ffreq, ffreq, ffreq * fvel], [0, \dec.kr], fcurve).kr(gate:trig).clip(20, 20000);

		sig = MoogFF.ar(sig, feg, fres.linlin(0, 1, 0, 4)) * 4;
		//sig = MoogLadder.ar(sig, feg, fres) * 4;
		//sig = MoogVCF.ar(sig, feg, res);
		//sig = SVF.ar(sig, feg, fres, 1, 1, 0, 1, 0);
		//sig = DFM1.ar(sig, feg, fres.clip(0.001, 1.0)) * 1;
		//sig = RLPF.ar(sig, feg, (1-fres).clip(0.001, 1.0));
		//sig = BLowPass4.ar(sig, feg, (1-fres).clip(0.001, 1.0));
		//sig = BLowPass.ar(sig, feg, (1-fres).clip(0.001, 1.0));
        sig;
    };

    var tri = {arg freq;
		var sig = VarSaw.ar(freq, 0, \triwidth.ar(0.5));
        sig * AmpCompA.kr(freq);
    };

	var saw = {arg freq;
		//var sig = Saw.ar(freq);
		var timbre = \sawtimbre.ar(0);
		var sig = SyncSaw.ar(freq, freq + timbre);
        sig * AmpCompA.kr(freq);
    };

	var square = {arg freq;
		var sig = Pulse.ar(freq, \squarewidth.ar(0.5));
        sig * AmpCompA.kr(freq);
    };

	var sine = {arg freq;
		var mod = fm.(freq) * \sinefm.kr(0);
		var sig = SinOsc.ar(freq + mod);
        sig * AmpCompA.kr(freq);
    };

	var noise = {
		var sig = WhiteNoise.ar;
		sig;
	};

	var aeg = adsr.();

	var sig = [
		tri.(freq * detune * \trifreqmul.kr(1)) * \tri.kr(1),
		saw.(freq * detune * \sawfreqmul.kr(2)) * \saw.kr(0.2),
		square.(freq * detune * \squarefreqmul.kr(4)) * \square.kr(0.1),
		sine.(freq * detune * \sinefreqmul.kr(1)) * \sine.kr(0.2),
		noise.() * \noise.kr(0)
	].sum;
    sig = sig * aeg * \vel.kr(1);
    sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	sig = LeakDC.ar(sig);

	sig = filter.(sig, aeg);
    sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	sig = sig * \amp.kr(-3.dbamp);
	Out.ar(\out.kr(0), sig);

}, metadata:(
	specs:(
		ddepth: ControlSpec(0, 1, \lin, 0, 0.1),
		drate: ControlSpec(0.0, 1.0, \lin, 0, 0.1),
		freq: \freq.asSpec,
		index: ControlSpec(0, 100, \lin, 0.0, 1),
		ivel: ControlSpec(0, 100, \lin, 0, 1),
		idur: ControlSpec(0, 1, \lin, 0, 1),
		ratio: ControlSpec(0, 100, \lin, 0, 1),
		atk: ControlSpec(0, 1, \lin, 0, 0.01),
		dec: ControlSpec(0, 1, \lin, 0, 0.2),
		rel: ControlSpec(0, 1, \lin, 0, 0.29),
		suslevel: ControlSpec(0, 1, \lin, 0, 0.7),
		curve: ControlSpec(-24, 24, \lin, 0, -4),
		ts: ControlSpec(0, 100, \lin, 0, 1),
		freqamt: ControlSpec(0, 4, \lin, 0, 0),
		cutoff: ControlSpec(20, 20000, 'exp', 0, 100),
		fvel: ControlSpec(0, 100, \lin, 0, 10),
		fcurve: ControlSpec(-24, 24, \lin, 0, -4),
		res: ControlSpec(0, 1, \lin, 0, 0.5),
		triwidth: ControlSpec(0, 1, \lin, 0, 0.5),
		sawtimbre: ControlSpec(0, 1, \lin, 0, 0.1),
		squarewidth: ControlSpec(0, 1, \lin, 0, 0.5),
		sinefm: ControlSpec(0, 1, \lin, 0, 0),
		trifreqmul: ControlSpec(0, 12, \lin, 0, 1),
		tri: ControlSpec(0, 1, \lin, 0, 1),
		sawfreqmul: ControlSpec(0, 12, \lin, 0, 1),
		saw: ControlSpec(0, 1, \lin, 0, 0),
		squarefreqmul: ControlSpec(0, 12, \lin, 0, 1),
		square: ControlSpec(0, 1, \lin, 0, 0),
		sinefreqmul: ControlSpec(0, 12, \lin, 0, 1),
		sine: ControlSpec(0, 1, \lin, 0, 0),
		noise: ControlSpec(0, 1, \lin, 0, 0),
		pre: ControlSpec(0, 1, \lin, 0, 1),
		vel: ControlSpec(0, 1, \lin, 0, 1),
		spread: ControlSpec(0, 1, \lin, 0, 1),
		center: ControlSpec(0, 1, \lin, 0, 0),
		pan: ControlSpec(-1, 1, \lin, 0, 0),
		amp: \amp.asSpec
	)
)).add;
)

/////////////////////////////////////////
// base pattern
(
Pdef(\subtrsynthbase, {arg evt, ndef, monitor=true;
	var metadata = SynthDescLib.global.at(\subtrsynth).metadata;
	var specs = metadata[\specs];
	var node = Ndef(ndef);
	if (node.isMonitoring.not and: monitor){
		node.play;
	};
	Penvir(evt,
		Pbind(
			\instrument, \subtrsynth,
			\out, Pfunc({node.bus.index}),
			\group, Pfunc({node.group}),

			// filter
			\cutoff, Pif(Pfunc({~cutoff.isNil}), specs[\cutoff].default, Pfunc({~cutoff})),
			\fvel, Pif(Pfunc({~fvel.isNil}), specs[\fvel].default, Pfunc({~fvel})),
			\fcurve, Pif(Pfunc({~fcurve.isNil}), specs[\fcurve].default, Pfunc({~fcurve})),
			\res, Pif(Pfunc({~res.isNil}), specs[\res].default, Pfunc({~res})),
			\freqamt, Pif(Pfunc({~freqamt.isNil}), specs[\freqamt].default, Pfunc({~freqamt})),

			// detune
			\ddepth, Pif(Pfunc({~ddepth.isNil}), specs[\ddepth], Pfunc({~ddepth})),
			\drate, Pif(Pfunc({~drate.isNil}), specs[\drate].default, Pfunc({~drate})),

			// env
			\atk, Pif(Pfunc({~atk.isNil}), specs[\atk].default, Pfunc({~atk})) * Pkey(\dur),
			\dec, Pif(Pfunc({~dec.isNil}), specs[\dec].default, Pfunc({~dec})) * Pkey(\dur),
			\sustain, Pif(Pfunc({~sustain.isNil}), 0.5, Pfunc({~sustain})) * Pkey(\dur),
			\rel, Pif(Pfunc({~rel.isNil}), specs[\rel].default, Pfunc({~rel})) * Pkey(\dur),
			\suslevel, Pif(Pfunc({~suslevel.isNil}), specs[\suslevel].default, Pfunc({~suslevel})),
			\ts, Pif(Pfunc({~ts.isNil}), specs[\ts].default, Pfunc({~ts})),

			// triangle
			\tri, Pif(Pfunc({~tri.isNil}), specs[\tri].default, Pfunc({~tri})),
			\trifreqmul, Pif(Pfunc({~trifreqmul.isNil}), specs[\trifreqmul].default, Pfunc({~trifreqmul})),
			\triwidth, Pif(Pfunc({~triwidth.isNil}), specs[\triwidth].default, Pfunc({~triwidth})),

			// saw
			\saw, Pif(Pfunc({~saw.isNil}), specs[\saw].default, Pfunc({~saw})),
			\sawfreqmul, Pif(Pfunc({~sawfreqmul.isNil}), specs[\sawfreqmul].default, Pfunc({~sawfreqmul})),
			\sawtimbre, Pif(Pfunc({~sawtimbre.isNil}), specs[\sawtimbre].default, Pfunc({~sawtimbre})),

			// square
			\square, Pif(Pfunc({~square.isNil}), specs[\square].default, Pfunc({~square})),
			\squarefreqmul, Pif(Pfunc({~squarefreqmul.isNil}), specs[\squarefreqmul].default, Pfunc({~squarefreqmul})),
			\squarewidth, Pif(Pfunc({~squarewidth.isNil}), specs[\squarewidth].default, Pfunc({~squarewidth})),

			// noise
			\noise, Pif(Pfunc({~noise.isNil}), specs[\noise].default, Pfunc({~noise})),

			// sine
			\sine, Pif(Pfunc({~sine.isNil}), specs[\sine].default, Pfunc({~sine})),
			\sinefreqmul, Pif(Pfunc({~sinefreqmul.isNil}), specs[\sinefreqmul].default, Pfunc({~sinefreqmul})),
			\sinefm, Pif(Pfunc({~sinefm.isNil}), specs[\sinefm].default, Pfunc({~sinefm})),

			// fm
			\index, Pif(Pfunc({~index.isNil}), specs[\index].default, Pfunc({~index})),
			\ivel, Pif(Pfunc({~ivel.isNil}), specs[\ivel].default, Pfunc({~ivel})),
			\idur, Pif(Pfunc({~idur.isNil}), specs[\idur].default, Pfunc({~idur})),
			\ratio, Pif(Pfunc({~ratio.isNil}), specs[\ratio].default, Pfunc({~ratio}))
		)
	)
})
)

/////////////////////////////////////////
// ui
(
~subtrsynthui = {arg envir, name;

	var metadata = SynthDescLib.global.at(\subtrsynth).metadata;
	var specs = metadata[\specs];
	var font = Font("Courier New", 10);
	var ezknob = {arg key, label;

		var knob = Knob();
		var nb = NumberBox();
		var controlSpec = specs[key];
		var myval = envir[key] ?? controlSpec.default;
		envir[key] = myval;

		VLayout(
			knob
			.action_({arg ctrl;
				var val = controlSpec.map(ctrl.value);
				nb.valueAction_(val);
			})
			.centered_(true)
			.mode_(\vert)
			.value_(controlSpec.unmap(myval))
			.mouseDownAction_({arg ctrl, x, y, mod, button, clickCount;
				if (clickCount == 2){
					knob.value = controlSpec.map(controlSpec.default);
					nb.value = controlSpec.default;
				}
			}),
			nb
			.font_(font)
			.maxWidth_(35)
			.maxHeight_(20)
			.action_({arg ctrl;
				envir[key] = ctrl.value;
				knob.value = controlSpec.unmap(envir[key]);
			})
			.clipLo_(controlSpec.minval)
			.clipHi_(controlSpec.maxval)
			.value_(myval),
			StaticText()
			.string_(label)
			.font_(font)
			.align_(\center)
		)
		.margins_(0)
		.spacing_(0)
	};

	var view = View().name_(name).layout_(VLayout().margins_(1).spacing_(1))
	.palette_(QPalette.light);

	var filterView = View().layout_(VLayout(
		StaticText().string_("filter").font_(font),
		HLayout(
			ezknob.(\cutoff, \cutoff),
			ezknob.(\fvel, \vel),
			ezknob.(\fcurve, \curve),
			ezknob.(\res, \res),
			ezknob.(\freqamt, \freqamt),
			nil
		)
	).margins_(2).spacing_(2))
	.background_(Color.grey.alpha_(0.2));

	var detuneView = View().layout_(VLayout(
		StaticText().string_("detune").font_(font),
		HLayout(
			ezknob.(\ddepth, \ddepth),
			ezknob.(\drate, \drate),
			nil
		)
	).margins_(2).spacing_(2));

	var triView = View().layout_(VLayout(
		StaticText().string_("triangle").font_(font),
		HLayout(
			ezknob.(\tri, \tri),
			ezknob.(\trifreqmul, \freqmul),
			ezknob.(\triwidth, \width),
			nil
		)
	).margins_(2).spacing_(2))
	.background_(Color.grey.alpha_(0.2));

	var sawView = View().layout_(VLayout(
		StaticText().string_("saw").font_(font),
		HLayout(
			ezknob.(\saw, \saw),
			ezknob.(\sawfreqmul, \freqmul),
			ezknob.(\sawtimbre, \timbre),
			nil
		)
	).margins_(2).spacing_(2));

	var squareView = View().layout_(VLayout(
		StaticText().string_("square").font_(font),
		HLayout(
			ezknob.(\square, \square),
			ezknob.(\squarefreqmul, \freqmul),
			ezknob.(\squarewidth, \width),
			nil
		)
	).margins_(2).spacing_(2))
	.background_(Color.grey.alpha_(0.2));

	var sineView = View().layout_(VLayout(
		StaticText().string_("sine").font_(font),
		HLayout(
			ezknob.(\sine, \sine),
			ezknob.(\sinefreqmul, \freqmul),
			ezknob.(\sinefm, \fm),
			ezknob.(\index, \index),
			ezknob.(\ivel, \ivel),
			ezknob.(\idur, \idur),
			ezknob.(\ratio, \ratio)
		)
	).margins_(2).spacing_(2));

	var noiseView = View().layout_(VLayout(
		StaticText().string_("noise").font_(font),
		HLayout(
			ezknob.(\noise, \noise),
			nil
		)
	).margins_(2).spacing_(2))
	.background_(Color.grey.alpha_(0.2));

	var env = EnvelopeView();
	var adsr = Env([0, 1, 0.7, 0.7, 0], [0.01, 0.2, 0.5, 0.29], 0);
	var slider = Slider();
	var nb = NumberBox();
	var envView = View().layout_(VLayout(
		env.setEnv(adsr)
		.action_({arg ctrl;
			var times = ctrl.asEnv.times;
			var levels = ctrl.asEnv.levels;
			var sel = ctrl.selection[0];
			var atk, dec, sustain, rel, suslevel;

			// this is broken
			if (sel == 2) {
				var y = ctrl.value[1];
				var val = y[sel];
				levels[3] = val;
				env.setEnv(Env(levels, times, 0));
			};
			if (sel == 3) {
				var y = ctrl.value[1];
				var val = y[sel];
				levels[2] = val;
				env.setEnv(Env(levels, times, 0));
			};
			envir[\atk] = times[0];
			envir[\dec] = times[1];
			envir[\sustain] = times[2];
			envir[\rel] = times[3];
			envir[\suslevel] = levels[2];
		})
		.gridOn_(false)
		.thumbSize_(15)
		.fillColor_(Color.blue)
		.gridColor_(Color.blue)
		.keepHorizontalOrder_(true),
		HLayout(
			slider
			.orientation_(\horizontal)
			.action_({arg ctrl;
				var val = specs[\ts].map(ctrl.value);
				nb.valueAction_(val);
			})
			.thumbSize_(15)
			.maxHeight_(20)
			.value_(specs[\ts].unmap(1)),
			nb
			.maxWidth_(35)
			.maxHeight_(20)
			.action_({arg ctrl;
				envir[\ts] = ctrl.value;
				slider.value = specs[\ts].unmap(ctrl.value);
			})
			.value_(1)
			.mouseDownAction_({arg ctrl, x, y, mod, button, clickCount;
				if (clickCount == 2){
					slider.value = specs[\ts].map(specs[\ts].default);
					nb.value = specs[\ts].default;
				}
			})
		)
	).margins_(2).spacing_(2));

	env.setEditable(0, false);

	view.layout.add(envView);
	view.layout.add(filterView);
	view.layout.add(detuneView);
	view.layout.add(triView);
	view.layout.add(sawView);
	view.layout.add(squareView);
	view.layout.add(sineView);
	view.layout.add(noiseView);
	view.front;
}
)