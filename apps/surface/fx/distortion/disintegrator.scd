(
	func: {arg in;
		Disintegrator.ar(in,
		probability: \prob.kr.range(\prob_min.kr(0), \prob_max.kr(1)),
		multiplier: \mult.kr.range(\mult_min.kr(-1), \mult_max.kr(1))
	)
	},
	specs: [
		prob: [0, 1, \lin, 0, 0.5],
		mult: [-1, 1, \lin, 0, 0]
	]
)