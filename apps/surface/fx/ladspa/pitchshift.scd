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
		\coef.kr(1)
	);
},
specs: (
	coef: [0.5, 2, \lin, 0, 1]
)
)