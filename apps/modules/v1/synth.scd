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
Library.put(\modules, \synth, \sinoscfb, ~sinoscfb);

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
Library.put(\modules, \synth, \sinosc, ~sinosc);

~anasine = {arg freq = [432], amp = [0], func = {arg sig;sig};

	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		// try to model a more analog sound
		var sig = Mix.fill(4,{
			//between 1 +- 0.01
			var freqmult = 1+SinOsc.ar(LFNoise1.kr(rrand(0.25,0.5),4,5),pi.rand,0.01);
			SinOsc.ar(freq_in * (freqmult), pi.rand);
		});

		sig = sig + VarSaw.ar(freq_in, mul: LFDNoise3.kr(0.25).range(0.1,0.4) );

		func.(sig * AmpCompA.kr(freq_in) * \amp.kr(amp));
	}
};
Library.put(\modules, \synth, \anasine, ~anasine);

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
Library.put(\modules, \synth, \varsaw, ~varsaw);

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
Library.put(\modules, \synth, \saw, ~saw);

~sawdpw = {arg freq = [432], amp = [0], func = {arg sig;sig};
	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var sig = SawDPW.ar(freq_in);
		func.(sig * AmpCompA.kr(freq_in) * \amp.kr(amp));
	}
};
Library.put(\modules, \synth, \sawdpw, ~sawdpw);

~tri = {arg freq = [432], amp = [0], func = {arg sig;sig};

	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var sig = DPW3Tri.ar(freq_in);
		func.(sig * AmpCompA.kr(freq_in) * \amp.kr(amp));
	}
};
Library.put(\modules, \synth, \tri, ~tri);

~noise = {arg type = \wn, amp = [0], func = {arg sig;sig};
	switch (type,
		\wn, { {var sig = WhiteNoise.ar * \amp.kr(amp); func.(sig);} },
		\pn, { {var sig = PinkNoise.ar * \amp.kr(amp); func.(sig);} },
		\bn, { {var sig = BrownNoise.ar * \amp.kr(amp); func.(sig)} },
		\gn, { {var sig = GrayNoise.ar * \amp.kr(amp); func.(sig);} }
	);
};
Library.put(\modules, \synth, \noise, ~noise);

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
Library.put(\modules, \synth, \pulse, ~pulse);

~oneshot = {arg buf, rate = [1], start = [0], end = [1], curve = 0, trig = 0, func = {arg sig;sig};

	var chans = 1;

	if (buf.isNil.not) {
		chans = buf.numChannels;
	};

	{
		var buf_in = \buf.kr(buf);
		var rate_in = \rate.kr(rate);
		var trig = \trig.tr(trig);
		var start_in = \start.kr(start);
		var end_in = \end.kr(end);
		var curve_in = \curve.kr(curve);

		var numFrames = BufFrames.kr(buf);
		var startFrame = start_in * numFrames;
		var endFrame = end_in * numFrames;

		var dur = (endFrame - startFrame)/BufSampleRate.kr(buf);
		var phasor = Env([startFrame, startFrame, endFrame], [0, dur * rate_in.reciprocal], curve_in).ar(gate:trig);
		func.(BufRd.ar(chans, buf_in, phasor, loop:0, interpolation: 4));
	}
};
Library.put(\modules, \synth, \oneshot, ~oneshot);

~playbuf = {arg buf, rate = [1], startFrame = [0], loop = 0, trig = 0, func = {arg sig;sig};

	var chans = 1;

	if (buf.isNil.not) {
		chans = buf.numChannels;
	};

	{
		var buf_in = \buf.kr(buf);
		var rate_in = \rate.kr(rate);
		var trig = \trig.tr(trig);
		var start_in = \start.kr(startFrame);
		var loop_in = \loop.kr(loop);

		func.(PlayBuf.ar(chans, buf_in, rate_in, trig, start_in, loop_in, doneAction:0));
	}
};
Library.put(\modules, \synth, \playbuf, ~playbuf);

~bufrd = {arg buf;
	// requires audio rate for phase

	var chans = 1;

	if (buf.isNil.not) {
		chans = buf.numChannels;
	};

	{
		var buf_in = \buf.kr(buf);
		var phase = \phase.ar;
		BufRd.ar(chans, buf_in, phase, interpolation:4);
	}
};
Library.put(\modules, \synth, \bufrd, ~bufrd);

~bufloop = {arg buf = 0, start = 0, end = 1, rate = 1, lag = 0.1;

	var chans = 1;

	if (buf.isNil.not) {
		chans = buf.numChannels;
	};

	{
		var buf_in = \buf.kr(buf);
		var start_in = \start.kr(start);
		var end_in = \end.kr(end);
		var rate_in = \rate.kr(rate);
		var lag_in = \lag.kr(lag);

		var numFrames = BufFrames.kr(buf_in);
		var startFrame = start_in * numFrames;
		var endFrame = end_in * numFrames;
		var dur = (endFrame - startFrame/BufSampleRate.kr(buf_in)) * rate_in.reciprocal;
		var trig = Impulse.kr(dur.reciprocal);
		var sig = PlayBufCF.ar(1, buf_in, rate_in, trig, startFrame, loop:0, lag:lag_in );

		sig;
	}
};
Library.put(\modules, \synth, \bufloop, ~bufloop);

~grain_buf = {arg buf, dur = 0.1, rate = 1, pos = 0, loop = 0;

	{
		var buf_in = \buf.kr(buf);
		var pan = \pan.kr(0);
		var envbuf = \envbuf.kr(-1);
		var grainamp = \grainamp.kr(1);
		var trig = \trig.kr(0);

		var sig = GrainBufJ.ar(1,
			trigger:trig,
			dur:\dur.kr(dur),
			sndbuf:buf_in,
			rate:\rate.kr(rate),
			pos:\pos.kr(pos),
			loop:loop,
			interp:4,
			grainAmp:grainamp,
			pan:pan,
			envbufnum:envbuf
		);

		sig;
	}
};
Library.put(\modules, \synth, \grain_buf, ~grain_buf);

~pmosc = {arg freq = [432], modratio = [0], index = [0], amp = [0], func = {arg sig;sig};

	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var sig = PMOsc.ar(freq_in, freq_in * \modratio.kr(modratio), \index.kr(index) );
		func.(sig * AmpCompA.kr(freq_in) * \amp.kr(amp));
	}
};
Library.put(\modules, \synth, \pmosc, ~pmosc);

~resN = {arg numFreqs = 6, chans = 1, freq = [432], func = {arg sig;sig};

	{
		var freq_in = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var in = \in.ar(0.dup(chans));

		var detune = \detune.kr(0);

		var ffreqs = (0..numFreqs-1).collect({arg i;
			(\f ++ i).asSymbol.kr(1);
		}) + detune;

		var amps = (0..numFreqs-1).collect({arg i;
			(\a ++ i).asSymbol.kr(1/numFreqs);
		});

		var rings = (0..numFreqs-1).collect({arg i;
			(\r ++ i).asSymbol.kr(1);
		});

		var sig = DynKlank.ar(`[freq_in * ffreqs, amps, rings], in);

		func.(sig * AmpCompA.kr(freq) * \amp.kr(0));
	};
};
Library.put(\modules, \synth, \resN, ~resN);

)

