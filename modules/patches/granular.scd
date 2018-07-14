s.options.inDevice_("Built-in Microph");
s.options.inDevice_("Soundflower (64ch)");
s.options.outDevice_("Soundflower (64ch)");
s.options.numOutputBusChannels = 16;
s.reboot;


/////////////////////////////////
// set up the buffer to granularize
~bufs.alloc(\m1, 16, 2); //Buffer.alloc(s, s.sampleRate * 16, 2);
~bufs.alloc(\m1, 16, 1);
~bufs.alloc(\m2, 16, 1);
~bufs.read(\m1, "~/projects/droptableuser/workspaces/ws8/smpl2.aif");
~bufs[\m1].zero;
~bufs[\m1].play;

Ndef(\rec_buf_m) <<> Ndef(\soundin_m);
Ndef(\rec_buf_m).set(\buf, ~bufs[\m1], \rlvl, 1, \plvl, 1, \loop, 1);

//rlvl = EnvGen.kr(Env.asr(0.05, 1.0, 0.05), PulseCount.kr(t_trig, t_reset) % 2);

///////////////////////////////////
// rec buf UI
(
Fdef(\button_on, {
	Ndef(\rec_buf_m).set(\trig, 1)
});
Fdef(\button_off, {
	Ndef(\rec_buf_m).set(\trig, 0)
})
)
~rec_buf_ui.();


/////////////////////////////////
// patch
~gran = ProxySpace.new(s);
~gran.quant = 1.0;
~gran.clock = TempoClock.default;

/////////////////////////////////
// synth
(~gran[\snd][0] = {

	//middle C is the original playback rate
	//\rate, (nn-60).midiratio
	var trig = \trig.tr;
	var buf_in = \buf.kr(0);
	var pos = \pos.kr([0.1,0.1]);
	var graindur = \graindur.kr([0.5, 0.5]);
	var rate = \rate.kr(1);
	var envbuf = \envbuf.kr(-1).lag(0.01);
	var pan = \pan.kr(0);
	var grainamp = \grainamp.kr(1);
	var loop = \loop.kr(0);

	var amp = Dwhite(grainamp.clip(0,1), 1, inf);
	var panValue = Dwhite(pan.neg, pan, inf);
	var reverse = \reverse.kr(0);
	var rev = Dwrand([-1,1], [reverse,1-reverse], inf);

	var sig = GrainBufJ.ar(2,
		trig,
		dur: graindur,
		sndbuf: buf_in,
		rate: rate * rev,
		pos: pos,
		loop: loop,
		interp: 4,
		grainAmp: amp,
		pan: panValue,
		envbufnum: envbuf
	);

	sig;
})

/////////////////////////////////
// modulators
~gran[\grain_env] = {Library.at(\buf, \welch)};

// grain dur
~gran[\grain_dur].mold
(~gran[\grain_dur] = {
	[
		LFTri.kr(0.1).range(0.1, 2),
		SinOsc.kr(0.5).range(0.5, 1)
	];
});

// grain pos
~gran[\lfo1] = {SinOsc.kr(1/16).range(0.1,1)};
(~gran[\grain_pos] = {
	[
		SinOsc.kr(\freq.kr(0.1)).range(0.1, 0.5),
		SinOsc.kr(1/16).range(0.5, 1),
	];
});
~gran[\grain_pos].set(\freq, ~gran[\lfo1])

// grain rate
~gran[\grain_rate] = {Demand.kr(Dust.kr(1), 0, Drand(Scale.kumoi.ratios, inf) );};

// trig
~gran[\grain_trig] = {Impulse.kr( LFNoise2.kr(1/16).range(1,10) )};


/////////////////////////////////
// settings
(~gran[\snd].set(
	\buf, ~bufs[\m1],
	\trig, ~gran[\grain_trig],
	\envbuf, ~gran[\grain_env],
	\graindur, ~gran[\grain_dur],
	\rate, 1,
	\reverse, 0.4
)
)

/////////////////////////////////
// play
~gran[\snd].play(out:0,fadeTime:0);
~gran[\snd].stop(fadeTime:30);
~gran[\snd].vol = 1;



(~gran[\delay] = {

	var in = \in.ar([0,0]);
	var fbNode = FbNode(2, 1);
	var d1 = fbNode.delay(3/8);
	var d2 = fbNode.delay(4/8);

	var sig = in + (d1 * 0.4) + (d2 * 0.4);

	fbNode.write(sig);

	sig;
})

~gran[\delay] <<> ~gran[\snd];
~gran[\delay].play(out:0);


(~gran[\rec] = {

	var in = \in.ar([0,0]);
	var buf = ~bufs[\m2];
	RecordBuf.ar(in.sum,
		buf,
		recLevel:\rlvl.kr(1),
		preLevel:\plvl.kr(0),
		loop:\loop.kr(1),
		trigger:\trig.kr(1),
		doneAction:Done.none
	);
})

~gran[\rec] <<> ~gran[\delay];

(
~gran[\snd2][0] = {

	//middle C is the original playback rate
	//\rate, (nn-60).midiratio
	var trig = \trig.tr;
	var buf_in = \buf.kr(0);
	var pos = \pos.kr([0.1,0.1]);
	var graindur = \graindur.kr([0.5, 0.5]);
	var rate = \rate.kr(1);
	var envbuf = \envbuf.kr(-1).lag(0.01);
	var pan = \pan.kr(0);
	var grainamp = \grainamp.kr(1);
	var loop = \loop.kr(0);

	var amp = Dwhite(grainamp.clip(0,1), 1, inf);
	var panValue = Dwhite(pan.neg, pan, inf);
	var reverse = \reverse.kr(0);
	var rev = Dwrand([-1,1], [reverse,1-reverse], inf);

	var sig = GrainBufJ.ar(2,
		trig,
		dur: graindur,
		sndbuf: buf_in,
		rate: rate * rev,
		pos: pos,
		loop: loop,
		interp: 4,
		grainAmp: amp,
		pan: panValue,
		envbufnum: envbuf
	);

	sig;
}
)

(~gran[\snd2].set(
	\buf, ~bufs[\m2],
	\trig, ~gran[\grain_trig],
	\envbuf, ~gran[\grain_env],
	\graindur, ~gran[\grain_dur],
	\rate, 2,
	\reverse, 0.3
)
)

~gran[\snd2].play(out:0);
~gran[\snd2].vol = 1;

/////////////////////////////////
// ui
(
var ezknob = {arg key, label, action={}, val=0;
	VLayout(
		Knob()
		.action_(action)
		.centered_(true)
		.value_(val),
		StaticText().string_(label)
		.font_(Font("Courier New", 10))
		.align_(\center)
	)
	.margins_(0)
	.spacing_(0)
};
var view = View().layout_(HLayout().margins_(2).spacing_(2)).palette_(QPalette.dark);
view.layout.add(ezknob.(\grain_dur, "dur", {arg ctrl; ctrl.value.postln;}));
view.layout.add(ezknob.(\grain_rate, "rate"));
view.front;
)

App.recordWorkspace("ws8");
s.stopRecording
