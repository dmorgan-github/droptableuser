/////////////////////////////////////////
// buffers
~bufs[\snd] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws11/SC_180630_185006.wav");
~bufs[\trumpet] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws11/2323__synapse__trumpetloop01.wav");


/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// warp1
~p[\warp1].clear;
(~p[\warp1] = {

	var numChannels = 1;
	var buf = \buf.kr(0);
	var pos = \pos.kr(0);
	var rate = \rate.kr(1);
	var windowSize = \ws.kr(0.2);
	var envbufnun = \envbufnum.kr(-1);
	var overlaps = \overlaps.kr(8);
	var windowRandRatio = \winrand.kr(0);

	var sig = Warp1.ar(
		numChannels,
		buf,
		pos,
		rate,
		windowSize,
		envbufnun,
		overlaps,
		windowRandRatio,
		interp:4
	);
	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0));
};
~p[\warp1].addSpec(\rate, [0.1, 4, \lin, 0, 1]);
~p[\warp1].addSpec(\ws, [0.001, 1, \lin, 0, 0.2]);
~p[\warp1].addSpec(\overlaps, [0.1, 12, \lin, 1, 8]);
~p[\warp1].addSpec(\winrand, [0.0, 1.0, \lin, 0, 0]);
~p[\warp1].addSpec(\spread, [0.0, 1.0, \lin, 0, 1]);
~p[\warp1].addSpec(\center, [0.0, 1.0, \lin, 0, 0]);
);

/////////////////////////////////////////
// pos
(~p[\warp_pos] = {

	var buf = ~bufs[\kitchen_sounds_1] ;
	var frames = ~bufs[\kitchen_sounds_1] .numFrames;
	var poslo = \lo.kr(0) / frames;
	var poshi = \hi.kr(frames) / frames;
	var pos = min(LFTri.kr(1/16).range(poslo, poshi), LFNoise2.kr(1/32).range(poslo, poshi));
	pos;
})

/////////////////////////////////////////
// set values
(~p[\warp1].set(
	\buf, ~bufs[\kitchen_sounds_1] ,
	\rate, -12.midiratio,
	\ws, 1,
	\overlaps, 5,
	\ws, 0.5,
	\winrand, 0.1,
	\pos, ~p[\warp_pos]
));
~p[\warp1].play(vol:0.5)
~p[\warp1].stop;
~p[\warp1].gui;

/////////////////////////////////////////
// reverb
~p[\rev2].clear;
(~p[\rev2] = {
	var in = \in.ar([0,0]);
	var fx = in;//BPeakEQ.ar(in, 2200, 1, -30 );
	//fx = BPeakEQ.ar(in, 2200, 1, -20 );
	fx = JPverb.ar(fx, 5, damp:\damp.kr(0), size:5, modDepth:0.5);
	fx;
})
~p[\rev2] <<> ~p[\warp1];
~p[\rev2].vol = 1;
~p[\rev2].play(vol:0.5);
~p[\rev2].stop

/////////////////////////////////////////
// fx2
~p[\fx2].clear;
(~p[\fx2][0] = {
	var in = \in.ar([0,0]);
	var fx = PitchShift.ar(in, 0.5, 0.5);
	fx = BPeakEQ.ar(in, 110, 0.7, 10 );
	fx = JPverb.ar(fx, 5, damp:\damp.kr(0), size:5, modDepth:0.8);
	fx;
});
~p[\fx2].play(vol:1);
~p[\fx2].stop;
~p[\fx2].gui;
~p[\fx2] <<> ~p[\warp1];

/////////////////////////////////////////
// fx3
~p[\fx3].clear;
(~p[\fx3][0] = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.5 + in}, [3/8, 5/8]);
	fx;
});
~p[\fx3].play;
~p[\fx3].stop;
~p[\fx3].gui;
~p[\fx3] <<> ~p[\warp1];


/////////////////////////////////////////
// fx4
~p[\fx4].clear;
(~p[\fx4][0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 5, 0, 5, modDepth:0.6);
	fx;
});
~p[\fx4].play;
~p[\fx4].stop;
~p[\fx4].gui;
~p[\fx4] <<> ~p[\fx3];

/////////////////////////////////////////
// fx5
~p[\fx5].clear;
(~p[\fx5][0] = {
	var in = \in.ar([0,0]);
	var fx = PitchShift.ar(in, 0.5, 0.5);
	fx = BLowPass4.ar(fx, SinOsc.kr(SinOsc.kr(1/16).range(1,5)).range(440, 1800), 0.8);
	fx;
});
~p[\fx5].play;
~p[\fx5].stop;
~p[\fx5].gui;
~p[\fx5] <<> ~p[\fx4];


App.recordWorkspace("ws11");
s.stopRecording

//////////////////////////////////////////////
// ui
(
Fdef(\warp1_lohi, {arg lo = 0, hi = 1;
	~p[\warp_pos].set(\lo, lo, \hi, hi);
});
)

(
var buf = ~bufs[\trumpet];
var view = View().layout_(HLayout().margins_(2).spacing_(2));
var sfv = SoundFileView()
.background_(Color.gray(0.3))
.timeCursorOn_(true)
.gridOn_(true)
.resize_(5)
.gridResolution_(0.0)
.mouseUpAction = ({arg view;
	var loFrames, hiFrames;
	loFrames = view.selection(0)[0];
	hiFrames = view.selection(0)[1] + loFrames;
	Fdef(\warp1_lohi).value(loFrames,hiFrames);
});
sfv.setSelectionColor(0, Color.blue(alpha:0.5));

buf.loadToFloatArray(action:{arg a;
	{
		sfv.setData(a, channels: buf.numChannels);
		sfv.setSelection (0, [0, buf.numFrames]);
		sfv.mouseUpAction.value(sfv);
	}.defer
});

view.layout.add(sfv);
view.alwaysOnTop_(true).front;
)

