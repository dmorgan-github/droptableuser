

~d1 = ProxySpace.new(s);
~d1[\s1] = ~drone1.();
~d1[\s1].play;


~scratch = ProxySpace.new(s);
~scratch_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/vox/oh-yeah-man-they-definitely-feel-it.wav");

(
~scratch[\phase] = {

	var globalFreq = 0.7, localOscSize = 0.01, foldRange = 0.28,
    localFreq = 0.87, preAmp = 1.4, smoothAmount = 0.36;

	var sig = LFDNoise3.ar(globalFreq).range(0.2, 0.7) +
	SmoothFoldS.ar(
		// adding space by decorrelating the local scratching / oscillation
		LFTri.ar(localFreq * ({ LFDNoise3.ar(0.2).range(0.999, 1.001) } ! 2)) * preAmp,
		foldRange: foldRange,
		smoothAmount: smoothAmount
	) * localOscSize;

	sig * BufFrames.ir(~scratch_buf);
}
)

~scratch[\phase].numChannels;
(
~scratch[\bfrd] = {

	var buf_in = \buf.kr(0);
	var phase = \phase.ar([0,0]);
	BufRd.ar(1, buf_in, phase, interpolation:4);
};
)
~scratch[\bfrd].set(\buf, ~scratch_buf, \phase, ~scratch[\phase]);
~scratch[\bfrd].play


App.record
s.stopRecording;
