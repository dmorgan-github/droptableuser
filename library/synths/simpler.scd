(
// http://sccode.org/1-51A#c957
SynthDef(\simpler, {
	arg buf=0
	,freq=220
	,sampleStart=0
	,loopStart=0
	,loopLen=1 // between 0 (min) and 1 (max)
	,fadeTime=0.1
	,gate=1
	,attack=0.01
	,sustain=1
	,release=1
	,f0=220;

	var rate = freq / f0;
	var sr = rate*BufSampleRate.kr(buf);
	var fadeFrames = fadeTime*sr;
	var loopEnd = loopLen*(BufFrames.kr(buf) - loopStart) + loopStart;
	var loopFrames = loopEnd - loopStart + 1;
	var loopTime = (loopFrames - fadeFrames)/sr;
	var startUpTime = (loopStart - sampleStart)/sr;

	var trigLoop = TDuty.ar(Dseq([startUpTime + loopTime, Dseq([loopTime], inf)]), gapFirst:1);

	var phaseA = Phasor.ar(trigLoop, rate, sampleStart, inf, loopStart);
	var phaseB = Phasor.ar(trigLoop, rate, loopEnd - fadeFrames, inf, loopEnd - fadeFrames);

	var srcA = BufRd.ar(buf.numChannels, buf, phaseA);
	var srcB = BufRd.ar(buf.numChannels, buf, phaseB);

	var startLoop = SetResetFF.ar(trigLoop);
	var loopPan = Phasor.ar(trigLoop, 2/fadeFrames * rate, -1, inf, -1).clip(-1,1);

	var out = Select.ar(startLoop, [srcA, LinXFade2.ar(srcB, srcA, pan:loopPan)]);
	var env = EnvGen.ar(Env.asr(attack, sustain, release, 1), gate, doneAction:2);

    Out.ar(0, Splay.ar(out) * env * \amp.kr(-6.dbamp));
}).add;
)