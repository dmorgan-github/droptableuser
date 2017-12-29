(
func: {arg in;

	var stretch = \stretch.kr(1).range(\stretch_min.kr(0.01), \stretch_max.kr(8));
	var shift = \shift.kr(0).range(\shift_min.kr(0.01), \shift_max.kr(8));
	var chain = FFT( { LocalBuf(512) } ! 2, in);
	chain = PV_BinShift(chain, stretch, shift, interp: 1);
	chain = IFFT(chain);
	LeakDC.ar(chain);
},
specs: (
	stretch: [0.01, 8, \lin, 0, 1],
	shift: [0.01, 8, \lin, 0, 0]
)
)