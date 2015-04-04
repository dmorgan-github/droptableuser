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

~freeze = {arg rate = 1;

	{arg in;
		var chain1, chain2, inp, frozen, outp;
		var freeze = LFNoise1.ar(rate).range(0, 1).round;
		inp    = in;
		chain1 = FFT( LocalBuf( 2048 ! 2 ), inp );
		chain1 = PV_MagFreeze( chain1, freeze );
		chain2 = FFT( LocalBuf( 2048 ! 2 ), WhiteNoise.ar( 1 ! 2 ));
		chain1 = PV_CopyPhase( chain1, chain2 );
		IFFT(chain1);
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
~samplesLib.load("tibet.mono", {arg buf; c = buf;});

/*
d = List.new();
10.do({
	Buffer.sendCollection(s, Env.xyc({ [1.0.rand, 1.0.rand, -4.rand2] } ! 16, \exp).discretize, 1,
		action:{arg buf;
			d.add(DC.ar(buf.bufnum))
		}
	);
});
*/


/******************************************
Gran 1
*******************************************/

q = ();

q.gran1 = ~granulator.init_new("gran1", a);
q.gran1.setTrig({
	Dust.ar(0.5);
});
q.gran1.setDur({
	LFNoise1.ar(1).range(2, 3)
});
q.gran1.setStart( {
	LFNoise1.ar(5).range(0.65, 0.8)
} );
q.gran1.setRate ( {
	DC.ar(1)
} );
q.gran1.setEnvbuf({
	Select.ar( TRand.ar(0, d.size(), Impulse.ar(3)).round, d);
});
q.gran1.setPan({
	LFNoise1.ar(1).range(-0.7, 0.7);
});
q.gran1.proxy.fadeTime = 1;
q.gran1.proxy.set(\amp, 0.4);
//q.gran1.proxy[1] = nil\filter -> ~pvBinShiftLFO.(shift:[0.1, 1, 3], stretch:[0.1, 0.9, 1.1]);
q.gran1.proxy[1] = \filter -> ~pvMagSmearLFO.(threshold:[0.1, 12, 16]);
q.gran1.proxy[2] = \filter -> {arg in;

	var audio = in;
	var chain,chain2;
	var maxc;
	var audio2 = PlayBuf.ar(1, c.bufnum, loop:1);

	chain = FFT(LocalBuf(2048 ! 2), audio);
	chain2 = FFT(LocalBuf(2048 ! 2), audio2 );
	chain = PV_CopyPhase(chain2, chain );
	(in) + IFFT(chain);
};
q.gran1.proxy[3] = \filter -> ~threeChan.(lov:0.5, midv:0.9, hiv:1);

//q.gran1.proxy.play;
//q.gran1.proxy.stop(15);

/****************************************************/
/****************************************************/

b = { Buffer.alloc(s,2048,1) }.dup;
q.gran2 = ~granulator.init_new("gran2", a);
q.gran2.setTrig({
	Dust2.ar(5)
});
q.gran2.setDur({
	LFNoise1.ar(4).range(1, 2)
});
q.gran2.setStart( {
	LFNoise1.ar(2).range(0.6, 0.8);
} );
q.gran2.setRate ( {
	DC.ar(1)
	//LFNoise1.ar(2).range(0.5, 1.5)
} );
q.gran2.setEnvbuf({
	DC.ar(-1);
});
q.gran2.setPan({
	LFNoise1.ar(1).range(-1, 1);
});
q.gran2.proxy.set(\amp, 0.4);
q.gran2.proxy[1] = \filter -> ~freeze.();
q.gran2.proxy[2] = \filter -> ~reverb1.();
q.gran2.proxy[3] = \filter -> ~echo.(decay:2.5);
q.gran2.proxy[4] = \filter -> ~threeChan.(xover1:500, threshold: 0.1, slope: 0, lov:0.2, midv:0.8, hiv:0.5);

//q.gran2.proxy.play;
//q.gran2.proxy.stop;

/****************************************************/
/****************************************************/

q.gran3 = ~granulator.init_new("gran5", a);
q.gran3.setTrig({
	Impulse.ar(LFSaw.ar(2).range(1,10))
});
q.gran3.setDur({
	LFPulse.ar(1).range(0.2,2)
});
q.gran3.setStart( {
	LFSaw.ar(2).range(0.01, 0.02)
});
q.gran3.setRate ( {
	DC.ar(1)
} );
q.gran3.setEnvbuf({
	DC.ar(-1)
});
q.gran3.setPan({
	DC.ar(0);
});
q.gran3.proxy.set(\amp, 0.6);
q.gran3.proxy.fadeTime = 1;
q.gran3.proxy[1] = \filter -> ~echo.();
q.gran3.proxy[2] = \filter -> ~threeChan.(lov:1, midv:0.9, hiv:1);
//q.gran3.proxy.play;
//q.gran3.proxy.stop;

/****************************************************/
/****************************************************/

q.gran4 = ~granulator.init_new("gran4", a);
q.gran4.setTrig({
	Dust.ar(SinOsc.ar(1).range(0.2, 1));
});
q.gran4.setDur({
	LFNoise1.ar(1).range(0.3,3)
});
q.gran4.setStart( {
	LFNoise1.ar(2).range(0.0001, 0.05)
});
q.gran4.setRate ( {
	DC.ar(1)
	//LFNoise1.ar(1).range(0.7, 1);
} );

q.gran4.setEnvbuf({
	Select.ar( TRand.ar(0, d.size(), Impulse.ar(3)).round, d);
});

q.gran4.setPan({
	DC.ar(0);
});

//Env.xyc([[1, 1.0.rand, -4.rand2], { [0.1.rand, 1.0.rand, -4.rand2] } ! 16], \exp).plot

q.gran4.proxy.set(\amp, 0.5);
q.gran4.proxy.fadeTime = 1;
q.gran4.proxy[1] = \filter -> ~reverb1.();
q.gran4.proxy[2] = \filter -> ~threeChan.(lov:1, midv:0.9, hiv:1);
//q.gran4.proxy.play;
//q.gran4.proxy.stop

//s.prepareForRecord("/Users/dmorgan/supercollider/do/unbrained/unbrained4b.aiff");
//s.record();
//s.stopRecording();
(
s.record();
Tdef(\main, {

	q.gran3.proxy.play;
	45.wait;
	q.gran1.proxy.play;
	45.wait;
	q.gran1.proxy.stop(15);
	q.gran2.proxy.play;
	90.wait;
	q.gran3.proxy.stop(10);
	30.wait;
	q.gran2.proxy.stop(20);

}).play;
)


InstrBrowser.new.gui
