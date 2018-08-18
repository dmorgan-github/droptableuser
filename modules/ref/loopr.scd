





// allocate buffer. Your loops should be shorter
b = Buffer.alloc(s, s.sampleRate * 16, 2);
b.write("/Users/david/projects/droptableuser/workspaces/ws8/smpl1.aif");

(
Ndef(\loopr, {

	var t_trig=\t_trig.kr(0), t_reset=\t_reset.kr(1), t_switch=\t_switch.kr, plvl=\plvl.kr(1), ticknum=\ticknum.kr(4);
	var frombeat=\frombeat.kr(0), grainsize=\grainsize.kr(0), buf=\buf.kr(0);

	var in, gate, time, ticklength, firsttrig, ticks, beats, grainstarts, grainlengths,
		grainend, startfrombeat, bufswitch, rlvl, playenv, player, grainer, sig;

	var beatnum = 4;

	in = \in.ar([0,0]);

	gate = PulseCount.kr(t_trig, t_reset) > 1;
	time = Latch.kr(Timer.kr(t_trig), gate);
	ticklength = time / (beatnum * ticknum);
	// initial trigger to set play- and recbuf to index 0
	firsttrig = Trig.kr(SetResetFF.kr(t_trig, t_reset), 0.05);

	ticks = TDuty.kr(ticklength, gate, 1) * gate;

	// triggers at each loop cycle beginning + extra trigger at start of first recording
	beats = Trig.kr(PulseCount.kr(ticks, t_reset) % (beatnum * ticknum), 0.1) + firsttrig;
	//Poll.kr(ticks, ticks);

	// values for the loopbuf and switching between it and the playbuf
	grainstarts = Array.series(beatnum, 0, (SampleRate.ir * ticklength * ticknum).round(1));
	grainlengths = [0.25, 0.5, 1, 2, 3, 4];
	startfrombeat = Select.kr(frombeat, grainstarts);
	grainend = startfrombeat + (ticklength * SampleRate.ir / Select.kr(grainsize, grainlengths)).round(1);
	bufswitch = (((PulseCount.kr(t_switch, t_reset) % 2) * 2 ) -1);

	// reclevel gate is read from controlbus index 3
	rlvl = EnvGen.kr(Env.asr(0.05, 1.0, 0.05), PulseCount.kr(t_trig, t_reset) % 2);
	playenv = EnvGen.kr(Env.asr(0.05, 1.0, 0.05), gate);

	player = PlayBuf.ar(2, buf, BufRateScale.kr(buf), beats, loop:1);
	grainer = LoopBuf.ar(2, buf, BufRateScale.kr(buf), bufswitch,
			startfrombeat, startfrombeat, grainend, 2);

	RecordBuf.ar(in <! in, buf, recLevel: rlvl, preLevel:plvl, loop:1, trigger:beats);

	LinXFade2.ar(player, grainer, Lag.kr(bufswitch, 0.1), playenv);
})
)

Ndef(\loopr).set(\buf, b);
Ndef(\loopr) <<> Ndef(\soundin);
Ndef(\loopr).play(out:2);
Ndef(\loopr).stop


// start recording first loop
Ndef(\loopr).set(\t_trig, 1);
// stop recording, start looping
Ndef(\loopr).set(\t_trig, 1);

// switch to LoopBuf
Ndef(\loopr).set(\t_switch, 1)
// beat 1-4, as 0-3
Ndef(\loopr).set(\frombeat, 0)
// size of the looped grain 0 - 5
Ndef(\loopr).set(\grainsize, 0)

// switch back to PlayBuf
Ndef(\loopr).set(\t_switch, 1)

// overdub
Ndef(\loopr).set(\t_trig, 1);

// reset and start again
Ndef(\loopr).set(\t_reset, 1);
b.zero;

(
Ndef(\fx1, {

	var in = \in.ar([0,0]);
	var sig;
	var trig;
	var fbNode1 = FbNode(2, 2, 4);
	var fbNode2 = FbNode(2, 2, 4);
	var fbNode3 = FbNode(2, 4.5, 4);
	var fbNode4 = FbNode(2, 2, 4);

	var tap1 = fbNode1.delay(0.25);
	var tap2 = fbNode2.delay(0.5);
	var tap3 = fbNode3.delay;
	var tap4 = (fbNode4.delay(1) * 2).distort;

	fbNode1.write(in + (tap1 * 0.7) + (tap2 * 0.3));
	fbNode2.write(in + (tap2 * 0));
	fbNode3.write(in + (tap3 * 0.6) );
	fbNode4.write(in + (tap4 * 0.3) + (tap1 * 0.4));

	sig = [tap1.sum + tap2.sum, tap3.sum + tap4.sum];

	XFade2.ar(in, sig, \wet.kr(0).linlin(0,1,-1,1));
});
)


Ndef(\fx1) <<> Ndef(\loopr);
Ndef(\fx1).set(\wet, 0.1)
Ndef(\fx1).play
Ndef(\fx1).stop


(
Ndef(\fx2, {

	var in = \in.ar([0,0]);
	var sig = JPverb.ar(in);

	XFade2.ar(in, sig, \wet.kr(0).linlin(0,1,-1,1));
});
)

Ndef(\fx2) <<> Ndef(\fx1);
Ndef(\fx2).set(\wet, 0.5)
Ndef(\fx2).play
Ndef(\fx2).stop


//finally, clean up
l.free; b.free;

Fdef(\rec_on, {
	"hello".postln;
})
Fdef(\rec_on).value
RecordBuf.ar(in <! in, buf, recLevel: rlvl, preLevel:plvl, loop:1, trigger:beats);


///////////////////////////////////
// UI
(
var view = View().layout_(VLayout().margins_(5));
view.layout.add(Button()
	.states_([
		["rec", Color.black, Color.red],
		["stop", Color.white, Color.black]
	])
	.action_({arg ctrl;
		if (ctrl.value == 1) {
			Fdef(\rec_on).value;
		} {
			Fdef(\rec_off).value;
		};
		ctrl.value.postln;
	})
);
view.front;
)
