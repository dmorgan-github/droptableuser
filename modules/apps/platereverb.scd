/*
# 1423 Plate reverb
> k: Reverb time (0.01 to 8.5)
> k: Damping (0 to 1)
> k: Dry/wet mix (0 to 1)
> a: Input
< a: Left output
< a: Right output
*/

(
func: {arg in;

	LADSPA.ar(1, 1423,
		\revtime.kr.range(\revtime_min.kr(0.01), \revtime_max.kr(8.5)),
		\damping.kr.range(\damping_min.kr(0), \damping_max.kr(1)),
		1,
		in
	);
},
specs: (
	revtime: [0.01, 8.5, \lin, 0, 1],
	damping: [0, 1, \lin, 0, 0],
)
)