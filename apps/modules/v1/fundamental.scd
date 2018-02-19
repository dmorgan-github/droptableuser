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
			\noise, { {var sig = LFDNoise3.kr(tempo_in * rate_in).range(min_in,max_in); sig = func.(sig); sig;} },
			\henon, { {var sig = A2K.kr(HenonC.ar(tempo_in * rate_in)).range(min_in,max_in); sig = func.(sig); sig;} };
		);
		sig;
	};
};
Library.put(\modules, \fundamental, \lfo, ~lfo);

~varlag = {

	{
		var val = \val.kr;
		VarLag.kr(val, \dur.kr(0.1), \curve.kr(0), \warp.kr(5));
	}
};
Library.put(\modules, \fundamental, \varlag, ~varlag);

~splay = {arg chans = 1, node;

	{
		Splay.ar(\in.ar(0.dup(chans)));
	};
};
Library.put(\modules, \fundamental, \splay, ~splay);

~sum = {arg chans;
	{
		var in = \in.ar(0.dup(chans));
		in.sum!2
	}
};
Library.put(\modules, \fundamental, \sum, ~sum);

~pan = {arg chans = 1;
	{
		Pan2.ar(\in.ar(0.dup(chans)), \pan.kr(0));
	};
};
Library.put(\modules, \fundamental, \pan, ~pan);

~rotate = {arg chans = 1;

	{
		var in = \in.ar(0.dup(chans));
		var x, y;
		#x, y = Rotate2.ar(in[0], in[1], LFSaw.kr(\rate.kr(0.1)));
		[x,y];
	};
};
Library.put(\modules, \fundamental, \rotate, ~rotate);


)
