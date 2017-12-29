(
~lpf = {arg chans = 1, freq = [1200], rq = [0.5];
	{
		var in = \in.ar(0.dup(chans));
		var fx = BLowPass.ar(in,
			\freq.kr(freq),
			\rq.kr(rq)
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};

~lpf4 = {arg chans = 1, freq = [1200], rq = [0.5];

	{
		var in = \in.ar(0.dup(chans));
		var fx = BLowPass4.ar(in,
			\freq.kr(freq),
			\rq.kr(rq)
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};

~bpf = {arg chans = 1, freq = [2200], bw = [0.1];
	{
		var in = \in.ar(0.dup(chans));
		var fx = BBandPass.ar(in,
			\freq.kr(freq),
			\bw.kr(bw).linlin(0,1,0,10)
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};

~rlpf = {arg chans = 1, freq = [2200], rq = [1];
	{
		var in = \in.ar(0.dup(chans));
		var freq_in = \freq.kr(freq);
		var rq_in = \rq.kr(rq);
		var fx = RLPF.ar(in, freq_in, rq_in);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};

~dfm1 = {arg chans = 1, freq = [1000], res = [0.1];
	{
		var in = \in.ar(0.dup(chans));
		var fx = DFM1.ar(in, \freq.kr(freq), \res.kr(res), \inputgain.kr(1), 0, \noiselevel.kr(0.0003));
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

~moogff = {arg chans = 1, freq = [1200], rq = [0.5];

	{
		var in = \in.ar(0.dup(chans));
		var fx = MoogFF.ar(in, \freq.kr(freq), 4 * (1-\rq.kr(rq)));
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};
)