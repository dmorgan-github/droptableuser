/*
# 1194 Higher Quality Pitch Scaler
> k: Pitch co-efficient (0.5 to 2)
> a: Input
< a: Output
< k: latency
*/
(
func: {arg in;

	LADSPA.ar(1, 1194,
		\coef.kr.range(\coef_min.kr(0.5), \coef_max.kr(2))
	);
},
specs: (
	coef: [0.5, 2, \lin, 0, 1]
)
)