(
~synths = {

	SynthDescLib.global.synthDescs.do { |desc|
        if(desc.def.notNil) {
                "\nSynthDef %\n".postf(desc.name.asCompileString);
                desc.def.func.postcs;
        };
	};
};

/*
~defaultOut = {
	s.options.numOutputBusChannels = 2;
	s.options.outDevice_("Built-in Output");
	s.options.inDevice_("Built-in Microph");
	s.reboot;
};

~soundflowerOut = {
	s.options.numOutputBusChannels = 16;
	s.options.inDevice_("Built-in Microph");
	s.options.outDevice_("Soundflower (64ch)");
	s.reboot;
};
*/

~record = {arg key, func, dur;
	s.prepareForRecord("".resolveRelative  ++ key ++ "_" ++ Date.getDate().asSortableString()  ++ ".aiff");
	s.record();
	func.value;
	if (dur.isNil.not) {

		{
			s.stopRecording();
		}.defer(dur);
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

Event.addEventType(\nbind, {arg server;

	var id = (currentEnvironment[\ndef] ? currentEnvironment[\instrument]).asSymbol;
	var type = \note;

	if (Ndef(id).isPlaying.not) {
		Ndef(id).play;
	};

	~type = type;
	~group = Ndef(id).group;
	~out = Ndef(id).bus;

    currentEnvironment.play;
});

)
