(
var freq_func = {arg evt;

	var freq, note, midinote;
	var scale = evt[\scale] ? Scale.major;
	var stepsPerOctave = evt[\stepsPerOctave] ? 12.0;
	var degree = evt[\degree] ? 0.0;
	var mtranspose = evt[\mtranspose] ? 0.0;
	var gtranspose = evt[\gtranspose] ? 0.0;
	var root = evt[\root] ? 0.0;
	var ctranspose = evt[\ctranspose] ? 0.0;
	var harmonic = evt[\harmonic] ? 1.0;
	var octave = evt[\octave] ? 5.0;

	note = (degree + mtranspose).degreeToKey(scale, stepsPerOctave);
	midinote = ((note + gtranspose + root) / stepsPerOctave + octave) * 12.0;
	freq =  (midinote + ctranspose).midicps * harmonic;
	freq;
};

Fdef(\freq_func, freq_func);
Pfunc(Fdef(\freq_func, freq_func));
)
