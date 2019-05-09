(
var scale = FloatArray[0, 2, 3.2, 5, 7, 9, 10]; // dorian scale
var buf = Buffer.alloc(Server.default, scale.size,1, {arg b; b.setnMsg(0, scale) });
Library.put(\bufs, \dorian, buf);
)

(
Ndef(\drone, {

	var buffer = Library.at(\bufs, \dorian);
    var sig = SinOsc.ar(
        (
            DegreeToKey.kr(
                buffer.bufnum,
				Latch.kr(Gendy1.kr(1, 1, 1, 1, 1, 1).range(0,4), Dust.kr(0.1)),        // mouse indexes into scale
                12,                    // 12 notes per octave
                1,                    // mul = 1
                72                    // offset by 72 notes
            )
            + LFNoise1.kr([3,3], 0.04)    // add some low freq stereo detuning
        ).midicps,                        // convert midi notes to hertz
        0,
        0.1);

    sig = sig + RLPF.ar(LFPulse.ar([48,55].midicps, 0.15), SinOsc.kr(0.1, 0, 10, 72).midicps, 0.1, 0.1);

	//sig = sig.blend(
	//	FbC({arg fb; PitchShift.ar(fb * 0.8 + sig, 0.5, [7,12].midiratio, 0.01, 0.01)}, 1).tanh,
	//	SinOsc.kr(1).range(0.1, 0.5));

    // add some 70's euro-space-rock echo
	sig = sig.blend(CombN.ar(sig, 0.31, 0.31, 2, 1), 0.8);

	sig = sig.blend(JPverb.ar(sig, 5, 0, 5), 0.4);

	Splay.ar(sig) * \amp.kr(-15.dbamp);
})
)

Ndef(\drone).play;
