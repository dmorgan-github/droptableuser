(~bin_delay = {

	var in = \in.ar([0,0]);
	var size = 128;
	var maxdel = 0.5;
	var buf = LocalBuf(size * 2, 1).clear;
	var pulse = Impulse.ar(0.33);
	var chain = FFT(buf, in, 0.25);
	chain = PV_BinDelay(chain, maxdel, \dels.kr, \fb.kr, 0.25);

	Pan2.ar(IFFT(chain), \pan.kr(0));
})
