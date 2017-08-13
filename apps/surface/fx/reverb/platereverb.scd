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
		[\revtimeL.kr.range(\revtimeL_min.kr(0.01), \revtimeL_max.kr(8.5)),
			\revtimeR.kr.range(\revtimeR_min.kr(0.01), \revtimeR_max.kr(8.5))
		],
		[\dampingL.kr.range(\dampingL_min.kr(0), \dampingL_max.kr(1)),
			\dampingR.kr.range(\dampingR_min.kr(0), \dampingR_max.kr(1))
		],
		1,
		in
	);
},
specs: (
	revtimeL: [0.01, 8.5, \lin, 0, 1],
	revtimeR: [0.01, 8.5, \lin, 0, 1],

	dampingL: [0, 1, \lin, 0, 0],
	dampingR: [0, 1, \lin, 0, 0]
)
)