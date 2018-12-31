~p.push

(
SynthDef(\s1, {

	var gate = \gate.kr(1);
	var freq = Vibrato.kr(\freq.kr(432), 6, 0.001).lag(0.01);
	var width = Rand(0.3, 0.7);
	var sig = VarSaw.ar(freq * [1, 1.01], 0, width);
	var env = Env.adsr.kr(gate:gate, doneAction:Done.freeSelf);
	sig = LPF.ar(sig, 1000);
	sig = Splay.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(0.dbamp);
	Out.ar(\out.kr(0), sig);

}).add;
)

(
~s1[0] = Pdef(\figure,

	Pspawner({arg ps;

		var seq = Pseq([0,1,2,3], inf).asStream;
		var degreeadd = Pseq([2, 4, 9], inf).asStream;
		var scale = Scale.aeolian;

		inf.do({arg i;

			var degree = seq.next;
			var six = false;
			var four = false;

			if (i.mod(6) == 0) {
				six = true;
				ps.par( Pn( (instrument: \s1, degree:degree + degreeadd.next, legato:0.1, amp:0.6, scale:scale), 1) );
			};

			if (i.mod(4) == 0) {
				if (six.not) {
					ps.par( Pn( (instrument: \s1, degree:degree + 5.01, legato:0.1, amp:0.6, scale:scale), 1) );
				};
				four = true;
			};

			if (i.mod(5) == 0) {
				if (four.not && six.not) {
					ps.par( Pn( (instrument: \s1, degree:degree + 3, legato:0.1, octave:6, amp:0.7, scale:scale), 1) );
				}
			};

			if (i.mod(13) == 0) {
				ps.par( Pn( (instrument: \s1, degree:degree, octave:3, amp:1, legato:3, scale:scale), 1) );
			};

			ps.wait(0.25);
		});
	})
);
)

(
~s1[2] = \filter -> {arg in;
	FbC({arg fb; fb * 0.4 + in}, [3/8, 5/8]);
};

~s1[4] = \filter -> {arg in;
	var sig = in;
	sig = JPverb.ar(sig, 10, 0, SinOsc.kr(1/16).range(1, 1.1));
	(sig * 1.2).tanh * 0.35;
};

~s1[6] = \filter -> {arg in;
	var sig = Squiz.ar(in, [7, 12].midiratio, SinOsc.kr(1/32).range(2, 8));
	LPF.ar(sig, 2000);
};

~s1.set(\wet4, 0.4, \wet6, 0.05);
)

~s1.play(fadeTime:8);
~s1.stop(fadeTime:20);

(
Tdef(\main, {

	s.record;
	~s1.play(fadeTime:8);
	96.wait;
	~s1.stop(fadeTime:20);
	22.wait;
	s.stopRecording
}).play;
)

s.record;
s.stopRecording