(
~hpf = {arg chans = 1, freq = [1200], rq = [0.5];
	{
		var in = \in.ar(0.dup(chans));
		var fx = BHiPass.ar(in,
			\freq.kr(freq),
			\rq.kr(rq)
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};
Library.put(\modules, \filter, \hpf, ~hpf);

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
Library.put(\modules, \filter, \lpf, ~lpf);

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
Library.put(\modules, \filter, \lpf4, ~lpf4);

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
Library.put(\modules, \filter, \bpf, ~bpf);

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
Library.put(\modules, \filter, \rlpf, ~rlpf);

~dfm1 = {arg chans = 1, freq = [1000], res = [0.1];
	{
		var in = \in.ar(0.dup(chans));
		var fx = DFM1.ar(in, \freq.kr(freq), \res.kr(res), \inputgain.kr(1), 0, \noiselevel.kr(0.0003));
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};
Library.put(\modules, \filter, \dfm1, ~dfm1);

~moogff = {arg chans = 1, freq = [1200], rq = [0.5];

	{
		var in = \in.ar(0.dup(chans));
		var fx = MoogFF.ar(in, \freq.kr(freq), 4 * (1-\rq.kr(rq)));
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};
Library.put(\modules, \filter, \moogff, ~moogff);

/*
var filters = {
  0: "lowpass",
  1: "highpass",
  2: "bandpass",
  3: "lowshelf",
  4: "highshelf",
  5: "peaking",
  6: "notch",
  7: "allpass"
 }
*/

~bpf_ratios = {arg chans = 1, base = 432, ratios = [1];

	{
		var in = \in.ar(0.dup(chans));
		var base_in = \base.kr(base).lag(\lag.kr(0.0));
		var fx = ratios.collect({arg ratio, i;
			var rq = NamedControl.kr(('rq_' ++ i).asSymbol, 1);
			BPF.ar(in, (base_in * ratio), rq) * NamedControl.kr(('amp_' ++ i).asSymbol, 0);
		});

		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};
Library.put(\modules, \filter, \bpf_ratios, ~bpf_ratios);

~comb_res = {arg chans = 1, freqs = [440];

	{
		var in = \in.ar(0.dup(chans));
		var fx = freqs.collect({arg freq, i;
			var freq_ctrl = NamedControl.kr(('freq_' ++ i).asSymbol, freq);
			var amp_ctrl = NamedControl.kr( ('amp_' ++ i).asSymbol, 1);
			CombC.ar(in, 0.2, 1/freq_ctrl, 0.2, mul:amp_ctrl);
		});

		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};
Library.put(\modules, \filter, \comb_res, ~comb_res);

~svf = {arg chans = 1, freq = [2200], res = [0.1];

	{
		var in = \in.ar(0.dup(chans));
		var freq_in = \freq.kr(freq);
		var res_in = \res.kr(res);
		var fx = SVF.ar(in, freq_in, res_in, \lpf.kr(0.1), \bpf.kr(0), \hpf.kr(0), \notch.kr(0), \peak.kr(0));
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};
Library.put(\modules, \filter, \svf, ~svf);

)