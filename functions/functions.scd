(
~synths = {

	SynthDescLib.global.synthDescs.do { |desc|
        if(desc.def.notNil) {
                "\nSynthDef %\n".postf(desc.name.asCompileString);
                desc.def.func.postcs;
        };
	};
};

~recordBuses = {arg buses, path;

	var recHeaderFormat = "aiff";
	var recSampleFormat = "int24";

	var bufs = buses.collect({arg b, i;

		Buffer.alloc(s, 65536, 1, {arg buf;

			var chanNum = "", chanPath;
			chanNum = "_" ++ i;
			chanPath = path ++ chanNum ++ "." ++ recHeaderFormat;
			chanPath.debug("Preparing:");
			buf.writeMsg(chanPath,
				recHeaderFormat, recSampleFormat, 0, 0, true);
		});
	});

	SynthDef(\diskout, {

		bufs.collect({arg buf, i;

			var bus = buses[i];
			DiskOut.ar(buf, In.ar(bus, 1));
		});

	}).play(target:s, addAction:\addToTail);

	bufs;
};

~sawAmps = {arg topPartial = 20;
	(1..topPartial).reciprocal;
};
~squareAmps = {arg topPartial = 20;
	[(1, 3 .. topPartial).reciprocal, 0].lace(topPartial);
};
~triangleAmps = {arg topPartial = 20;
	[(1, 3 .. topPartial).reciprocal.squared * #[1, -1], 0].lace(topPartial)
};
~sawSignal = {arg size, topPartial = 20;
	Signal.sineFill(size, ~sawAmps.(topPartial:topPartial));
};
~squareSignal = {arg size, topPartial = 20;
	Signal.sineFill(size, ~squareAmps.(topPartial:topPartial));
};
~triangleSignal = {arg size, topPartial = 20;
	Signal.sineFill(size, ~triangleAmps.(topPartial:topPartial));
};

~slcr = {arg tempo, beats = 8, dur = 1, amp = 0.1, buf;

	// set tempo if none provided
	var tmpo = tempo? TempoClock.default.tempo;

	// length in seconds of sample
	var len = buf.numFrames/buf.sampleRate;
	// beats per second
	var bps = beats/len;
	// rate adjusted to tempo
	var rate = tmpo/bps;

	// multiply into eigth note events
	var events = beats * 2;
	// frames per event
	var fpe = buf.numFrames/events;

	// return the pmono to be played
	// more complicated strategies for startPos and dur can be set up
	Pmono(\smplr_m,
		\startPos, Pfuncn({ rrand(0, events-1) * fpe; }, inf),
		\t_trig, 1,
		\buf, buf,
		\rate, rate,
		\amp, Pexprand(0.7, 1, inf) * amp,
		\loop, 1
	);
};

//b = Buffer.read(s, "/Users/david/Desktop/bbcut2 sounds/break")
//~slcr.(tempo:2, buf:b, amp: 0.2).play

)
