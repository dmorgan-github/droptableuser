(
~sinoscfb = {arg freq = [432], fb = [0], amp = [0], func = {arg sig;sig};
	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var sig = SinOscFB.ar(freq_in, \fb.kr(fb));
		func.(sig * AmpCompA.kr(freq_in) * \amp.kr(amp));
	}
};

~sinosc = {arg freq = [432], amp = [0], func = {arg sig;sig};
	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var sig = SinOsc.ar(freq_in);
		func.(sig * AmpCompA.kr(freq_in) * \amp.kr(amp));
	}
};

~varsaw = {arg freq = [432], width = [0.5], amp = [0], func = {arg sig;sig};
	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var sig = VarSaw.ar(freq_in, width:\width.kr(width));
		func.(sig * AmpCompA.kr(freq_in) * \amp.kr(amp));
	}
};


~saw = {arg freq = [432], amp = [0], func = {arg sig;sig};
	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var sig = Saw.ar(freq_in);
		func.(sig * AmpCompA.kr(freq_in) * \amp.kr(amp));
	}
};

~noise = {arg type = \wn, amp = [0], func = {arg sig;sig};
	switch (type,
		\wn, { {var sig = WhiteNoise.ar * \amp.kr(amp); func.(sig);} },
		\pn, { {var sig = PinkNoise.ar * \amp.kr(amp); func.(sig);} },
		\bn, { {var sig = BrownNoise.ar * \amp.kr(amp); func.(sig)} },
		\gn, { {var sig = GrayNoise.ar * \amp.kr(amp); func.(sig);} }
	);
};

~pulse = {arg freq = [432], width = [0.5], amp = [0], func = {arg sig;sig};
	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var sig = Pulse.ar(freq_in, \width.kr(width));
		func.(sig * AmpCompA.kr(freq_in) * \amp.kr(amp));
	}
};

~smplr = {arg buf, rate = [1], start = [0], end = [1], func = {arg sig;sig};

	var chans = 1;

	if (buf.isNil.not) {
		chans = buf.numChannels;
	};

	{
		var buf_in = \buf.kr(buf);
		var rate_in = \rate.kr(rate);
		var trig = \trig.tr;
		var start_in = \start.kr(start);
		var end_in = \end.kr(end);

		var numFrames = BufFrames.kr(buf);
		var startFrame = start_in * numFrames;
		var endFrame = end_in * numFrames;

		var dur = (endFrame - startFrame)/BufSampleRate.kr(buf);
		var phasor = Env([startFrame, startFrame, endFrame], [0, dur * rate_in.reciprocal], 0).ar(gate:trig);
		func.(BufRd.ar(chans, buf, phasor, loop:0, interpolation: 4));
	}
}
)

