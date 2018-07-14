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

	\degree, Pbrown(0, 5, 1, inf),

	\vrate, 0.003,
	\vrate2, 0.003,

	\mtranspose, 0,
	\gtranspose, 0,
	\ctranspose, 0,//Pstep(Pseq([0,2,-2], inf), Pseq([16], inf), inf),//0,
	\root, 0,
	\scale, Scale.kumoi,
	\stepsPerOctave, 12,

	\octave2, Prand([5, 6], inf),
	\degree2, Pkey(\degree) + (Prand([2, 3], inf) * Prand([-1,1], inf)),
	\freq2, Pfunc({arg evt;
		var note = (evt[\degree2] + evt[\mtranspose]).degreeToKey(evt[\scale], evt[\stepsPerOctave]);
		var midinote = ((note + evt[\gtranspose] + evt[\root])/ evt[\stepsPerOctave] + evt[\octave2]) * 12.0;
		var freq = (midinote + evt[\ctranspose]).midicps;
		freq;
	})
));


~p[\sinpair1][0] = ~anasine.();
~p[\sinpair1].set(\vdepth, 0.001, \vrate, 2, \vrateVar, 0.5, \vdepthVar, 0.5)
~p[\sinpair2][0] = ~anasine.();
~p[\sinpair2].set(\vdepth, 0.01, \vrate, 3, \vrateVar, 0.1, \vdepthVar, 0.3)

~p[\pairtrig] = {~p[\pairseq].kr[0]};

~p[\pairenv1] = ~tlinen.();
~p[\pairenv1].set(\atk, 2, \sus, 2, \rel, 1)
~p[\pairenv1].set(\trig, ~p[\pairtrig]);

~p[\pairenv2] = ~tlinen.();
~p[\pairenv2].set(\atk, 1, \sus, 1, \rel, 1)
~p[\pairenv2].set(\trig, ~p[\pairtrig]);

~p[\pairfreq1] = {~p[\pairseq].kr[1]}
~p[\pairfreq2] = {~p[\pairseq].kr[2]};

~p[\sinpair1].set(\freq, ~p[\pairfreq1], \amp, ~p[\pairenv1]);
~p[\sinpair2].set(\freq, ~p[\pairfreq2], \amp, ~p[\pairenv2]);

~p[\pairmix][0] = {~p[\sinpair1]};
~p[\pairmix][1] = {~p[\sinpair2]};


~p[\paisum] = ~splay.(chans:~p[\pairmix].numChannels);
~p[\paisum] <<> ~p[\pairmix];

~jpverb.def.sourceCode
~p[\pairverb] = ~jpverb.(chans:~p[\paisum].numChannels);
~p[\pairverb] <<> ~p[\paisum];
~p[\pairverb].set(\wet, 0.5, \t60, 10, \size, 10)
~p[\pairverb].play(fadeTime:5);
~p[\pairverb].stop(fadeTime:5);
~p[\pairverb].vol = 0.5;

~waveloss.def.sourceCode
~p[\dist] = ~waveloss.(chans:~p[\pairverb].numChannels);
~p[\dist] <<> ~p[\pairverb];
~p[\dist].set(\wet, 0.1);
~p[\dist].vol = 0.05
~p[\dist].play


App.recordVersion;
s.stopRecording


