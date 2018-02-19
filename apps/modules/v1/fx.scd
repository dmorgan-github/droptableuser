(
~gran = {arg chans = 1;

	var length = 16;
	var buf = Buffer.alloc(s, s.sampleRate * length, chans);

	{
		var in = \in.ar(0.dup(chans));

		var frames = BufFrames.kr(buf);
		var rate = BufSampleRate.kr(buf);
		var phase = Phasor.ar(1, BufRateScale.kr(buf), 0, frames, 0);
		var rec = BufWr.ar(in, buf, phase);
		var fx = Warp1.ar(chans, buf, 0, 1, 0.2, -1, 8, 0, 4);

		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};
Library.put(\modules, \fx, \gran, ~gran);

~granulator = {arg chans = 1;

	//var length = 16;
	//var buf = Buffer.alloc(s, s.sampleRate * length, chans );

	{arg bufnum, pdisp = 0.01, tdisp = 0.02;


		var in = \in.ar(0.dup(chans));

		var wet = \wet.kr(1);
		var frames, sRate, recHead, rec, overlap, trig,
		out, eff, rate, dur, pan, center;

		bufnum = b;

		//in = SoundIn.ar( 0 );

		/*

		in = {

			var trig = Impulse.kr(0.1);
			var freq = Demand.kr(trig, 0, Dseq(( [60, 65, 72, 58]).midicps, inf));
			var sig = SinOsc.ar(Vibrato.ar(K2A.ar(freq.lag(0.01))));
			var env = Env.linen(releaseTime:3).kr(gate:trig);
			var drive=2.3,type=0,outAmp=1;

			sig = sig * env * 0.3;

			//sig = sig.blend(GVerb.ar(sig, 150, damping:0.7, drylevel:0, taillevel:0.7), 0.5);

			out= SelectX.ar(type,[sig.softclip,sig.distort,sig.clip(-1,1),sig.fold(-1,1)]);
			sig = sig * ((outAmp**2)*(1-(drive/2.6)));

			Mix.ar(sig);

		}.value;

		*/

		frames = BufFrames.kr( bufnum );
		sRate = BufSampleRate.kr( bufnum );
		recHead = Phasor.ar( 1, BufRateScale.kr( bufnum), 0, frames, 0 );
		rec = BufWr.ar( in, bufnum, recHead );
		overlap = MouseY.kr( 0.8, 10, 1 );
		dur = 0.6 + SinOsc.kr( 0.1, mul:0.4 );
		pdisp = pdisp + 1;

		trig = Impulse.ar( overlap/dur );

		rate = MouseX.kr( -6, 6, 0 ) * TExpRand.kr( pdisp.reciprocal, pdisp, trig );
		center = Wrap.ar( recHead - (dur * rate * 0.5), 0, frames-1 ) - TRand.kr( 0, tdisp, trig );

		pan = WhiteNoise.kr( 1 );
		out = TGrains.ar( 2, trig, bufnum, rate, center/sRate, dur, pan, 1.0, 2 );
		eff = out;
		6.do({
			eff = LPF.ar( AllpassC.ar( eff, 0.5, 0.1.rand, 1), 8000 );

		});
		out = out + eff;
		out * 2;

		XFade2.ar(in, out, wet.linlin(0,1,-1,1));
	}
};
Library.put(\modules, \fx, \granulator, ~granulator);

// TGrains2

~pitch_shift = {arg chans = 1, windowsize = 0.2, pitchratio = 1, pitchdisp = 0, timedisp = 0;

	{
		var in = \in.ar(0.dup(chans));
		var fx = PitchShift.ar(in,
			\windowsize.kr(windowsize),
			\pitchratio.kr(pitchratio),
			\pitchdisp.kr(pitchdisp),
			\timedisp.kr(timedisp)
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};
Library.put(\modules, \fx, \pitch_shift, ~pitch_shift);

~freq_shift = {arg chans = 1, freq = 0, phase = 0;

	{
		var in = \in.ar(0.dup(chans));
		var fx = FreqShift.ar(in,
			\freq.kr(freq),
			\phase.kr(0)
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};
Library.put(\modules, \fx, \freq_shift, ~freq_shift);

/*
# 1767 C* ChorusI - Mono chorus/flanger
> a: in (-1 to 1)
> k: t (ms) (2.5 to 40)
> k: width (ms) (0.5 to 10)
> k: rate (Hz) (0 to 5)
> k: blend (0 to 1)
> k: feedforward (0 to 1)
> k: feedback (0 to 1)
< a: out
*/
~chorus = {arg chans = 2;

	{
		var wet, fx, sig;
		var in = \in.ar(0.dup(chans));
		fx = LADSPA.ar(1, 1767,
			in,
			\t.kr(30),
			\width.kr(1.5),
			\rate.kr(2.5),
			1,
			\fwd.kr(0.8),
			\fb.kr(0.2)
		);
		wet = \wet.kr(1);
		XFade2.ar(in, LeakDC.ar(fx), wet.linlin(0,1,-1,1));
	};
};

Library.put(\modules, \fx, \chorus, ~chorus);

)
