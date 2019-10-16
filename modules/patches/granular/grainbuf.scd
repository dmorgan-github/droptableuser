/////////////////////////////////////////
// proxy space
~p = ~p ?? {ProxySpace.new(s, \p)};
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);


// sample from here:"https://www.youtube.com/watch?v=8JWpnonT8Fg"
~bufs[\guitar] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws11/guitar-mono.wav");
~bufs[\guitar].play
~bufs[\guitar].duration

/////////////////////////////////////////
// granulator
~p[\grn].clear;
~p[\grn].mold;
(~p[\grn][0] = {

	//middle C is the original playback rate
	//\rate, (nn-60).midiratio
	var trig = Impulse.kr(LFNoise2.kr(6.0833333333333.reciprocal).range(1,5));
	var buf_in = ~bufs[\guitar];
	var pos = min(SinOsc.kr(6.0833333333333.reciprocal * 0.5).range(0,1), LFNoise2.kr(6.0833333333333.reciprocal).range(0,1));
	var graindur = max(
		SinOsc.kr(6.0833333333333.reciprocal, SinOsc.kr(12)).range(0.3,0.5),
		LFNoise2.kr(6.0833333333333.reciprocal).range(0.3,0.5)
	);
	var rate = [1,2];
	var envbuf = ~bufs[\hamming];//~bufs[\welch];//\envbuf.kr(-1).lag(0.01);
	var pan = LFNoise2.kr(0).range(SinOsc.kr(0.05).range(-1,-0.1), SinOsc.kr(0.1).range(0.1,1));
	var grainamp = 0.2;
	var loop = 1;

	var amp = Demand.kr(trig, 0, Dwhite(grainamp.clip(0,1), 1, inf));
	var panValue = pan;
	var reverse = 0.4;
	var rev = Demand.kr(trig, 0, Dwrand([-1,1], [reverse,1-reverse], inf));

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
});
~p[\grn].play;
~p[\grn].stop;
~p[\grn].gui;


/////////////////////////////////////////
// fx1
~p[\fx1].clear;
(~p[\fx1][0] = {
	var in = \in.ar([0,0]);
	var fbNode = FbNode(2, 5, 5);
	var fb = fbNode.delay(0.3);
	var sig = fb * 0.3 + in;
	//sig = PitchShift.ar(sig, 0.5, 2);
	sig = Squiz.ar(sig, 2.1);
	//sig = BLowPass4.ar(sig, 820);
	fbNode.write(sig);
	sig;
});
~p[\fx1].play(vol:0.2);
~p[\fx1].stop;
~p[\fx1].gui;

~p[\fx1] <<> ~p[\grn];


/////////////////////////////////////////
// fx3
~p[\fx3].clear;
(~p[\fx3][0] = {
	var in = \in.ar([0,0]) * SinOsc.ar(220);
	var fx = JPverb.ar(in, 3, 0, 3);
	fx;
});
~p[\fx3].play(vol:0.05);
~p[\fx3].stop;
~p[\fx3].gui;

~p[\fx3] <<> ~p[\grn];

/////////////////////////////////////////
// fx4
~p[\tap4] <<> ~p[\grn];
~p[\tap4].play
~p[\tap4].stop;
~p[\tap4].set(\tap1_delay, 3/8, \tap1_delay, 5/8, \tap1_delay, 2/8, \tap1_delay, 4/8);


/////////////////////////////////////////
// fx2
~p[\fx2].clear;
(~p[\fx2][0] = {
	var in = \in.ar([0,0]);// + ~p[\tap4].ar;
	var fx = JPverb.ar(in, 2, 0, SinOsc.kr(1/32).range(1,2), modDepth:0.5);
	fx;
});
~p[\fx2].play;
~p[\fx2].stop;
~p[\fx2].gui;

~p[\fx2] <<> ~p[\grn];

App.recordWorkspace("ws11");
s.stopRecording


m = ProxyMixer(~p);
ProxyMeter.addMixer(m);

/////////////////////////////////////////
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

