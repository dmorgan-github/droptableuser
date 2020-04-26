(
Ndef(\synth, {

	//arg out,
	//effectBus, phase_out, level_out,
	var buf = \buf.kr(0);
	//var gate = \gate.kr(0);
	var pos = \pos.kr(0);
	var speed = \speed.kr(1);
	var jitter = \jitter.kr(0);
	var size = \size.kr(0.1);
	var density = \density.kr(20);
	var density_mod_amt = \density_mod_amt.kr(0);
	var pitch = \pitch.kr(1);
	var spread = \spread.kr(0);
	var gain = \gain.kr(1);
	var envscale = \envscale.kr(1);
	var freeze = \freeze.kr(0);
	var t_reset_pos = \reset_pos.tr(0);
	var cutoff = \cutoff.kr(20000);
	var q = \q.kr(0.5);
	var mode = \mode.kr(0);
	//, send=0;

	var grain_trig;
	var trig_rnd;
	var density_mod;
	var jitter_sig;
	var buf_dur;
	var pan_sig;
	var buf_pos;
	var pos_sig;
	var sig;
	var env;
	var level;

	trig_rnd = LFNoise1.kr(density);
	density_mod = density * (2**(trig_rnd * density_mod_amt));
	grain_trig = Impulse.kr(density_mod);

	buf_dur = BufDur.kr(buf);

	pan_sig = TRand.kr(trig: grain_trig,
		lo: spread.neg,
		hi: spread);

	jitter_sig = TRand.kr(trig: grain_trig,
		lo: buf_dur.reciprocal.neg * jitter,
		hi: buf_dur.reciprocal * jitter);

	buf_pos = Phasor.kr(trig: t_reset_pos,
		rate: buf_dur.reciprocal / ControlRate.ir * speed,
		resetPos: pos);

	pos_sig = Wrap.kr(Select.kr(freeze, [buf_pos, pos]));

	sig = GrainBuf.ar(2, grain_trig, size, buf, pitch, pos_sig + jitter_sig, 4, pan_sig);
	sig = BMoog.ar(sig, cutoff, q, mode);

	//env = EnvGen.kr(Env.asr(1, 1, 1), gate: gate, timeScale: envscale);

	level = 1;//env;

	(sig * level * gain).softclip;
	//Out.ar(effectBus, sig * level * send).softclip;
	//Out.kr(phase_out, pos_sig);
	// ignore gain for level out
	//Out.kr(level_out, level);
})
)

/*
~buf.play;
~buf.numFrames

(
var path = "/Users/david/projects/droptableuser/samples/Hainbach - Isolation Loops (soundpack)/Hainbach - Isolation Loops (soundpack) - 31 Tape Piano.wav";
Buffer.readChannel(s, path, channels:[0], action:{arg buf;
	~buf = buf;
});
)

Ndef(\synth).play;
Ndef(\synth).set(\buf, ~buf);
Ndef(\synth).set(\pitch, 7.midiratio)
Ndef(\synth).set(\jitter, 0.5);


OscCtrl.trace(false);

-- arc ring 1 = speed
-- arc ring 2 = pitch
-- arc ring 3 = grain size
-- arc ring 4 = density

(
OscCtrl.path('/4/rotary1', {arg msg;
	var val = msg[0];
	Ndef(\synth).set(\speed, val);
});
OscCtrl.path('/4/rotary2', {arg msg;
	var val = msg[0];
	Ndef(\synth).set(\pitch, val.linlin(0, 1, 0, 12).midiratio);
});
OscCtrl.path('/4/rotary3', {arg msg;
	var val = msg[0];
	Ndef(\synth).set(\size, val);
});
OscCtrl.path('/4/rotary4', {arg msg;
	var val = msg[0];
	Ndef(\synth).set(\density, val.linlin(0, 1, 1, 50));
});
OscCtrl.path('/4/rotary5', {arg msg;
	var val = msg[0];
	var numframes = ~buf.numFrames;
	val = val * numframes;
	Ndef(\synth).set(\pos, val.floor);
});
OscCtrl.path('/4/rotary6', {arg msg;
	var val = msg[0];
	val.postln;
});
)


Ndef(\synth).filter(10, {arg in; Greyhole.ar(in)}).set(\wet10, 0.3)
*/


