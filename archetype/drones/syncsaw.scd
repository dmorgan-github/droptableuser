(
Ndef(\fun, {
	var src, freq = 25;
	var lagTime = \lagTime.kr(0);
	var vibrato = \vibrato.kr([ 1.3515662384033, 1.3061940193176, 0.604791264534, 1.2328997278214, 0.33569867610931, 0.40528120040894, 1.0865307760239, 1.22394572258, 1.7781081724167, 0.15319232463837 ], lagTime);

	var vibRatio = \vibRatio.kr([ 2.9047239411079, 0.39578121743921, 0.10932490532285, 0.051738858660565, 0.17840235868831, 0.024495380749894, 3.9689920754869, 4.1139229659643, 0.23327501819885, 0.97643604193256 ], lagTime);

	var freqVary = \freqVary.kr([ 143.76541377614, 14.25479545154, 6.6728691888342, 58.434807398325, 154.89385962072, 34.112274650688, 3.1140823758236, 10.42040949808, 158.59959972037, 1.2163188440936 ], lagTime);


	var numSrcs = vibrato.size;

	src = numSrcs.collect{|i|
		var freq2 = (freq * freqVary[i]) * LFNoise2.kr(0.01).range(1, 1.5);

	SyncSaw.ar(freq2, freq2 * SinOsc.ar(Line.kr(1, vibrato[i], 20) * vibRatio[i], Rand(0, 0.8)).range(pi, pi * 0.1)) * rrand(0.05, 0.1)
	};

	src = Splay.ar(src);

}).play
)

Ndef(\fun).fadeTime = 20;
//Ndef(\fun).stop

Ndef(\fun).rebuild

(
Ndef(\fun).setn(
	\lagTime, [5],
	\vibRatio, {exprand(0.1, 3)}!10,
	\freqVary, {exprand(1, 150)}!10,
	\vibrato, {exprand(0.3, 3)}!10
)
)
(
Ndef(\fun).setn(
	\lagTime, [200],
	\vibRatio, ({exprand(0.1, 3)}!10).sort,
	\freqVary, ({exprand(1, 150)}!10).sort,
	\vibrato, ({exprand(0.3, 3)}!10).sort
)
)

(
Ndef(\fun).xsetn(
	\lagTime, [100],
	\vibRatio, {exprand(0.1, 3)}!10,
	\freqVary, {exprand(1, 150)}!10,
	\vibrato, {exprand(0.3, 3)}!10
))