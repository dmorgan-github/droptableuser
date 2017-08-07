(
func: {arg in;
	WaveLoss.ar(in,
		\drop.kr.range(\drop_min.kr(1), \drop_max.kr(50)),
		\outof.kr.range(\outof_min.kr(1), \outof_max.kr(100)),
		\mode.kr.range(\mode_min.kr(1), \mode_max.kr(2))
	);
},
specs: (
	drop: [1,50,\lin,1,20],
	outof: [1,100,\lin,1,40],
	mode: [1,2,\lin,1,1]
)
)