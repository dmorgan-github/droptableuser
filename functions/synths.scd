(
~fx = {arg id, func;

	var synthId = id.asSymbol;
	SynthDef.new(synthId, {arg in, out, wet = 0;

		var sig = In.ar(in);
		var env = EnvGate.new;
		var fx = SynthDef.wrap(func, nil, sig);
		in = XFade2.ar(sig, fx, wet); // -1, 1
		XOut.ar(out, env, in);
	});
};

SynthDef(\samplr, {arg numChannels = 1, buf, trigger = 1, startPos = 0, loop = 0, out = 0, amp = 0.5;

	var sig = PlayBuf.ar(numChannels:1,
		bufnum:buf,
		rate:BufRateScale.kr(buf),
		trigger: trigger,
		startPos: startPos,
		loop: loop,
		doneAction:2);

	OffsetOut.ar(out, sig * amp);

}).add;

SynthDef(\gverb, {arg in = 0, out = 0,
	roomsize = 10, revtime = 3, damping = 0.5, inputbw = 0.5, spread = 15, drylevel = 1,
	earlyreflevel = 0.7, taillevel = 0.5, maxroomsize = 300, mix = 0;

	var env = EnvGate.new;
	var sig = In.ar(in);
	var fx = GVerb.ar(sig,
		roomsize,
		revtime,
		damping,
		inputbw,
		spread,
		drylevel,
		earlyreflevel,
		taillevel,
		maxroomsize);
	sig = XFade2.ar(sig, fx, mix);
	XOut.ar(out, env, sig);
}).add;

SynthDef(\freeverb, {arg in = 0, out = 0, wet = 0, mix = 0.33, room = 0.5, damp = 0.5;

	var env = EnvGate.new;
	var sig = In.ar(in);
	var fx = Mix.arFill(2, {FreeVerb.ar(sig, mix, room, damp)});
	sig = XFade2.ar(sig, fx, wet);
	XOut.ar(out, env, sig);
}).add;

SynthDef(\delayC, {arg in = 0, out = 0, wet = 0, maxdelaytime = 0.2, delaytime = 0.2, amp = 1;

	var sig = In.ar(in);
	var fx = DelayC.ar(
		in:sig,
		maxdelaytime: maxdelaytime,
		delaytime: delaytime,
		mul: amp
	);
	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet)
	);
}).add;

SynthDef(\allpassC, {arg in = 0, out = 0, wet = 0, maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1, amp = 1;

	var sig = In.ar(in);
	var fx = AllpassC.ar(
		in:sig,
		maxdelaytime: maxdelaytime,
		delaytime: delaytime,
		decaytime: decaytime,
		mul: amp
	);
	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet)
	);
}).add;

SynthDef(\combC, {arg in = 0, out = 0, wet = 0, maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1, amp = 1;

	var sig = In.ar(in);
	var fx = CombC.ar(
		in: sig,
		maxdelaytime: maxdelaytime,
		delaytime: delaytime,
		decaytime: decaytime,
		mul: amp
	);
	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet)
	);
}).add;

SynthDef(\binshift, {arg in = 0, out = 0, wet = 0, stretch = 1, shift = 0, amp = 1;

	var sig = In.ar(in);
	var fx = {
		var chain = FFT(LocalBuf(2048, 1), sig);
		// Shift and scale the positions of the bins.
		// Can be used as a very crude frequency shifter/scaler.
		chain = PV_BinShift(chain, stretch, shift);
		IFFT(chain) * amp;
	}.value;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet)
	);
}).add;

SynthDef(\magshift, {arg in = 0, out = 0, wet = 0, stretch = 1, shift = 0, amp = 1;

	var sig = In.ar(in);
	var fx = {
		var chain;
		chain = FFT(LocalBuf(2048, 1), sig);
		// Shift and stretch the positions of only the magnitude of the bins.
		// Can be used as a very crude frequency shifter/scaler.
		chain = PV_MagShift(chain, stretch, shift);
		IFFT(chain) * amp;
	}.value;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet)
	);
}).add;

SynthDef(\magsmear, {arg in = 0, out = 0, wet = 0, bins = 1, amp = 1;

	var sig = In.ar(in);
	var fx = {
		var chain = FFT(LocalBuf(2048,1), sig);
		// Average a bin's magnitude with its neighbors.
		chain = PV_MagSmear(chain, bins);
		IFFT(chain) * amp;
	}.value;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet)
	);
}).add;

SynthDef(\magsquared, {arg in = 0, out = 0, wet = 0, amp = 1;

	var sig = In.ar(in);
	var fx = {
		var chain = FFT(LocalBuf(2048, 1), sig);
		// Squares the magnitudes and renormalizes to previous peak.
		// This makes weak bins weaker.
		chain = PV_MagSquared(chain);
		IFFT(chain) * amp;
	}.value;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet)
	);
}).add;

SynthDef(\randcomb, {arg in = 0, out = 0, wet = 0, wipe = 0, rate = 1, amp = 1;

	var sig = In.ar(in);
	var fx = {

		var trig = Impulse.ar(rate);
		var chain = FFT(LocalBuf(2048,1), sig);
		// Randomly clear bins.
		chain = PV_RandComb(chain, wipe, trig);
		IFFT(chain);
	}.value;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet)
	);
}).add;

SynthDef(\randwipe, {arg in1 = 0, in2 = 0, out = 0, wet = 0, wipe = 0, rate = 1, amp = 1;

	var sig1 = In.ar(in1);
	var sig2 = In.ar(in2);

	var fx = {

		var chain, chain2, audio, audio2;
		var maxc;
		var trig = Impulse.ar(rate);
		maxc = max(sig1.numChannels, sig2.numChannels);
		audio2 = NumChannels.ar(sig2, maxc);
		audio = NumChannels.ar(sig1, maxc);

		chain = FFT(LocalBuf(2048,1), audio);
		chain2 = FFT(LocalBuf(2048,1), audio2);
		// Crossfades between two sounds by copying bins in a random order.
		chain = PV_RandWipe(chain, chain2,wipe,trig);
		IFFT(chain) * amp;
	}.value;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig1, fx, wet)
	);
}).add;

SynthDef(\binwipe, {arg in1 = 0, in2 = 0, out = 0, wet = 0, wipe=0, amp = 1;

	var sig1 = In.ar(in1);
	var sig2 = In.ar(in2);

	var fx = {

		var chain, chain2;
		var audio, audio2;
		var maxc = max(sig1.numChannels, sig2.numChannels);
		audio = NumChannels.ar(sig1, maxc);
		audio2 = NumChannels.ar(sig2, maxc);

		chain = FFT(LocalBuf(2048,1), audio);
		chain2 = FFT(LocalBuf(2048,1), audio2 );
		// Copies low bins from one input and the high bins of the other.
		chain = PV_BinWipe(chain, chain2, wipe);
		IFFT(chain) * amp;
	}.value;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig1, fx, wet);
	);
}).add;

SynthDef(\diffuser, {arg in = 0, out = 0, wet = 0, amp = 1, rate = 1;

	var sig = In.ar(in);
	var fx = {

		var trig = Impulse.ar(rate);
		var chain = FFT(LocalBuf(2048, 1), sig);
		// Adds a different constant random phase shift to each bin.
		// When triggered, it selects a new set of random phases
		chain = PV_Diffuser(chain, trig);
		IFFT(chain) * amp;
	}.value;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet);
	);
}).add;

SynthDef(\magnoise, {arg in = 0, out = 0, wet = 0, amp = 1;

	var sig = In.ar(in);
	var fx = {

		var chain = FFT(LocalBuf(2048,1), sig);
		// Magnitudes are multiplied with noise.
		chain = PV_MagNoise(chain);
		IFFT(chain) * amp;
	}.value;

	XOut.ar(
		out,
		EnvGate.new,
		XFade2.ar(sig, fx, wet);
	);
}).add;



SynthDef(\rndpan, {arg in = 0, out = 0, rate = 0.1, left = -1, right = 1, amp = 1;

	var sig = NumChannels.ar(In.ar(in), 1);
	var fx = Pan2.ar(sig, LFNoise2.kr(rate).range(left, right));
	Out.ar(out, fx * amp);
}).add;

SynthDef(\splay, {arg in = 0, out = 0, amp = 1;

	var sig = NumChannels.ar(In.ar(in), 2);
	var fx = Splay.ar(sig);
	Out.ar(out, fx * amp);
}).add;
)