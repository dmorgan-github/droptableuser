//  Nathan Ho - "http://sccode.org/1-56v"

(
init: {arg self;
	self[\buf] = Buffer.alloc(s, s.sampleRate * 5);
},

func: {arg self;

	var buf = self[\buf];

	{arg in;

		var dry, snd, phase, iois;
		var cumulDelay;
		var decayFactor, lpfCutoff, numEchoes, ioiScale, ioiDecayFactor;

		decayFactor = 0.75;
		lpfCutoff = 500;
		numEchoes = 16;
		ioiScale = 0.4;
		ioiDecayFactor = 0.75;

		// needs to be a mono signal
		dry = Mix.ar(in);

		phase = DelTapWr.ar(buf, dry);
		iois = Array.geom(numEchoes, ioiScale, ioiDecayFactor);
		cumulDelay = iois.sum;
		snd = Silent.ar;
		iois.reverse.do { |ioi|
			snd = (snd + DelTapRd.ar(buf, phase, cumulDelay, interp: 4)) * decayFactor;
			snd = OnePole.ar(snd, lpfCutoff / SampleRate.ir);
			cumulDelay = cumulDelay - ioi;
		};
		//snd = snd + dry;

		Splay.ar(snd * 0.5);
	};
},

specs: (),

destroy: {arg self;
	self[\buf].free;
}
)
