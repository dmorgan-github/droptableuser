(
// plot the compressor curve with 3 different knee settings
{ var sig;
	sig = Line.ar(-60,0,0.1).dbamp;
	SoftKneeCompressor.ar(
		sig,				// input (also used as control)
		thresh: -20,  	// dB
		ratio: 0.125,  	// dB ratio above thresh
		knee: 10, 	// number of dB's around thresh
		makeUp: 0		   	// amount of make-up gain (dB ratio)
	).ampdb; 				// convert to dB's

}.plot2( 0.1, minval: -60, maxval: 0 ).superpose_(true);
)

(
// plot the reduction curve
{ var sig;
	sig = Line.ar(-60,0,0.1).dbamp;
	SoftKneeCompressor.ar(
		1, 	// use 1 as input signal to multiply
		sig,	// use the actual signal as control
		thresh: -20,
		ratio: 0.125,
		knee: [0,10,20],
		makeUp: 0
	).ampdb.neg;

}.plot2( 0.1, minval: 0, maxval: 60 ).superpose_(true);
)