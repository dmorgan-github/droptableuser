//Server.internal.options.device = "Soundflower (64ch)"; //nil;
//Server.local.options.device = "Soundflower (64ch)"; //nil;
//Server.default = s = Server.internal;
//Server.default = s = Server.local;
//s.boot

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
)

(
~samplesLib = (

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

		if (path.notNil, {
			Buffer.read(s, path:path, action:action);
		}, {
			"Sample not found".error;
		});
	}
);

)

(
~granulator = (

	init_new: {arg self, id, sndbuf;

		var granulatorId = "granulator:" ++ id;
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
			asProxy: {arg self;
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
				Ndef(ndefId);
			}
		);
		granulator;
	}
);

~fmgranulator = (

	init_new: {arg self, id;

		var granulatorId = "fmgranulator:" ++ id;
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
			asProxy: {arg self;
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
				Ndef(ndefId);
			}
		);
		granulator;
	}
);


~ingranulator = (

	init_new: {arg self, id;

		var granulatorId = "ingranulator:" ++ id;
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
			asProxy: {arg self;
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
				Ndef(ndefId);
			}
		);
		granulator;
	}
);

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

~freeze = {arg freeze = 1;

	{arg in;

		var chain1, chain2, inp, frozen, outp;
		var rate = LFNoise1.ar(freeze).range(0, 1).round;

		inp    = in.asArray;//In.ar( 0, 2 ).asArray;
		chain1 = FFT( LocalBuf( 2048 ! 2 ), inp );
		chain1 = PV_MagFreeze( chain1, rate );
		chain2 = FFT( LocalBuf( 2048 ! 2 ), WhiteNoise.ar( 1 ! 2 ));
		chain1 = PV_CopyPhase( chain1, chain2 );
		frozen = IFFT( chain1 ).asArray;
		outp   = (0..1).collect({ arg ch; Select.ar( rate, [ inp[ ch ], frozen[ ch ]])});
		outp;
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

~build1 = { arg func,audio,buffs;
	if(audio.numChannels == 2,{
		Array.fill(2,{ arg i;
			func.value(buffs.at(i),audio.at(i))
		})
	},{
		func.value(buffs.at(0),audio)
	})
};

~pvMagAbove = {arg threshold=32.0;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_MagAbove(chain, threshold );
		IFFT(chain);
	};
};

~pvMagBelow = {arg threshold=1.0;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_MagBelow(chain, threshold );
		IFFT(chain);
	};
};

~pvMagClip = {arg threshold=1.0,gain=1.5;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_MagBelow(chain, threshold );
		IFFT(chain) * gain;
	};
};

~pvMagSmear = {arg threshold=1.0,gain=1.5;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_MagSmear(chain, threshold );
		IFFT(chain) * gain;
	};
};

~pvBinShift = {arg stretch=1.0,shift=0.0;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_BinShift(chain, stretch,shift );
		IFFT(chain);
	};
};

~pvMagShift = {arg stretch=1.0,shift=0.0;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_MagShift(chain, stretch,shift );
		IFFT(chain);
	};
};

~pvMagSquared = {
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_MagSquared(chain);
		IFFT(chain);
	};
};

~pvBrickWall = {arg wipe=0.0,fftbuffl,fftbuffr;
	{arg in;
		var audio = in;
		~build1.value({ arg buff,audio;
			var chain;
			chain = FFT(buff.bufnumIr, audio);
			chain = PV_BrickWall(chain, wipe );
			IFFT(chain);
		},audio,[fftbuffl,fftbuffr]);
	};
};

~pvBinWipe = {arg audio2,wipe=0.0;
	{arg in;
		var audio = in;
		var chain,chain2;
		var maxc;
		maxc = max(audio.numChannels,audio2.numChannels);
		audio2 = NumChannels.ar(audio2,maxc);
		audio = NumChannels.ar(audio,maxc);

		chain = FFT(LocalBuf(2048,1), audio);
		chain2 = FFT(LocalBuf(2048,1), audio2 );
		chain = PV_BinWipe(chain,chain2, wipe );
		IFFT(chain);
	};
};

~pvMagMul = {arg audio2;
	{arg in;
		var audio = in;
		var chain,chain2;
		var maxc;
		maxc = max(audio.numChannels,audio2.numChannels);
		audio2 = NumChannels.ar(audio2,maxc);
		audio = NumChannels.ar(audio,maxc);

		chain = FFT(LocalBuf(2048,1), audio);
		chain2 = FFT(LocalBuf(2048,1), audio2 );
		chain = PV_MagMul(chain,chain2 );
		IFFT(chain);
	};
};

~pvCopyPhase = {arg audio2;
	{arg in;
		var audio = in;
		var chain,chain2;
		var maxc;
		maxc = max(audio.numChannels,audio2.numChannels);
		audio2 = NumChannels.ar(audio2,maxc);
		audio = NumChannels.ar(audio,maxc);

		chain = FFT(LocalBuf(2048,1), audio);
		chain2 = FFT(LocalBuf(2048,1), audio2 );
		chain = PV_CopyPhase(chain,chain2 );
		IFFT(chain);
	};
};

~pvMax = {arg audio2;
	{arg in;
		var audio = in;
		var chain,chain2;
		var maxc;
		maxc = max(audio.numChannels,audio2.numChannels);
		audio2 = NumChannels.ar(audio2,maxc);
		audio = NumChannels.ar(audio,maxc);

		chain = FFT(LocalBuf(2048,1), audio);
		chain2 = FFT(LocalBuf(2048,1), audio2 );
		chain = PV_Max(chain,chain2 );
		IFFT(chain);
	};
};

~pvMin = {arg audio2;
	{arg in;
		var audio = in;
		var chain,chain2;
		var maxc;
		maxc = max(audio.numChannels,audio2.numChannels);
		audio2 = NumChannels.ar(audio2,maxc);
		audio = NumChannels.ar(audio,maxc);

		chain = FFT(LocalBuf(2048,1), audio);
		chain2 = FFT(LocalBuf(2048,1), audio2 );
		chain = PV_Min(chain,chain2 );
		IFFT(chain);
	};
};

~pvRandComb = {arg wipe=0.0, trig=0.0;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_RandComb(chain, wipe,trig );
		IFFT(chain);
	};
};

~pvRectComb = {arg numTeeth=0.0,phase=0.0,width=0.5;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_RectComb(chain, numTeeth,phase,width );
		IFFT(chain);
	};
};

// left channel issue ??
~pvRectComb2 = {arg audio2,numTeeth=0.0,phase=0.0,width=0.5;
	{arg in;
		var audio = in;
		var chain,chain2;
		var maxc;
		maxc = max(audio.numChannels,audio2.numChannels);
		audio2 = NumChannels.ar(audio2,maxc);
		audio = NumChannels.ar(audio,maxc);

		chain = FFT(LocalBuf(2048,1), audio);
		chain2 = FFT(LocalBuf(2048,1), audio2);
		chain = PV_RectComb2(chain, chain2,numTeeth,phase,width );
		IFFT(chain);
	};
};

~pvRandWipe = {arg audio2,wipe=0.0,trig=0.0;
	{arg in;
		var audio = in;
		var chain,chain2;
		var maxc;
		maxc = max(audio.numChannels,audio2.numChannels);
		audio2 = NumChannels.ar(audio2,maxc);
		audio = NumChannels.ar(audio,maxc);

		chain = FFT(LocalBuf(2048,1), audio);
		chain2 = FFT(LocalBuf(2048,1), audio2);
		chain = PV_RandWipe(chain, chain2,wipe,trig);
		IFFT(chain);
	};
};

~pvDiffuser = {arg trig;
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_Diffuser(chain, trig);
		IFFT(chain);
	};
};

~pvMagFreeze = {arg freeze=0.0, fftbuffl, fftbuffr;
	{arg in;
		var audio = in;
		// this can be done in faster stereo
		~build1.value({ arg fftbuff,audio;
			var chain;
			chain = FFT(LocalBuf(2048,1), audio);
			chain = PV_MagFreeze(chain, freeze);
			IFFT(chain);
		},audio,[fftbuffl,fftbuffr]);
	};
};

~pvMagNoise = {
	{arg in;
		var audio = in;
		var chain;
		chain = FFT(LocalBuf(2048,1), audio);
		chain = PV_MagNoise(chain);
		IFFT(chain);
	};
};

~leakLimBPF = {arg coef=0.8,ffreq=1000,rq=0.5,fboost=0.2;
	{arg in=0.0;
		var audio = in;
		audio = LeakDC.ar(audio,coef);
		Limiter.ar( (audio + BPF.ar(audio,ffreq,rq,fboost)), 0.999);
	};
};

~limiter = {arg level = 1, dur = 0.01;
	{arg in;
		Limiter.ar(LeakDC.ar(in), level, dur);
	};
};

~threeChan = {arg xover1=400, xover2=9000, lov=1.0, midv=1.0, hiv=1.0, threshold=0.5, slope=0.5, drive=1.0;

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

		var comp = {arg audio=0.0, threshold=0.5, slope=0.5, clampTime=0.1, relaxTime=0.3;
			Compander.ar(audio, Mono(audio).max(0.0001), threshold, 1.0 , slope, clampTime, relaxTime);
		};

		var lo,mid,hi;
		#lo,mid,hi = lomidhi.value(audio, xover1, xover2, lov, midv, hiv);

		audio = Mix.new([lo,mid,hi]);
		audio = comp.value(audio,threshold,slope);

		Limiter.ar(audio * drive);
	};
};

~str = {arg obj, postString = false;
	if (postString, {
		obj.postString
	}, {
		var result = "(";
		obj.argNames.do({arg a, i;
			if (i > 0,{
				result = result ++ ", ";
			});
			result = result ++ a ++ ": " ++ obj.defaultArgs.at(i);
		});
		result = result ++ ")";
		result.postln;
	});
};

)

// ------------------

(
//~hf.value();
u = Buffer.sendCollection(s, Env.linen(1,0.5,0.5,curve:-4).discretize, 1);
w = Buffer.sendCollection(s, Env.perc.discretize, 1);
y = Buffer.sendCollection(s, Env([0.001, 1], [0.1], \exp).discretize, 1);
z = Buffer.sendCollection(s, Env.linen.discretize, 1);

~samplesLib.ls();
~samplesLib.load("unchained.aiff", {arg buf; a = buf;});


/******************************************
Gran 1
*******************************************/
(
i = ~granulator.init_new("gran1", a);
i.setTrig({
	Impulse.ar(5.5)
});
i.setDur({
	//SinOsc.ar(2).range(0.3, 0.6);
	DC.ar(0.7)
});
i.setStart( {
	//WhiteNoise.ar().range(0.6, 0.8)
	LFNoise1.ar(5).range(0.63, 0.8)
} );
i.setRate ( {
	DC.ar(1)
} );
i.setEnvbuf({
	DC.ar(-1)
});
i.setPan({
	LFNoise1.ar(0.1).range(-0.6, 0.6);
});
j = i.asProxy();
j.fadeTime = 1;
j.set(\amp, 0.3);
j[1] = \filter -> ~threeChan.(lov:0.3, midv:0.9, hiv:1);

//j.play;
//j.stop(10)
)

/******************************************
Gran 3
*******************************************/
(
b = { Buffer.alloc(s,2048,1) }.dup;
m = ~granulator.init_new("gran3", a);
m.setTrig({
	Impulse.ar(5)
});
m.setDur({
	LFNoise1.ar(4).range(1, 2)
});
m.setStart( {
	LFPulse.ar(SinOsc.ar(2).range(1,3)).range(0.6, 0.8)
} );
m.setRate ( {
	DC.ar(1)
	//LFNoise1.ar(2).range(0., 1)
} );
m.setEnvbuf({
	DC.ar(-1);
});
m.setPan({
	LFNoise1.ar(0.1).range(-0.3, 0.3);
});
n = m.asProxy();
n.set(\amp, 0.6);

n[1] = \filter -> {arg in;

	var chain1, chain2, inp, frozen, outp;
	var freeze = LFNoise1.ar(1).range(0,1).round;

	inp = in;
	chain1 = FFT( LocalBuf( 2048 ! 2 ), inp );
	chain1 = PV_MagFreeze( chain1, freeze );
	chain2 = FFT( LocalBuf( 2048 ! 2 ), WhiteNoise.ar( 1 ! 2 ));
	chain1 = PV_CopyPhase( chain1, chain2 );
	//frozen = IFFT( chain1 ).asArray;

	//outp   = (0..1).collect({ arg ch; Select.ar( freeze, [ inp[ ch ], frozen[ ch ]])});
	//outp;
	//frozen;
	IFFT( chain1 );
};

n[2] = \filter -> ~reverb1.();
n[3] = \filter -> ~echo.(decay:2.5);
n[4] = \filter -> ~threeChan.(xover1:500, threshold: 0.1, slope: 0, lov:0.3, midv:0.8, hiv:0.5);


~str.(~threeChan);
//n.play;
//n.stop;
)


/******************************************
Gran 5
*******************************************/
(
q = ~granulator.init_new("gran5", a);
q.setTrig({
	Impulse.ar(LFSaw.ar(2).range(1,10))
	//Dust.ar(LFSaw.ar(2).range(3,10))
});
q.setDur({
	LFPulse.ar(1).range(0.2,2)
});
q.setStart( {
	LFSaw.ar(2).range(0.01, 0.02)
});
q.setRate ( {
	DC.ar(1)
} );
q.setEnvbuf({
	DC.ar(-1)
});
q.setPan({
	DC.ar(0);
});
t = q.asProxy();
t.fadeTime = 1;
t[1] = \filter -> ~echo.();
t[2] = \filter -> ~threeChan.(lov:1, midv:0.9, hiv:1);

t.set(\amp, 0.8);
//t.play;
)

FreqScope.new

//s.prepareForRecord("/Users/dmorgan/supercollider/do/unbrained/unbrained3.aiff");
//s.record();
//s.stopRecording();
(
//s.record();
Tdef(\main, {

	t.stop(5);
	t.play;
	10.wait;

	Tdef(\a, {
		loop({
			n.play;
			10.wait;
			n.stop(5);
			10.wait;
		});
	}).play;

	20.wait;
	j.play;
	30.wait;
	j.stop(10);
	10.wait;
	t.stop(5);
	15.wait;

	j.fadeTime = 2;
	j.play;
	i.setDur({ LFPulse.ar(0.01).range(0.5, 1); });
	i.setRate ( { LFNoise1.ar(2).range(0.5, 1); } );
	i.setPan ( { DC.ar(0) } );
	5.wait;
	j.stop(7);

	10.wait;
	n.stop(5);
	Tdef(\a).stop

}).play;
)


InstrBrowser.new.gui
