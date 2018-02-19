~h = ~ps_helper.(~p);

(~p[\pairseq][0] = {
	var trig = \trig.tr;
	var freq = \freq.kr;
	var freq2 = \freq2.kr;
	[trig, freq, freq2];
})
(~p[\pairseq][4] = \set -> Pbind(

	\trig, 1,

	\delta, 8,

	\degree, Ppatlace([Pseq([0,6], inf), Pseq([2,3,5,4], inf)], inf),

	\vrate, 0.003,
	\vrate2, 0.003,

	\mtranspose, 0,
	\gtranspose, 0,
	\ctranspose, 0,
	\root, 0,
	\ocatave, Prand([5], inf),
	\scale, Scale.ritusen,
	\stepsPerOctave, 12,

	\degree2, Pkey(\degree) + Prand([2, 3], inf),
	\freq2, Pfunc({arg evt;
		var note = (evt[\degree2] + evt[\mtranspose]).degreeToKey(evt[\scale], evt[\stepsPerOctave]);
		var midinote = ((note + evt[\gtranspose] + evt[\root])/ evt[\stepsPerOctave] + evt[\ocatave]) * 12.0;
		var freq = (midinote + evt[\ctranspose]).midicps;
		freq;
	})
));

(
~p[\sinpair][0] = {

	var freq = 432;

	var amp = 0;

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var freq2_in = Vibrato.ar(K2A.ar(\freq2.kr(freq).lag(\lag2.kr(0.0))),
		\vrate2.kr(6),
		\vdepth2.kr(0.0),
		\vdelay2.kr(0),
		\vonset2.kr(0),
		\vrateVar2.kr(0.04),
		\vdepthVar2.kr(0.1)
	);

	var sig = SinOsc.ar([freq_in, freq2_in]);
	sig * AmpCompA.kr([freq_in, freq2_in]) * [\amp.kr(amp), \amp2.kr(amp)];
};
)

~p[\pairtrig] = {~p[\pairseq].kr[0]};
~p[\pairenv1] = ~tlinen.();
~p[\pairenv1].set(\atk, 2, \sus, 2, \rel, 1)

~p[\pairenv1].set(\trig, ~p[\pairtrig]);

~p[\pairfreq1] = {~p[\pairseq].kr[1]}
~p[\pairfreq2] = {~p[\pairseq].kr[2]}

(~p[\sinpair].set(
	\amp, ~p[\pairenv1],
	\amp2, ~p[\pairenv1],
	\freq, ~p[\pairfreq1],
	\freq2, ~p[\pairfreq2]
)
);

~p[\sinpair].play;
~p[\sinpair].stop;

~p[\paisum] = ~sum.(chans:~p[\sinpair].numChannels);
~p[\paisum] <<> ~p[\sinpair];

~jpverb.def.sourceCode
//~p[\pairverb] = ~gverb.(chans:~p[\sinpair].numChannels, roomsize:50);
~p[\pairverb] = ~jpverb.(chans:~p[\sinpair].numChannels);
~p[\pairverb] <<> ~p[\paisum];
~p[\pairverb].set(\wet, 0.4, \t60, 5, \size, 5)
~p[\pairverb].play
~p[\pairverb].stop
~p[\pairverb].vol = 0.02;

~waveloss.def.sourceCode
~p[\dist] = ~waveloss.(chans:~p[\pairverb].numChannels);
~p[\dist] <<> ~p[\pairverb];
~p[\dist].set(\wet, 0.3);
~p[\dist].vol = 0.05
~p[\dist].play


App.recordVersion;
s.stopRecording


