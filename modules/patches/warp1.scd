~buf = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws13/434189__greek555__ethnic-style.wav");
"/Users/david/projects/droptableuser/samples/1channel/171326__bradovic__piano-improvisation.mono.aiff"
"/Users/david/projects/droptableuser/workspaces/ws12/27130__pryght-one__harp.wav"

~p[\warp1].mold

(~p[\warp1] = {

	var numChannels = 1;
	var buf = ~buf;
	var phase = LFNoise2.kr(3).range(0.2, 0.25);
	var rate = \rate.kr(1);//SinOsc.kr(0.1).range(0.5, 2);
	var windowSize = \ws.kr(0.2);
	var envbufnun = \envbufnum.kr(-1);
	var overlaps = \overlaps.kr(8);
	var windowRandRatio = \winrand.kr(0);

	var env = Env.perc(releaseTime:0.1).kr(gate:Impulse.kr(1));

	var fx = Warp1.ar(
		numChannels,
		buf,
		phase,
		rate,
		windowSize,
		envbufnun,
		overlaps,
		windowRandRatio,
		interp:-4
	);
	env * fx!2
})

~p[\warp1].set(\rate, 1.midiratio, \ws, 1, \overlaps, 5, \winrand, 0.1)
~p[\warp1].play;


(~p[\rev2] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in);
	fx;
})

(~p[\d2] = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.3 + in }, 2.4);
	fx;
})

~p[\d2].vol = 1
~p[\d2] <<> ~p[\warp1];
~p[\d2].play
~p[\d2].stop;

~p[\rev2] <<> ~p[\d2];//~p[\d2];//~p[\warp1];
~p[\rev2].play
