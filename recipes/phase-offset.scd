//https://scsynth.org/t/phase-offsets-and-ranges-of-several-basic-oscillators/6295
(
{[
	// phase value between
	//			[0..4]
	// offset to lowest point
	// 			0.5 * 4 = 2
	LFPar.ar(10, iphase:  0.5  * 4  ).range(0, 1),

	// phase value between
	//			[0..2]
	// offset to lowest point
	// 			0.75 * 2 = 1.5
	LFCub.ar(10, iphase:  0.75 * 2  ).range(0, 1),

	// phase value between
	//			[0..2]
	// offset to lowest point
	// 			0.5 * 2 = 1
	LFSaw.ar(10, iphase:  0.5  * 2  ).range(0, 1),

	// phase value between
	//			[0..2pi]
	// offset with lowest point
	// 			0.75 * 2pi = 1.5pi
	SinOsc.ar(10, phase:  0.75 * 2pi).range(0, 1),

	// phase value between
	//			[0..1]
	// offset to lowest point
	// 			0 * 1 = 0
	VarSaw.ar(10, iphase: 0    * 1  ).range(0, 1),

	// phase value between
	//			[0..4]
	// offset to lowest point
	// 			0.75 * 4 = 3
	LFTri.ar(10, iphase:  0.75 * 4).range(0, 1),

	// phase value between
	//			[0..1]
	// offset to lowest point
	// 			0.5 * 1 = 0
	LFPulse.ar(10, iphase: 0.5   * 1).range(0, 1),
]}.plot(0.1)
)