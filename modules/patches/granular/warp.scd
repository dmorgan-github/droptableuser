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