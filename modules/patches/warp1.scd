~p = ~p ? ProxySpace.new(s, \p);
//~p.envir

~buf = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws13/434189__greek555__ethnic-style.wav");

//////////////////////////////////////////////
// synth
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
});

//////////////////////////////////////////////
// pos
(~p[\warp_pos] = {
	var buf = ~buf;
	var frames = ~buf.numFrames;
	var poslo = \lo.kr(0) / frames;
	var poshi = \hi.kr(frames) / frames;
	LFNoise2.kr(0.1).range(poslo, poshi);
})

//////////////////////////////////////////////
// set values
(~p[\warp1].set(
	\buf, ~buf,
	\rate, 1.midiratio,
	\ws, 1,
	\overlaps, 5,
	\winrand, 0.1,
	\pos, ~p[\warp_pos]
));
~p[\warp1].play;
~p[\warp1].stop;

//////////////////////////////////////////////
// reverb
(~p[\rev2] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, \t60.kr(1), damp:\damp.kr(0), size:\size.kr(1));
	fx;
})
~p[\rev2] <<> ~p[\warp1];
~p[\rev2].vol = 0.05;
~p[\rev2].play(fadeTime:8);
~p[\rev2].stop(fadeTime:8);

//////////////////////////////////////////////
// ui
(
Fdef(\warp1_lohi, {arg lo = 0, hi = 1;
	~p[\warp_pos].set(\lo, lo, \hi, hi);
});
)
(
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

~buf.loadToFloatArray(action:{arg a;
	{
		sfv.setData(a, channels: ~buf.numChannels);
		sfv.setSelection (0, [0, ~buf.numFrames]);
		sfv.mouseUpAction.value(sfv);
	}.defer
});

view.layout.add(sfv);
view.alwaysOnTop_(true).front;
)


App.recordWorkspace("ws13");
s.stopRecording