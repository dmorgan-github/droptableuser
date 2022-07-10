// https://scsynth.org/t/generate-new-buffers-from-onset-detection-on-a-buffer/6111/6?u=droptableuser

s.reboot;
(
Pdef.removeAll;
s.newBufferAllocators;

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

SynthDef(\onsets, {arg buf, threshold = 0.5;
	var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf));
	var chain = FFT(LocalBuf(512), sig);
	SendTrig.kr(Onsets.kr(chain, threshold));
}).add;

SynthDef(\playbuf, {arg buf, sPos, dur, playBackRate = 1, out = 0;
	// sPos & dur values are in seconds.
	var sig = PlayBuf.ar(1, buf, playBackRate, 1, sPos * SampleRate.ir);
	// sPos converted from time in seconds to number of Frames
	var env = Env.perc(0.001, dur, 8).kr(2);
	Out.ar(out, sig!2)
}).add;

o = OSCFunc({ arg msg, time;
	~onsets.add(Main.elapsedTime - ~initTime);
    ~onsets.last.postln;
},'/tr', s.addr);
)

(
// Analyse onsets and add times (in seconds) to ~onsets;
~onsets = List.new;
~initTime = Main.elapsedTime; // time = 0
x = Synth(\onsets, [\buf, b, \threshold, 0.8]);
)

// wait for the post window to stop outputting onset values, this will last the duration of the sample (there are tools to this offline, eg. in the Flucoma toolkit, don't think that any are built in to SC, not sure...

(
// now =calculate the duration of each segment. The length of a segment 'i' is (~onsets[i + 1] - ~onsets[i]), except for the last segments which is (duration of whole sample - ~onsets.last). Duration of the whole sample in seconds = b.numFrames/s.sampleRate.
~durs = (~onsets[1..] ++ [b.numFrames/s.sampleRate]) - ~onsets;
)

(
Pdef.removeAll;
// reconstruct the original sample from the segments
Pdef(\test,
	Pbind(
		\instrument, \playbuf,
		\sPos, Pseq(~onsets, inf).trace,
		\dur, Pseq(~durs, inf).trace,
		\buf, b
	)
).play
)

(
// randomize the order and pitch of segments
Pdef(\test,
	Pbind(
		\instrument, \playbuf,
		\playBackRate, Pwhite(0.5, 2.0),
		\segment, Pwhite(0, ~onsets.size-1).trace, // produces an index
		\sPos, Pfunc{|ev|~onsets[ev.segment]}, // use the index from \segment to index in to the ~onsets list
		\dur, Pfunc{|ev|~durs[ev.segment]/ev.playBackRate},
		// use the index from \segment to index in to the ~durs list, scale by playBackRate
		\buf, b
	)
).play
)

(
// stop and clean up;
Pdef(\test).stop;
Pdef.removeAll;
o.free; // free the OSCFunc
x.free; // free the onset-detection synth
)

(
// random single shot sample at random rate
var i = rand(~onsets.size);
var rate = rrand(0.5, 2); // rate between halfspeed and doublespeed will produce pithes in the range [octave down - octave up]
Synth(\playbuf, [\buf, b, \sPos, ~onsets[i], \dur, ~durs[i]/rate, \playBackRate, rate]);
)