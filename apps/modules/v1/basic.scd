(
~lfo = {arg wave = \sin, tempo = [1], freq = [1], min = [1], max = [1], func = {arg lfo;lfo};
	{
		var tempo_in = \tempo.kr(tempo);
		var rate_in = \freq.kr(freq);
		var min_in = \min.kr(min);
		var max_in = \max.kr(max);
		var sig =
		switch (wave,
			\sin, { {var sig = SinOsc.kr(tempo_in * rate_in).range(min_in,max_in); sig = func.(sig); sig;} },
			\saw, { {var sig = LFSaw.kr(tempo_in * rate_in).range(min_in,max_in); sig = func.(sig); sig;} },
			\tri, { {var sig = LFTri.kr(tempo_in * rate_in).range(min_in,max_in); sig = func.(sig); sig;} },
			\pulse, { {var sig = LFPulse.kr(tempo_in * rate_in).range(min_in,max_in); sig = func.(sig); sig;} },
			\noise, { {var sig = LFNoise2.kr(tempo_in * rate_in).range(min_in,max_in); sig = func.(sig); sig;} },
			\henon, { {var sig = A2K.kr(HenonC.ar(tempo_in * rate_in)).range(min_in,max_in); sig = func.(sig); sig;} };
		);
		sig;
	};
};

~splay = {arg chans = 1;
	{
		Splay.ar(\in.ar(0.dup(chans)));
	};
};

~pan = {arg chans = 1;
	{
		Pan2.ar(\in.ar(0.dup(chans)), \pan.kr(0));
	};
};

)

