(
~channel = {arg id;
	var chan = (
		id: id,
		grp: Group.new,
		bus: Bus.audio(s,2),
		hasFx: false
	);
	//clean up
	CmdPeriod.doOnce({
		var bus = chan.bus;
		var out = chan.bus.subBus(1);
		var grp = chan.grp;
		"freeing buses: bus: %, out:%\n".postf(bus.index, out.index);
		bus.free;
		out.free;
		"freeing group: %\n".postf(grp);
		grp.free;
	});
	chan;
};

~synth = {arg channel, id, func;
	var synthId = channel.id ++ id;
	var bus = channel.bus;
	var grp = channel.grp;

	SynthDef(synthId, {arg out;
		var sig = SynthDef.wrap(func);
		Out.ar(out, sig);
	}).add;

	channel.plays = {arg self ... args;
		var list = args.asList;
		list.add(\out);
		list.add(bus.index);
		Synth.head(grp, synthId, list.flatten);
	};
};

~filter = {arg channel, id, func, cb;
	var synthId = channel.id ++ id;
	var fxIn = channel.bus;
	var fxOut = channel.bus.subBus(1);
	var grp = channel.grp;

	fxIn.postln;
	fxOut.postln;

	if (channel.hasFx, {
		fxIn = channel.subBus(1);
	});

	fork({

		channel[id.asSymbol] = SynthDef.new(synthId, {arg in, out;
			var sig;
			in = In.ar(in);
			sig = SynthDef.wrap(func, nil, in);
			ReplaceOut.ar(out, sig);
		}).play(grp, [\in, fxIn.index, \out, fxOut.index], addAction:\addToTail);
		s.sync;

		if (cb.notNil, {
			cb.();
		});
	});

	//channel[id.asSymbol] = SynthDef.new(synthId, {arg in, out;
	//	var sig;
	//	in = In.ar(in);
	//	sig = SynthDef.wrap(func, nil, in);
	//	Out.ar(out, sig);
	//}).play(grp, [\in, fxIn.index, \out, fxOut.index], addAction:\addToTail);

	channel.hasFx = true;
};

~mix = {arg channel;
	var in = channel.bus;
	var out = channel.bus.subBus(1);

	var synthId = channel.id ++ "mix";
	channel[\mix] = SynthDef.new(synthId, {arg inDry, inWet, out, pan = 0, dryWet = 0;
		var audio = XFade2.ar(In.ar(inDry, 1), In.ar(inWet, 1), dryWet);
		Out.ar(out, Pan2.ar(audio, pan));
	}).play(channel.grp, [\inDry, in.index, \inWet, out.index, \out, 0, \pan, 0], addAction:\addToTail);
};


/*
~chan1 = ~channel.("chan1");
~synth.(~chan1, "synth1", {arg amp = 1;
	SinOsc.ar() * EnvGen.kr(Env.perc,doneAction:2);
});
~filter.(~chan1, "fx1", {arg in, decay = 1, allpasses = 5, gain = 1;
	var source = in;
	allpasses.do({ source = AllpassN.ar(source, 0.5, [Rand(0, 0.5), Rand(0, 0.5)], decay) }; );
	source * gain;
});
~mix.(~chan1);
~chan1.plays();

~group = {arg name, func ... effects;

	var returnVal = ();
	var grp = Group.new;
	var bus, out, fxIn;
	var mixerFunc;
	bus = Bus.audio(s, 2);
	out = bus.subBus(1);
	fxIn = bus;

	"allocating buses: bus: %, out: %\n".postf(bus.index, out.index);
	returnVal.grp = grp;
	returnVal.bus = bus;

	mixerFunc = {arg inDry, inWet, out, pan = 0;
		var audio = XFade2.ar(In.ar(inDry, 1), In.ar(inWet, 1), 0);
		Out.ar(out, Pan2.ar(audio, pan));
	};

	if (effects.notNil, {

		fork({
			effects.do({arg fx;

				var fxKey = fx.key;
				var fxFunc = fx.value;
				var fxId = name ++ fxKey;

				SynthDef.new(fxId, {arg in, out;
					var sig;
					in = In.ar(in);
					sig = SynthDef.wrap(fxFunc, nil, in);
					Out.ar(out, sig);
				}).add;

				// syncronize
				s.sync;
				returnVal[fxKey.asSymbol] = Synth.tail(grp, fxId, [\in, fxIn.index, \out, out.index]);
				fxIn = out;
			});
			returnVal[\mixer] = mixerFunc.play(grp, addAction:\addToTail, args:[\inDry, bus.index, \inWet, out.index, \out, 0, \pan, 0]);
		});
	}, {
		returnVal[\mixer] = mixerFunc.play(grp, addAction:\addToTail, args:[\inDry, bus.index, \inWet, out.index, \out, 0, \pan, 0]);
	});

	CmdPeriod.doOnce({
		"freeing buses: bus: %, out:%\n".postf(bus.index, out.index);
		bus.free;
		out.free;
		"freeing group: %\n".postf(grp);
		grp.free;
		~buses = ();
		~groups = ();
	});

	d = SynthDef(name, {arg out;
		var sig = SynthDef.wrap(func);
		Out.ar(out, sig);
	}).add;

	returnVal.plays = {arg self ... args;
		var list = args.asList;
		list.add(\out);
		list.add(bus.index);
		Synth.head(grp, name, list);
	};

	returnVal;
};
*/

~stepper = {arg id, init, steps = 16;

	var tdefId = id.asSymbol;
	Tdef(tdefId).envir = (
		dur: {1;},
		steps: List.newClear(steps)
	);
	Tdef(tdefId).quant = 1;
	Tdef(tdefId, {arg envir;

		init.(envir);
		inf.do({arg i;
			var index = i%envir.steps.size();
			var func = envir.steps[index];
			if (func.notNil, {
				func.();
			});
			envir.dur().wait;
		});
	});
};

)

(
thisThread.randSeed = 8;
~sin = ~group.("sin", {arg freq;
	var sig = SinOsc.ar(freq) * EnvGen.kr( Env.xyc({ [1.0.rand, 1.0.rand, -4.rand2] } ! 16, \exp), doneAction:2);
	sig;
}, 0, \pvfreeze -> ~pvfreeze.(2));

~sin2 = ~group.("sin2", {arg freq=440, sustain=0.02;
	SinOsc.ar(freq) * EnvGen.ar(Env.linen(0.0005, sustain - 0.001, 0.0005, 1), doneAction: 2);
}, 0.5);

~sin3 = ~group.("sin3", {arg freq;
	Splay.ar({SinOsc.ar(exprand(freq, freq + (freq/64)), 0, 0.2)} !16) * LFGauss.ar(9, 1/4, 0, 0, 2, doneAction:2);
});

~sin4 = ~group.("sin4", {arg freq;
	var sig = (
		SinOsc.ar(freq*Array.geom(6, 1, 1.5)*Array.fill(6, { LFNoise2.kr(Rand(1,3),0.01,1) }) )
		+ VarSaw.ar(freq/2, mul:0.3)
		+ VarSaw.ar(freq/3, mul:0.1)
	).mean * LFGauss.ar(9, 1/4, 0, 0, 2, doneAction:2);
	sig;
});

~kik = ~group.("kik", {arg basefreq = 50, envratio = 3, freqdecay = 0.02, ampdecay = 0.5;
	var fenv = EnvGen.kr(Env([envratio, 1], [freqdecay], \exp), 1) * basefreq,
	aenv = EnvGen.kr(Env.perc(0.005, ampdecay), 1, doneAction:2);
	SinOsc.ar(fenv, 0.5pi, aenv);
});

~klank = ~group.("klank", {arg trig=1,  freqScale = 1, timeScale = 1, decay=0.001,  freqOffset=300;
	var amps, freqs, freqsDetune, ringTimes;
	var lFreqs, rFreqs, rTimes;
	freqs = #[2913, 2916.1, 2940, 2942, 2973, 2978, 6796, 6832, 6912, 9711, 9776, 9814, 9960, 12090, 12199];
	freqsDetune = #[ 0, -10, 10, 0.1, 0, -10, 10, 0.1, 0, -10, 10, 0.1, 0, -10, 10, 0.1, 0, -10, 10] ;
	ringTimes = #[9, 8.2, 6, 8.6, 10, 14, 2.2, 1.9, 2.5, 0.9, 1.7, 0.75, 0.5, 0.45, 0.4];
	amps =  #[ 1.0, 0, 2, 0.01, 1.0, 0, 2, 0.01, 1.0, 0, 2, 0.01, 1.0, 0, 2];
	lFreqs = 	freqs;
	rFreqs = 	lFreqs + freqsDetune;	// r channel klank gets freqOffsetd.
	Klank.ar(						// extended to two channels:
		[ 	`[ lFreqs , amps, ringTimes] ,
			// left: original resonator
			`[ rFreqs, amps, ringTimes ]
		],		// right: slightly freqOffsetd freqs,
		Decay.ar(Impulsar.ar(trig), decay),
		// attack with an envelope.
		freqScale,
		freqOffset,
		timeScale
	) * EnvGen.kr(Env.perc(releaseTime:1.5, level:0.05),doneAction:2) * 0.5
});

~thwick = ~group.("thwick", { arg trig=1.0, sfreqScale=1.0, sfreqOffset=0.0, stimeScale=1.0, foldAt=0.1;
	Klank.ar(`[
		FloatArray[ 237.225, 53.8729, 741.223, 76.144, 142.979, 172.487 ],
		nil,
		FloatArray[ 0.0310065, 0.130285, 0.0594931, 0.0716388, 0.157874, 0.114807 ]
		],
		Impulsar.ar(trig),
		sfreqScale,sfreqOffset,stimeScale
	).squared.fold2(foldAt) * EnvGen.kr(Env.perc(releaseTime:1.5),doneAction:2)	;
});

~bass = ~group.("bass", {arg trig = 1;
	SinOsc.ar([52.8, 740], 0, [2, 0.05]).mean.tanh *
		EnvGen.ar(Env([0, 1, 0.7, 0], [0, 0.2, 0.1]), doneAction:2);
});

~noise = ~group.("noise", {arg trig = 1;
	BPF.ar
	(
		WhiteNoise.ar(Decay2.ar(Impulse.ar(1), 0.02, 0.1));
	) * EnvGen.kr(Env.perc, doneAction:2);
});


~snd3 = ~group.("snd3", {arg freq=440, detune=3.0, atk=6, sus=4, rel=6, curve1=1, curve2=(-1),
				minCf=30, maxCf=6000, minRq=0.005, maxRq=0.04,
				minBpfHz=0.02, maxBpfHz=0.25,
				lowShelf=220, rs=0.85, db=6,
				gate=1, amp=1, spread=1.0;

	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[curve1,0,curve2]), gate, levelScale:amp, doneAction:2);
	sig = Saw.ar(freq +
		LFNoise1.kr({LFNoise1.kr(0.5).range(0.15,0.4)}!8).range(detune.neg,detune));
	sig = BPF.ar(sig,
		LFNoise1.kr({LFNoise1.kr(0.13).exprange(minBpfHz,maxBpfHz)}!8).exprange(minCf, maxCf),
		LFNoise1.kr({LFNoise1.kr(0.08).exprange(0.08,0.35)}!8).range(minRq, maxRq)
	);
	sig = BLowShelf.ar(sig, lowShelf, rs, db);
	sig = SplayAz.ar(4, sig, spread);
	sig = sig * env * 2;
	sig;
});

)

(
~scale = 440 * Scale.phrygian.ratios;
v = TempoClock.new(360/60);

/////////////////////////////////////////////////////////////////
//controller 1
/////////////////////////////////////////////////////////////////
~ctrl1 = ~controller.(v);

/////////////////////////////////////////////////////////////////
//1
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq1", ~sin, {arg envir;
	envir.steps[0] = [\freq, ~scale[0]];
	envir.steps[4] = [\freq, ~scale[3]];
}, 32));

/////////////////////////////////////////////////////////////////
//2
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq2", ~sin, {arg envir, clock;

	envir.steps[3] = nil;
	envir.steps[10] = nil;
	clock.sched(64, {
		envir.steps[3] = [\freq, ~scale[4]];
		envir.steps[10] = [\freq, ~scale[5]];
	});

}, 32));

/////////////////////////////////////////////////////////////////
//3
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq3", ~sin3, {arg envir, clock;

	envir.dur = { rrand(0.5, 2.5) };
	envir.steps[20] = [\freq, ~scale[2]/1.5];
	envir.steps[22] = [\freq, ~scale[6]/1.5];
	envir.steps[26] = [\freq, ~scale[5]/1.5];

}, 32));

/////////////////////////////////////////////////////////////////
//5
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq5", ~kik, {arg envir, clock;

	envir.steps = List.newClear(1);
	envir.dur = { 4 };

	clock.sched(64, {
		envir.steps[0] = {[\basefreq, 50]}
	});

}, 1));

/*
/////////////////////////////////////////////////////////////////
//6
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq6", ~klank, {arg envir, clock;

	clock.sched(64, {
		envir.steps[0] = [\freqScale, 1];
		envir.steps[4] = [\freqScale, 1];
		envir.steps[8] = [\freqScale, 1];
		envir.steps[12] = [\freqScale, 2];
	});

}, 32));

/////////////////////////////////////////////////////////////////
//7
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq7", ~thwick, {arg envir, clock;

	clock.sched(32, {
		envir.steps[1] = [\sfreqScale, 1.0];
		envir.steps[3] = [\sfreqScale, 1.0];
		envir.steps[8] = [\sfreqScale, 1.0];
		envir.steps[10] = [\sfreqScale, 1.0];
		envir.steps[12] = [\sfreqScale, 1.0];
		envir.steps[14] = [\sfreqScale, 1.0];
		envir.steps[22] = [\sfreqScale, 1.0];
		envir.steps[28] = [\sfreqScale, 1.0];
		envir.steps[29] = [\sfreqScale, 1.0];
		envir.steps[30] = [\sfreqScale, 1.0];
	});

}, 32));

/////////////////////////////////////////////////////////////////
//8
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq8", ~sin4, {arg envir, clock;

	clock.sched(32, {
		envir.steps[1] = [\freq, ~scale[0]];
		envir.steps[17] = [\freq, ~scale[0]];
	});

}, 32));
*/

/*
/////////////////////////////////////////////////////////////////
//9
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq9", ~bass, {arg envir, clock;

	clock.sched(8, {
		envir.steps[1] = [\trig, 1];
		envir.steps[3] = [\trig, 1];
		envir.steps[5] = [\trig, 1];
		envir.steps[6] = [\trig, 1];
		envir.steps[13] = [\trig, 1];
		envir.steps[20] = [\trig, 1];
		envir.steps[30] = [\trig, 1];
	});

}, 32));
*/

/*
/////////////////////////////////////////////////////////////////
//10
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq10", ~noise, {arg envir, clock;

	clock.sched(8, {
		envir.steps[1] = [\trig, 1];
		envir.steps[2] = [\trig, 1];
		envir.steps[3] = [\trig, 1];
		envir.steps[5] = [\trig, 1];
		envir.steps[6] = [\trig, 1];
		envir.steps[13] = [\trig, 1];
		envir.steps[14] = [\trig, 1];
		envir.steps[15] = [\trig, 1];
		envir.steps[20] = [\trig, 1];
		envir.steps[30] = [\trig, 1];
	});

}, 32));
*/

/*
/////////////////////////////////////////////////////////////////
//11
/////////////////////////////////////////////////////////////////
~ctrl1.add_new(~stepper.("seq11", ~snd3, {arg envir, clock;
	envir.steps[1] = [\freq, ~scale[0]];
}, 32));
*/



~ctrl1.play_all();
//~ctrl1.stop_all();

)

~samples.ls()
~samples.load("linndrum/kick.wav")
~samples.load("TR909all/ST7T3SA");
~samples.load("TR909all/MT3D0");
~samples.load("astralplane.mono");

(
//~samples.load("angels.piano.mono");
var buf = ~samples['astralplane.mono'];
~gran1 = ~grainbuf.("gran1", buf);
~gran1.setTrig({
	Dust.ar(0.01);
});
~gran1.setDur({
	DC.ar(0.001)
});
~gran1.setStart( {
	LFNoise1.ar(5).range(0.1, 0.8)
} );
~gran1.setRate ( {
	DC.ar(1)
} );
~gran1.setPan({
	LFNoise1.ar(1).range(-0.7, 0.7);
});
~gran1.proxy.play;
~gran1.proxy.set(\amp, 0.4);
//~gran1.proxy.stop
//Ndef.clear
)


InstrBrowser.new.gui

l = List.newClear(8);
l[0] = 1;
l.reset






