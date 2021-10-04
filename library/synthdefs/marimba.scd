(
SynthDef(\marimba, {
	arg
	// Standard values
	out = 0, freq = 440, amp = 0.1, att = 0.001, dec = 0.1, rel = 0.5, pan = 0,
	// Other controls, position goes from 0 to 1
	decCoef = 2, position = 0.414, ampSlope = 3;

	var freqarray, amparray, decarray, mallet, snd;

	// Array of frequencies, determined by solutions to the dynamic beam equation
	freqarray = Array.fill(30, { arg i; i + 1.5});
        freqarray[0] = 1.50561873;
	    freqarray[1] = 2.49975267;
	    freqarray = freqarray/1.50561873; // Normalize to freqarray[0] = 1

	// Array of amplitudes
	amparray = Array.fill(30, { arg i;
		if (freqarray[i] > 20000)
		    { 0 }
		    {
		        sin(((i + 1) * pi) * position) *
		        (ampSlope * (freqarray[i]).log2).dbamp
		    }
	});

	// Array of Decay times
	decarray = Array.fill(30, { arg i;
		exp(-1 * i * decCoef)
	}); // The decay times are dropping off exponentially

	// Hit the object
	mallet = Decay2.ar(
		in: Impulse.ar(0),
		attackTime: att,
		decayTime: dec,
		mul: 0.1);

	// Bank of resonators
	snd = Klank.ar(
		specificationsArrayRef: Ref.new([freqarray, amparray, decarray]),
		input: mallet,
		freqscale: freq,
		decayscale: rel);

	// Output stuff
	snd = Mix.ar(snd) * amp * \vel.kr(1);
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "by Josh Mitchell",
	category: \percussion,
	tags: [\pitched, \modal]
)).add;
)

