
(
SynthDef(\jwgeu, {
	var freq = \freq.kr(220);
	var freqmul = Line.ar(2, 1, 0.01);
	var sig = SinOsc.ar(freq * freqmul, 0.5pi);
	var aeg = Env.perc(\atk.kr(0.001), \rel.kr(0.001), curve:\curve.kr(-8)).ar(doneAction:Done.freeSelf);
	sig = sig * aeg * \amp.kr(0.2);
	sig = Splay.ar(sig);
	OffsetOut.ar(\out.kr(0), sig);
}).add;
)

/////////////////////////////////////////
// jwgeu
~jwgeu = S(\jwgeu, \jwgeu);
~jwgeu.octave = 6;
~jwgeu.stretch = 0.5;
~jwgeu.dur_([3, 2, 1, 1, 0.5, 0.5].mirror2.pseq).octave_([6,7].pseq).amp_(0.15).rel_(0.05).curve_(-14);
~jwgeu.play;
~jwgeu.stop;
~jwgeu.amp = 0.05;




/////////////////////////////////////////
// vou
(
var env = Env.xyc({ [ 1.0.rand , 1.0.rand, -4.rand2] } ! 16, \exp);
~dur = env.times.linlin(0, 1, 0.125, 2.0);
~degree = (env.levels * 7).floor;
)

(
~vou = S(\vou, {arg freq, gate;
	var osc1 = {arg freq;
		var sig = SinOscFB.ar(freq, feedback:Rand(0.5, 0.8));
		var res = \res.kr(0.8).linlin(0, 1, 0, 4);
		var feg = \cutoff.kr(1200) * Line.ar(\fvel.kr(2), 1, \fdur.kr(0.1));
		sig = MoogFF.ar(sig, feg, res) * 4;
		sig;
	};
	var mix = osc1.(freq);
	mix;
})
)

~vou.fx(90, \delay);
~vou.fx(100, {arg in; JPverb.ar(in, 3, 0, 3) });
~vou.wet90 = 0.3;
~vou.wet100 = 0.3;

~vou.detunehz = 0.5;
~vou.legato_(0.7).root_(4).octave_(4).harmonic_(1);
~vou.amp = 0.6;
~vou.vel = [1, 0.7].normalizeSum;
~vou.fdur = Pkey(\sustain);
~vou.res = 0.6;
~vou.stretch = 1;
~vou.ddl( [0, 1, [2, [3, [2,3]]], 1, -1, \] ++ {\}.dup(4) ++ [-7] ++ {\}.dup(5)).amp_(0.2);
~vou.play;
~vou.stop;


/////////////////////////////////////////
// record
App.saveWorkspace("wip3", rec:true);
s.stopRecording;

