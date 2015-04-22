(
~sf = {
	s.quit;
	Server.internal.options.device = "Soundflower (64ch)"; //nil;
	Server.local.options.device = "Soundflower (64ch)"; //nil;
	s.boot;
};
~hf = {
	s.quit;
	Server.internal.options.device = nil;
	Server.local.options.device = nil;
	s.boot;
};
~str = {arg obj, postString = false;
	if (postString, {
		obj.postString
	}, {
		if (obj.isFunction, {
			var result = "(";
			obj.argNames.do({arg a, i;
			if (i > 0,{
				result = result ++ ", ";
			});
				result = result ++ a ++ ": " ++ obj.defaultArgs.at(i);
			});
			result = result ++ ")";
			result.postln;
		}, {
			var keys = obj.keys;
			keys.do({arg key;
				key.postln;
			});
		});
	});
};

/*************************************************
~samples
*************************************************/
~samples = (

	default_dir: "/Users/dmorgan/supercollider/samples/",
	samples_list: nil,
	ls: {arg self, path;

		var folder;
		if (path.isNil, {
			path = self.default_dir;
		});

		self.samples_list = List.new;
		folder = PathName.new(path);
		"---------------------------".postln;
		folder.filesDo {arg path;
			path.fullPath.postln;
			self.samples_list.add(path.fullPath);
        };
		"---------------------------".postln;
	},

	load: {arg self, name, action;

		var len = 0;
		var i = 0;
		var path = nil;
		var found = false;
		var buf = nil;

		if (self.samples_list.isNil, {
			self.ls();
		});

		len = self.samples_list.size();
		while( {(found == false) && (i < len)}, {
			var p = self.samples_list.at(i);
			if ( p.containsi(name), {
				path = p;
				found = true;
			});
			i = i + 1;
		});

		if (self.at(name.asSymbol).isNil, {
			if (path.notNil, {
				if (action.notNil, {
					format("loading %", name).postln;
					Buffer.read(s, path:path, action:action);
				}, {
					format("loading %", name).postln;
					buf = Buffer.read(s, path:path);
					self.put(name.asSymbol, buf);
				});
			}, {
				"Sample not found".error;
			});
		},{
			format("Sample already loaded -> %", name).postln;
			buf = self[name.asSymbol];
		});
		buf;
	}
);

/*************************************************
~grainbuf
*************************************************/

~grainbuf = {arg id, sndbuf;
	var granulatorId = "grainbuf:" ++ id;
	var granulator;
	var trigId = (granulatorId ++ ":trig").asSymbol;
	var rateId = (granulatorId ++ ":rate").asSymbol;
	var panId = (granulatorId ++ ":pan").asSymbol;
	var startId = (granulatorId ++ ":start").asSymbol;
	var durId = (granulatorId ++ ":dur").asSymbol;
	var sndbufId = (granulatorId ++ ":sndbuf").asSymbol;
	var envbufId = (granulatorId ++ ":envbuf").asSymbol;
	var ndefId = (granulatorId ++ ":ndef").asSymbol;

	// initialize with reasonable defaults
	Ndef(trigId, {Impulse.ar(1);});
	Ndef(rateId, {DC.ar(1);});
	Ndef(panId, {DC.ar(0);});
	Ndef(startId, {DC.ar(0.1);});
	Ndef(durId, {DC.ar(0.5);});
	Ndef(sndbufId, {DC.ar(sndbuf);});
	Ndef(envbufId, {DC.ar(-1);});

	Ndef(ndefId).ar(2);
	Ndef(ndefId).source = {arg amp = 0.5;
		GrainBuf.ar(2,
			trigger:Ndef(trigId).ar,
			dur:Ndef(durId).ar,
			sndbuf:Ndef(sndbufId).ar,
			rate:Ndef(rateId).ar,
			pos:Ndef(startId).ar,
			pan:Ndef(panId).ar,
			envbufnum:Ndef(envbufId).ar,
			mul:amp
			);
	};

	granulator = (
		setTrig: {arg self, obj;
			Ndef(trigId, obj);
		},
		setRate: {arg self, obj;
			Ndef(rateId, obj);
		},
		setPan: {arg self, obj;
			Ndef(panId, obj);
		},
		setStart: {arg self, obj;
			Ndef(startId, obj);
		},
		setDur: {arg self, obj;
			Ndef(durId, obj);
		},
		setSndbuf: {arg self, obj;
			Ndef(sndbufId, obj);
		},
		setEnvbuf: {arg self, obj;
			Ndef(envbufId, obj);
		},
		proxy: Ndef(ndefId)
	);
	granulator;
};

/*************************************************
~grainfm
*************************************************/
~grainfm = {arg id;
	var granulatorId = "grainfm:" ++ id;
	var granulator;
	var trigId = (granulatorId ++ ":trig").asSymbol;
	var carfreqId = (granulatorId ++ ":carfreq").asSymbol;
	var panId = (granulatorId ++ ":pan").asSymbol;
	var modfreqId = (granulatorId ++ ":modfreq").asSymbol;
	var indexId = (granulatorId ++ ":index").asSymbol;
	var durId = (granulatorId ++ ":dur").asSymbol;
	var envbufId = (granulatorId ++ ":envbuf").asSymbol;
	var ndefId = (granulatorId ++ ":ndef").asSymbol;

	// initialize with reasonable defaults
	Ndef(trigId, {Impulse.ar(1);});
	Ndef(durId, {DC.ar(0.5);});
	Ndef(carfreqId, { WhiteNoise.ar() + 440; });
	Ndef(modfreqId, { DC.ar(200) });
	Ndef(indexId, {DC.ar(1);});
	Ndef(panId, {DC.ar(0);});
	Ndef(envbufId, {DC.ar(-1);});

	Ndef(ndefId).ar(2);
	Ndef(ndefId).source = {arg amp = 0.5;
		GrainFM.ar(2,
			trigger:Ndef(trigId).ar,
			dur:Ndef(durId).ar,
			carfreq:Ndef(carfreqId).ar,
			modfreq:Ndef(modfreqId).ar,
			index:Ndef(indexId).ar,
			pan:Ndef(panId).ar,
			envbufnum:Ndef(envbufId).ar,
			mul:amp);
	};

	granulator = (
		setTrig: {arg self, obj;
			Ndef(trigId, obj);
		},
		setDur: {arg self, obj;
			Ndef(durId, obj);
		},
		setCarfreq: {arg self, obj;
			Ndef(carfreqId, obj);
		},
		setModfreq: {arg self, obj;
			Ndef(modfreqId, obj);
		},
		setIndex: {arg self, obj;
			Ndef(indexId, obj);
		},
		setPan: {arg self, obj;
			Ndef(panId, obj);
		},
		setEnvbuf: {arg self, obj;
			Ndef(envbufId, obj);
		},
		proxy: Ndef(ndefId)
	);
	granulator;
};

/*************************************************
grainin
*************************************************/
~grainin = {arg id;
	var granulatorId = "grainin:" ++ id;
	var granulator;
	var trigId = (granulatorId ++ ":trig").asSymbol;
	var inId = (granulatorId ++ ":in").asSymbol;
	var panId = (granulatorId ++ ":pan").asSymbol;
	var durId = (granulatorId ++ ":dur").asSymbol;
	var envbufId = (granulatorId ++ ":envbuf").asSymbol;
	var ndefId = (granulatorId ++ ":ndef").asSymbol;

	// initialize with reasonable defaults
	Ndef(trigId, {Impulse.ar(1);});
	Ndef(durId, {DC.ar(0.5);});
	Ndef(inId, { PinkNoise.ar * 0.05; });
	Ndef(panId, {DC.ar(0);});
	Ndef(envbufId, {DC.ar(-1);});

	Ndef(ndefId).ar(2);
	Ndef(ndefId).source = {arg amp = 0.5;
		GrainIn.ar(2,
			trigger:Ndef(trigId).ar,
			dur:Ndef(durId).ar,
			in:Ndef(inId).ar,
			pan:Ndef(panId).ar,
			envbufnum:Ndef(envbufId).ar,
			mul:amp);
	};

	granulator = (
		setTrig: {arg self, obj;
			Ndef(trigId, obj);
		},
		setDur: {arg self, obj;
			Ndef(durId, obj);
		},
		setIn: {arg self, obj;
			Ndef(inId, obj);
		},
		setPan: {arg self, obj;
			Ndef(panId, obj);
		},
		setEnvbuf: {arg self, obj;
			Ndef(envbufId, obj);
		},
		proxy: Ndef(ndefId)
	);
	granulator;
};

/*************************************************
fx
*************************************************/
~fx = ();

~echo = {arg decay = 1, allpasses = 5, gain = 1;
	{arg in;
		var source = in;
		allpasses.do({ source = AllpassN.ar(source, 0.5, [Rand(0, 0.5), Rand(0, 0.5)], decay) }; );
		source * gain;
	};
};

~reverb1 = {

	{arg in;

		var output, delrd, sig, deltimes;

		// Read our 4-channel delayed signals back from the feedback loop
		delrd = LocalIn.ar(4);

		// This will be our eventual output, which will also be recirculated
		output = in + delrd[[0,1]];

		sig = output ++ delrd[[2,3]];
		// Cross-fertilise the four delay lines with each other:
		sig = ([ [1,  1,  1,  1],
			[1, -1,  1, -1],
			[1,  1, -1, -1],
			[1, -1, -1,  1]] * sig).sum;

		// Attenutate the delayed signals so they decay:
		sig = sig * [0.4, 0.37, 0.333, 0.3];

		// Here we give delay times in milliseconds, convert to seconds,
		// then compensate with ControlDur for the one-block delay
		// which is always introduced when using the LocalIn/Out fdbk loop
		deltimes = [101, 143, 165, 177] * 0.001 - ControlDur.ir;

		// Apply the delays and send the signals into the feedback loop
		LocalOut.ar(DelayC.ar(sig, deltimes, deltimes));

		// Now let's hear it:
		//Out.ar(0, output);
		output;
	}
};

~dissonator = {
	{arg in;
		var mix = 1.0;
		var filterfreqs = Array.geom(23, 60, 2**(1/3));
		var rq = ((2**(1/3)) - 1) / (2**(1/6));
		var width = 2**(1/6);
		var fmin = filterfreqs / width;
		var fmax = filterfreqs * width;
		var g = { |f| 2.27 * (f**0.477) };
		var snd, mod;
		snd = in;
		snd = BPF.ar(snd, filterfreqs, rq);
		mod = SinOsc.ar(0.5 * g.value((0.2*fmin) + (0.8*fmax)));
		mod = (1 - mix) + (mix * mod);
		snd = snd * mod;
		snd = Mix(snd);
		snd;
	};
};

~combsAllpasses = {arg delay=0.1, decay=15, combs=7, maxDelay=0.5, allpasses=4, allpassDecay=1;
	{arg in;
		var audio = in;
		var y;
		y = Mix.fill(combs,{ CombL.ar(audio, maxDelay, delay, decay) });
		allpasses.do({ y = AllpassL.ar(y, 0.05, [0.05.rand, 0.05.rand], allpassDecay) });
		y;
	};
};

~pitchshift = {arg pchDispersion=1.01, timeDispersion=1.01, pchRatio=0.5, winSize=0.2;
	{arg in;
		var audio = in;
		PitchShift.ar(
			audio,
			winSize,
			pchRatio,
			pchDispersion,
			timeDispersion
		);
	};
};

~exciterL = {arg microDelay = 0.2, maxDelay=0.2, ffreq=60, drive=1.0, thru=0.0;

	{arg in;
		var audio = in;
		if(thru != 0.0,{ thru = audio * thru });
		DelayL.ar( HPF.ar(audio, ffreq, drive), maxDelay, microDelay, 1.0, thru);
	};
};

~exciterN = {arg microDelay = 0.2, maxDelay=0.2, ffreq=60, drive=1.0, thru=0.0;
	{arg in;
		var audio = in;
		if(thru != 0.0,{ thru = audio * thru });
		DelayN.ar( HPF.ar(audio,ffreq,drive), maxDelay ,microDelay, 1.0, thru);
	};
};

~ptchDustFlip = {arg pchRatio=0.5, density=5, winSize=0.2, pchDispersion=0.01, lag=0.01;
	{arg in;
		var audio = in;
		var  pitched, flippy;
		flippy = Lag.kr(ToggleFF.kr(Dust.kr(density)),lag,pchRatio,0.5);
		pitched = PitchShift.ar(audio, winSize, flippy, pchDispersion);
		pitched;
	}
};

~ptchThreshFlip = {arg pchRatio=0.5,threshold=0.8,winSize=0.2,pchDispersion=0.01,lag=0.01;
	{arg in;
		var audio = in;
		var  pitched,flippy;
		flippy = Lag.kr(Amplitude.kr(Mono(audio)) > threshold ,lag, pchRatio, 0.5);
		pitched = PitchShift.ar(audio, winSize, flippy, pchDispersion);
		pitched;
	}
};

~ptchToggFlip = {arg pchRatio=0.5,threshold=0.8,winSize=0.2,pchDispersion=0.01,lag=0.01;
	{arg in;
		var audio = in;
		var  pitched,flippy;
		flippy=Lag.kr(ToggleFF.kr( Amplitude.kr(Mono(audio)) > threshold),lag,pchRatio,0.5);
		pitched = PitchShift.ar(audio, winSize, flippy, pchDispersion);
		pitched;
	}
};

~qAllpassA = {arg decay=1, maxDelay=0.3, qnty=4, chanDiff=0.1;
	{arg in;
		var audio = in;
		(qnty.asInteger).do({
			var x;
			audio = AllpassL.ar(audio, maxDelay, [rrand(0.01,maxDelay),rrand(0.01,maxDelay)], decay)
		});
		audio;
	};
};

~qAllpassL = {arg decay=1, maxDelay=0.3, qnty=4;
	{arg in;
		var audio = in;
		(qnty.asInteger).do({
			var x;
			audio = AllpassL.ar(audio, maxDelay, [rrand(0.01,maxDelay),rrand(0.01,maxDelay)], decay)
		});
		audio;
	}
};

~pvfreeze = {arg rate = 1;
	{arg in;

		var freeze = LFNoise1.ar(rate).range(0, 1).round;
		var chain = FFT( LocalBuf( 2048 ! 2 ), in);
		chain = PV_Freeze( chain, freeze ); //SC3 plugin
		IFFT(chain);
	};
};

~pvCopyPhase = {
	/*
	var chain1, chain2, inp, frozen, outp;
	inp    = in;
	chain1 = FFT( LocalBuf( 2048 ! 2 ), inp );
	chain1 = PV_MagFreeze( chain1, freeze );
	chain2 = FFT( LocalBuf( 2048 ! 2 ), WhiteNoise.ar( 1 ! 2 ));
	chain1 = PV_CopyPhase( chain1, chain2 );

	//outp =
	//Select.ar(freeze, [in, IFFT(chain1)]);
	IFFT(chain1);
	*/
};

~pvBinShiftLFO = {arg stretch=[1,0,1], shift=[1,0,1];
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048 ! 2), audio);
		chain = PV_BinShift(chain,
			LFNoise1.ar(stretch[0]).range(stretch[1], stretch[2]),
			LFNoise1.ar(shift[0]).range(shift[1], shift[2]));
		IFFT(chain);
	};
};

~pvMagSmear = {arg threshold=1.0, gain=1.5;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048 ! 2), audio);
		chain = PV_MagSmear(chain, threshold );
		IFFT(chain) * gain;
	};
};

~pvMagSmearLFO = {arg threshold=[1,0,1], gain=1.5;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048 ! 2), audio);
		chain = PV_MagSmear(chain, LFNoise1.ar(threshold[0]).range(threshold[1], threshold[2]) );
		IFFT(chain) * gain;
	};
};

~pvMagShift = {arg stretch=1.0,shift=0.0;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048 ! 2), audio);
		chain = PV_MagShift(chain, stretch, shift );
		IFFT(chain);
	};
};

~pvMagSquared = {
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048 ! 2), audio);
		chain = PV_MagSquared(chain);
		IFFT(chain);
	};
};

~stereo2Exc = {arg microDelay = 0.2, maxDelay=0.2, ffreq=1000, drive=5.0, panDepth=0.05, lfo=1.0, decay=0.1, thru=0.0;
	{arg in;

		var audio = in;
		var panner;
		if(thru != 0.0,{ thru = audio * thru });

		panner = FSinOsc.kr(lfo,panDepth);
		microDelay = microDelay;

		CombL.ar(
			HPF.ar(audio,ffreq,drive).softclip,
			maxDelay ,
			[max(0.001,microDelay + panner),max(0.001,microDelay - panner)] ,
			decay,
			1.0,
			thru
		)
	};
};

~stereoExc = {arg microDelay = 0.2, maxDelay=0.2, ffreq=4000, drive=5.0,panDepth = 0.5,thru=0.0;
	{arg in;
		var audio = in;
		if(thru != 0.0,{ thru = audio * thru });
		DelayL.ar( HPF.ar(audio,ffreq,drive), maxDelay ,[microDelay,(microDelay - panDepth).max(0.001)] , 1.0, thru);
	}
};


~leakLimBPF = {arg coef=0.8,ffreq=1000,rq=0.5,fboost=0.2;
	{arg in=0.0;
		var audio = in;
		audio = LeakDC.ar(audio,coef);
		Limiter.ar( (audio + BPF.ar(audio,ffreq,rq,fboost)), 0.999);
	};
};

~compress = {arg ratio=3, threshdb=8, attackTime=0.016, relaxTime=0.05;
	{arg in;

		Compander.ar(2*in,
			in,
			(threshdb.neg).dbamp,
			1.0,
			ratio.reciprocal,
			attackTime,
			relaxTime);
	};
};

~threeChan = {arg xover1=400, xover2=9000, lov=1.0, midv=1.0, hiv=1.0, ratio=3, threshdb=8, drive=1.0;

	{arg in;
		var audio = in;
		var lomidhi = {arg audio=0.0, xover1=200, xover2=4000, logain=1.0, midgain=1.0, higain=1.0;

			var lo,mid,hi,rest;
			lo = RLPF.ar(audio, xover1, 0.4);
			rest = audio - lo;
			mid = LPF.ar(rest, xover2);
			hi = rest - mid;

			lo = if(logain == 1.0,{lo},{lo*logain});
			mid = if(midgain == 1.0,{mid},{mid*midgain});
			hi = if(higain == 1.0,{hi},{hi*higain});
			[ lo, mid, hi ];
		};

		/*
		input = BLowShelf.ar(input, *frdb[0][[0,2,1]].lag(0.1));
        input = BPeakEQ.ar(input, *frdb[1][[0,2,1]].lag(0.1));
        input = BPeakEQ.ar(input, *frdb[2][[0,2,1]].lag(0.1));
        input = BPeakEQ.ar(input, *frdb[3][[0,2,1]].lag(0.1));
        input = BHiShelf.ar(input, *frdb[4][[0,2,1]].lag(0.1));
        input = RemoveBadValues.ar(input);

		frpresets = [// x_ = cannot delete or modify
            'x_flat', [[100, 0, 1], [250, 0, 1], [1000, 0, 1], [3500, 0, 1],
                [6000, 0, 1]],
            'x_loudness', [[78.0, 7.5, 0.65], [250, 0, 1], [890.0, -9.5, 3.55],
                [2800.0, 3.5, 1.54], [7400.0, 7.0, 1.0]],
            'x_telephone', [[600.0, -22.0, 0.7], [250, 0, 1], [1200.0, -2.0, 0.5],
                [1800.0, 1.0, 0.5], [4000.0, -22.0, 0.7]]
        ];
		*/

		var compFunc = ~compress.value(ratio:ratio, threshdb:threshdb);

		var lo,mid,hi;
		#lo,mid,hi = lomidhi.value(audio, xover1, xover2, lov, midv, hiv);

		audio = Mix.new([lo,mid,hi]);
		audio = compFunc.value(audio);

		Limiter.ar(audio * drive);
	};
};

)