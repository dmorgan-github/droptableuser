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

~limiter = {arg level = 1, dur = 0.01;
	{arg in;
		Limiter.ar(LeakDC.ar(in), level, dur);
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
	Impulse.ar(5)
});
i.setDur({
	//DC.ar(1)
	LFNoise1.ar(0.1).range(0.1, 1);
});
i.setStart( {
	LFNoise1.ar(2).range(0.6, 0.8)
} );
i.setRate ( {
	DC.ar(1)
} );
i.setEnvbuf({
	DC.ar(-1)
});
i.setPan({
	LFNoise1.ar(0.1).range(-1, 1);
});
j = i.asProxy();
j.fadeTime = 1;
j.set(\amp, 0.6);
j[1] = \filter -> {arg in;
	CompanderD.ar(in, 1, 1, 1, 0.5, 0.5);
};
j[2] = \filter -> ~limiter.(1);
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
	LFNoise1.ar(0.1).range(-0.5, 0.5);
});
n = m.asProxy();
n.set(\amp, 0.2);
n[1] = \filter -> {arg in;
	var chain = FFT(b, in);
	chain = PV_MagFreeze(chain, SinOsc.ar(2) );
	in + IFFT(chain);
};
n[2] = \filter -> ~limiter.(1);
//n.play;
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
t[2] = \filter -> {arg in;
	BPeakEQ.ar(
		    in,
		    7822,
		    0.8,
		    4);
};
t[3] = \filter -> ~limiter.(1);
t.set(\amp, 0.8);
//t.play;
)


//s.prepareForRecord("/Users/dmorgan/supercollider/do/unbrained/unbrained2.aiff");
//s.record();
//s.stopRecording();

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
	20.wait;
	Tdef(\a).stop;

	j.fadeTime = 2;
	j.play;
	i.setDur({ LFPulse.ar(0.01).range(0.5, 1); });
	i.setRate ( { LFNoise1.ar(2).range(0.5, 1); } );
	i.setPan ( { DC.ar(0) } );
	5.wait;
	j.stop(7);

}).play;
