(
~scale = 440 * Scale.phrygian.ratios;
Tdef.all.collect({arg tdef; tdef.clear;});
v = TempoClock.default = TempoClock.new(120/60);

///////////////////////////////////////////////////
//1
~kik = ~channel.("kik");
~synth.(~kik, "kik", {arg basefreq = 50, envratio = 3, freqdecay = 0.02, ampdecay = 0.5, amp = 1;
	var fenv = EnvGen.kr(Env([envratio, 1], [freqdecay], \exp), 1) * basefreq,
	aenv = EnvGen.kr(Env.perc(0.005, ampdecay, amp, -4), 1, doneAction:2);
	FSinOsc.ar(fenv, 0.5pi, aenv);
});
~mix.(~kik);

~stepper.("seq5", {arg envir;
	var args = [\amp, 0.3, \basefreq, 50, \envratio, 8, \freqdecay, 0.01, \ampdecay, 0.2];
	var seq = Prand([2], inf).asStream;
	envir.dur = { seq.next };
	envir.steps[0] = { ~kik.plays(args); };
}, 1).play();


///////////////////////////////////////////////////
//2
~thwick = ~channel.("thwick");
~synth.(~thwick, "thwick", {arg trig=1.0, sfreqScale=1.0, sfreqOffset=0.0, stimeScale=1.0, foldAt=0.1, amp = 1;
	Klank.ar(`[
		FloatArray[ 237.225, 53.8729, 741.223, 76.144, 142.979, 172.487 ],
		nil,
		FloatArray[ 0.0310065, 0.130285, 0.0594931, 0.0716388, 0.157874, 0.114807 ]
		],
		Impulsar.ar(trig),
		sfreqScale,sfreqOffset,stimeScale
	).squared.fold2(foldAt) * EnvGen.kr(Env.perc(releaseTime:1.5, level:amp),doneAction:2);
});
~mix.(~thwick);

~stepper.("seq6", {arg envir;
	var args = {
		~thwick[\mix].set(\pan, 1.0.sum3rand);
		~thwick.plays( [\amp, 0.3,
			\foldAt, rrand(-0.01, 1),
			\stimeScale, rrand(0.01, 3),
			\sfreqOffset, rrand(0.1, 15),
			\sfreqScale, rrand(0.1, 15)
		]);
	};

	envir.dur = {0.25};
	envir.steps[0] = args;
	envir.steps[4] = args;
	envir.steps[8] = args;
	envir.steps[9] = args;
	envir.steps[12] = args;
	envir.steps[16] = args;
	envir.steps[17] = args;
	envir.steps[18] = args;
	envir.steps[19] = args;
	envir.steps[21] = args;
	envir.steps[24] = args;
	envir.steps[25] = args;
	envir.steps[26] = args;
	envir.steps[27] = args;
	envir.steps[28] = args;
	envir.steps[29] = args;
	envir.steps[30] = args;
	envir.steps[31] = args;
}, 32).play();

///////////////////////////////////////////////////
//3
~grain = ~channel.("grain");
~synth.(~grain, "grain", {arg amp=0.3, freq = 440;
	SinOsc.ar(freq) * EnvGen.kr(Env.perc(level:amp), doneAction:2);
});
~filter.(~grain, "echo", {arg in, decay = 1, allpasses = 5, gain = 1;
	var source = in;
	allpasses.do({ source = AllpassN.ar(source, 0.5, [Rand(0, 0.5), Rand(0, 0.5)], decay) }; );
	source * gain;
}, {
	~mix.(~grain);
});

~stepper.("seq7", {arg envir;
	v.sched(8, {
		~grain[\echo].set(\decay, 5);
		~grain2[\mix].set(\pan, 0.5);
		envir.steps[0] = { ~grain.plays([\freq, ~scale[0]]); };
		envir.steps[1] = { ~grain.plays([\freq, ~scale[6]]); };
		envir.steps[4] = { ~grain.plays([\freq, ~scale[3]]); };
		envir.steps[8] = { ~grain.plays([\freq, ~scale[4]]); };
		envir.steps[10] = { ~grain.plays([\freq, ~scale[6]]); };
	});

}, 16).play();

///////////////////////////////////////////////////
//4
~grain2 = ~channel.("grain2");
~synth.(~grain2, "grain2", {arg amp=0.3, freq = 440;
	SinOsc.ar(freq) * EnvGen.kr(Env.perc(level:amp), doneAction:2);
});
~filter.(~grain2, "echo", {arg in, decay = 1, allpasses = 5, gain = 1;
	var source = in;
	allpasses.do({ source = AllpassN.ar(source, 0.5, [Rand(0, 0.5), Rand(0, 0.5)], decay) }; );
	source * gain;
}, {
	~mix.(~grain2);
});
~stepper.("seq8", {arg envir;
	v.sched(32, {
		~grain2[\echo].set(\decay, 6);
		~grain2[\mix].set(\pan, -0.5);
		envir.steps[0] = { ~grain.plays([\freq, ~scale[1]]); };
		envir.steps[3] = { ~grain.plays([\freq, ~scale[3]]); };
		envir.steps[6] = { ~grain.plays([\freq, ~scale[2]]); };
		envir.steps[12] = { ~grain.plays([\freq, ~scale[5]]); };
		envir.steps[14] = { ~grain.plays([\freq, ~scale[4]]); };
	});

}, 16).play();

)


(
~samples.ls();
~samples.load("astralplane.mono");

~gran1 = ~grainbuf.("gran1", ~samples['astralplane.mono']);

~gran1.setTrig({
	Dust.ar(0.5);
});
~gran1.setDur({
	LFNoise1.ar(1).range(1, 2)
});
~gran1.setStart( {
	LFNoise1.ar(1).range(0.1, 0.8)
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
//~gran1.proxy.stop
//Ndef.clear
)

(
var win = Window("controller", Rect(100,100,300, 300)).front ;
var textView = TextView(win, Rect(0,0,300, 300)) ;
textView.keyUpAction_{arg view, char, modifiers, unicode, keycode;
	// control
	if (modifiers == 262144, {
		if (keycode == 15, {
			Tdef.all.collect({arg tdef; tdef.clear;});
			v = TempoClock.default = TempoClock.new(120/60);
			Tdef.all.collect({arg tdef; tdef.play});
		});
		if (keycode == 12, {
			Tdef.all.collect({arg tdef; tdef.stop});
		});
	});
};
)



