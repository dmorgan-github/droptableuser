/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// \pluck2
~p[\pluck2].clear;
~p[\pluck2].mold;
(~p[\pluck2][0] = {

	var freq = \freq.kr(432);
	var trig = \trig.tr;

	var osc1 = {
		var sig = { Pluck.ar(WhiteNoise.ar,
			Impulse.kr(1),
			freq.reciprocal * 2,
			freq.reciprocal * 2,
			11,
			SinOsc.kr(1/32).range(0.07, 0.1);
		) }.dup(4).sum;
		sig * 0.2;
	};

	var sig = [
		osc1.()
	].sum;

	Pan2.ar(sig, \pan.kr(0));
});
~p[\pluck2].play(vol:0.08);
~p[\pluck2].stop(fadeTime:5);
~p[\pluck2].gui;

/////////////////////////////////////////
// pattern
(~p[\pluck2][2] = \set -> Pbind(
    \trig, 1,
	\midinote, 77
));

/////////////////////////////////////////
// pitchshift
~p[\pitchshift].clear;
(~p[\pitchshift][0] = {
	var in = \in.ar([0,0]);
	var fx = PitchShift.ar(in, 0.1, 2, 0, 0.5);
	fx = JPverb.ar(fx, 10, 0, 2);
	fx = SVF.ar(fx, [1475, 880], SinOsc.kr(1/32).range(0.2, 0.8) );
	fx = LPF.ar(fx, SinOsc.kr(1/16).range(220, 2300));
	fx = (fx * 2).tanh;
	fx = fx * Env.circle([0,1,0], [4,4,4], -4).kr(gate:1);
	fx;
};
//~p[\pitchshift].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\pitchshift] <<> ~p[\pluck2];
~p[\pitchshift].play(vol:0.3);
~p[\pitchshift].stop;
~pitchshift_win = App.guiHelper(~p[\pitchshift], "pitchshift");
~pitchshift_win.front;

/////////////////////////////////////////
// warp
~p[\warp].clear;
(~p[\warp][0] = {

	var in = \in.ar([0,0]);
	var buffer = \buf.kr(0);
	var warpFactor = \warpFactor.kr(1);
	var freqScale = \freqScale.kr(1);
	var windowSize = \windowSize.kr(0.2);
	var envbufnum = \envbufnum.kr(-1);
	var overlaps = \overlaps.kr(10);
	var windowRandRatio = \windowRandRatio.kr(0.1);
	var preLevel = \preLevel.kr(0);

	var numChannels = in.asArray.size;
	var pointer = LFSaw.kr(warpFactor * BufDur.kr(buffer).reciprocal, 1, 0.5, 0.5 );
	var record = RecordBuf.ar(in, buffer, preLevel: preLevel, loop: 0);

	var fx = Warp1.ar(numChannels,
		buffer,
		pointer,
		freqScale,
		windowSize,
		envbufnum,
		overlaps,
		windowRandRatio,
		4
	);

	fx;
};
~p[\warp].addSpec(\warpFactor, [0.1, 250, \lin, 0.0, 1]);
~p[\warp].addSpec(\freqScale, [0.1, 4, \lin, 0.0, 1]);
~p[\warp].addSpec(\windowSize, [0.1, 4, \lin, 0.0, 0.2]);
~p[\warp].addSpec(\overlaps, [0, 250, \lin, 0.0, 10]);
~p[\warp].addSpec(\windowRandRatio, [0, 1, \lin, 0.0, 0.1]);
~p[\warp].addSpec(\preLevel, [0, 1, \lin, 0.0, 0]);
);

// ten second buffer
~bufs[\warp] = Buffer.alloc(s, 44100 * 10, 2);

~p[\warp] <<> ~p[\pluck2];
~p[\warp].set(\buf, ~bufs[\warp], \warpFactor, 0.1, \overlaps, 50, \freqScale, -9.midiratio, \windowSize, 1, \windowRandRatio, 0.1);
~p[\warp].play(vol:0.1);
~p[\warp].stop;
~warp_win = App.guiHelper(~p[\warp], "warp");
~warp_win.front;

/////////////////////////////////////////
// n1_fx
~p[\pluck2_fx].clear;
(~p[\pluck2_fx][0] = {
	var in = \in.ar([0,0]);
	var fx = in;
	fx = DelayC.ar(
		FreqShift.ar(fx, LFNoise2.kr(0.5).range(-100, 200)), 2, [1,2,3,4,5,6,7,8].normalizeSum * SinOsc.kr(1/16).range(5,10));
	fx = fx + FbC({arg fb; fb * 0.2 + fx}, 0.26);
	Splay.ar(fx) * Env.circle([0,0.6,0], [4,5,5], -4).kr(gate:1);
};
//~p[\pluck2_fx].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\pluck2_fx] <<> ~p[\pluck2];
~p[\pluck2_fx].play(vol:0.3);
~p[\pluck2_fx].stop;
~n1_fx_win = App.guiHelper(~p[\pluck2_fx], "pluck2_fx");
~n1_fx_win.front;


App.saveWorkspace("ws3", rec:true);
s.stopRecording




/////////////////////////////////////////
// mix1
~p[\mix1].clear;
~p[\mix1][0] = \mix -> {~p[\pluck2]};
~p[\mix1][1] = \mix -> {~p[\pitchshift]};
~p[\mix1][2] = \mix -> {~p[\warp]};
~p[\mix1][3] = \mix -> {~p[\pluck2_fx]};
~p[\mix1].play;
~p[\mix1].stop;
~p[\mix1].set(\mix0, 1);
~mix1_win = App.guiHelper(~p[\mix1], "mix1");
~mix1_win.front;

App.saveWorkspace("ws3");