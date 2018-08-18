(
SynthDef(\sine, {
	var freq = \freq.kr(432);
	var sig = SinOsc.ar(freq) + VarSaw.ar(freq, mul:0.3);
	var env = Env.adsr(decayTime:0.3, releaseTime:0.1, curve:-4).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = sig * env * \amp.kr(-10.dbamp) * AmpCompA.kr(freq);
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig)
}).add;
)

~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(1);

/////////////////////////////////////////
// p1
~p[\p1].clear;
~p[\p1].mold;
(~p[\p1][0] = Pspawner({arg ps;

	inf.do({

		var pbinds = (0..[1,2].choose).collect({arg val;
			var div = (2 ** [1,2,3]).wchoose([3,2,1].normalizeSum);
			var dur = [2,4,8].choose;
			[dur, {[1,2,4].choose}.dup(div)]
		}).collect({arg val, i;

			var size = val[1].size;
			var degrees = Ppoisson(i+1, inf).asStream.nextN(size);
			var amp = Pwhite(-15.0, -10.0).asStream.next;
			var sustain = 0.3;
			var octave = [5, 6].wchoose([1,3].normalizeSum);
			var pan = Pwhite(-0.8, 0.8, inf).asStream.next;

			Pbind(
				\instrument, \sine,
				\degree, Pseq(degrees, size * [2,4,8].wchoose([3,2,1].normalizeSum)),
				\scale, Scale.dorian,
				\delta, Pseq(val.convertRhythm, inf),
				\sustain, sustain,
				\octave, octave,
				\amp, amp.dbamp,
				\pan, pan,
				\timingOffset, i
			)
		});

		ps.par(Ppar(pbinds, 1));
		ps.wait(16);
	});
})
);

~p[\p1].play(vol:1);
~p[\p1].stop;
~p[\p1].gui;


/////////////////////////////////////////
// rev
(~p[\rev][0] = {
	var fx;
	var in = ~p[\p1].ar;
	fx = JPverb.ar(in, 3, 0, Env.circle([1,2,1],[20,20,20],0).kr, modDepth:0.6);
	fx = RLPF.ar(fx, SinOsc.kr(15).range(880, 2200), 0.7);
	fx;
});
~p[\rev].play;
~p[\rev].stop;
~p[\rev].gui;

App.recordWorkspace("ws10");
s.stopRecording


s.meter(2,2).window.alwaysOnTop_(true);

/////////////////////////////////////////
// s5

~bufs[\sines] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws6/sines.wav");

~p[\s5].clear;
~p[\s5].mold;
(~p[\s5][0] = {

	var buf = ~bufs[\sines];
	var pos = \pos.kr(0) * BufFrames.kr(buf);
	var trig = \trig.tr;
	var loop = \loop.kr(1);
	var sig = PlayBufCF.ar(2, buf, rate:[1, 0.25], trigger:trig, startPos:pos, loop:loop);
	sig;
});
~p[\s5].play;
~p[\s5].stop;
~p[\s5].gui;


(
Slider2D()
.action_({arg ctrl;
	~p[\fx2].set(
		\pr, ctrl.x.linlin(0,1,0.1,4),
		\fb, ctrl.y.postln
	);
})
.front;
)
/////////////////////////////////////////
// fx2
(~p[\fx2][0] = {
	var in = \in.ar([0,0]);
	var fbNode = FbNode(2, 10, 4);
	var fb = fbNode.delay(0.4);
	var sig = in + (fb * \fb.kr(0.4));
	sig = PitchShift.ar(sig, 0.5, pitchRatio:LFTri.kr(1/64).range(0.5,4.0), timeDispersion:0.1);
	//sig = Decimator.ar(sig, 44100/4 , 16);
	//sig = SoftClipAmp8.ar(sig, 2.1);
	fbNode.write(sig.tanh);
	sig;
});

~p[\fx2] <<> ~p[\p1];
~p[\fx2].play(vol:0.2);
~p[\fx2].stop;
~p[\fx2].gui;

/////////////////////////////////////////
// fx1
~p[\fx1].clear;
(~p[\fx1][0] = {
	var in = \in.ar([0,0]);
	JPverb.ar(in, t60:5, damp:0, size:5, modFreq:2, modDepth:0.7);
});
~p[\fx1] <<> ~p[\fx2];
~p[\fx1].play(vol:0.5);
~p[\fx1].stop;
~p[\fx1].gui;

/////////////////////////////////////////
// bufplay
~p[\bufplay].clear;
~p[\bufplay].mold;
(~p[\bufplay][0] = {

	var in = (~p[\fx2].ar + (~p[\p1].ar * 0.5));

	var buf = LocalBuf(s.sampleRate * 10, 1).clear;

	var foo = {

		var rec = \rec.kr(1);
		var renv = Env.asr.kr(gate:rec);
		var penv = Env.asr.kr(gate:rec) * \plevel.kr(0);
		//var write_index = Phasor.ar(0, 10 , 0, buf.numFrames);
		//IBufWr.ar(Mix.ar(in), buf, write_index);

		RecordBuf.ar(Mix.ar(in),
			buf,
			recLevel:renv,
			preLevel:penv,
			run:rec,
			loop:\rec_loop.kr(0),
			trigger:\rec_trig.kr(1)
		);
	}.();

	var pos = \pos.kr(0) * BufFrames.kr(buf);
	var trig = \trig.tr;
	var loop = \loop.kr(1);
	var sig = PlayBufCF.ar(1, buf, rate:[0.25, 0.5], trigger:trig, startPos:pos, loop:loop);
	Pan2.ar(sig, \pan.kr(0));
});

~p[\bufplay].set(\rec_loop, 1, \rec, 1, \plevel, 0, \rate, 0.25, \pos, 0, \trig, 0, \loop, 1)
//~p[\bufplay] <<> ~p[\fx1];
~p[\bufplay].play(vol:0.5);
~p[\bufplay].stop;


/////////////////////////////////////////
// fx4
(~p[\fx4][0] = {
	var in = ~p[\bufplay].ar;
	var sig = JPverb.ar(in, t60:5, damp:0, size:5, modFreq:2, modDepth:0.7);
	sig = sig * Env([0,0,1,1,0], [0,0.5,1,0.1], -4).kr(gate:Impulse.kr(0.5));
	sig;
});
~p[\fx4].play(vol:0.6);
~p[\fx4].stop;
~p[\fx4].gui;


App.recordWorkspace("ws6");
s.stopRecording

(~p[\amb_grain][0] = {

	var in = ~p[\fx4].ar;

	var buf = ~bufs[\sines];//LocalBuf(s.sampleRate * 10, 1).clear;

	var foo = {

		var rec = \rec.kr(1);
		var renv = Env.asr.kr(gate:rec);
		var penv = Env.asr.kr(gate:rec) * \plevel.kr(0);

		RecordBuf.ar(Mix.ar(in),
			buf,
			recLevel:renv,
			preLevel:penv,
			run:rec,
			loop:\rec_loop.kr(0),
			trigger:\rec_trig.kr(1)
		);

	};//.();

	var trig = Dust.kr(\speed.kr(1)); //\trig.tr;
	var pos = LFNoise2.kr(0.5).range(0.1,0.9);// \pos.kr(0);
	var graindur = \graindur.kr(2);
	var rate = \rate.kr([0.5, 2]);
	var envbuf = \envbuf.kr(-1).lag(0.01);
	var pan = \pan.kr(0);
	var grainamp = \grainamp.kr(1);
	var loop = \loop.kr(0);

	var amp = Dwhite(grainamp.clip(0,1), 1, inf);
	var panValue = Dwhite(pan.neg, pan, inf);
	var reverse = \reverse.kr(0.5);
	var rev = Dwrand([-1,1], [reverse,1-reverse], inf);

	var sig = GrainBufJ.ar(2,
		trig,
		dur: graindur,
		sndbuf: buf,
		rate: rate * rev,
		pos: pos,
		loop: loop,
		interp: 4,
		grainAmp: amp,
		pan: panValue,
		envbufnum: envbuf
	);

	Splay.ar(sig);
}
);

~p[\amb_grain].play;
~p[\amb_grain].stop;


/////////////////////////////////////////
// fx4
(~p[\fx5][0] = {
	var in = ~p[\amb_grain].ar;
	RLPF.ar(in, SinOsc.kr(1).range(880, 3333), 0.5);
});
~p[\fx5].play;
~p[\fx5].stop;
~p[\fx5].gui;



(~p[\flanger2][0] = {

	var f = \freq.kr([432, 432]);
	var cutoff = \cutoff.kr(1100);
	var sig = \sig.ar([0]);
	var delay = f / 2;

	var osc2 = {arg delay, sig, local;

		var pluckOffset = 5;
		var pluckCoef = 0.9;

		var sigPluck = delay.collect({|delay, i|
			delay = [
				LFCub.ar(1 / rrand(30, 36), 2.0.rand).range(delay - pluckOffset, delay + pluckOffset)
				+ SinOsc.ar(1/2).range(-0.2, 0.2),
				delay * 4.05
			];
			PeakFollower.kr(sig, 0.9) * Pluck.ar(
				sig + local, sig,
				4,
				delay.reciprocal,
				9,
				[pluckCoef, 0.1],
				[1, -16.dbamp]
			).sum;
		});
		sigPluck;
	};

	var fb = {arg f = 1, cutoff = 1;
		var local = LocalIn.ar(2);
		local = Rotate2.ar(local[0], local[1], SinOsc.kr(1/16).range(-1, 1));
		local = SoftClipAmp8.ar(local, 0.4);
		local = BLowPass.ar(local, cutoff);
		local = PitchShift.ar(local, 4 / f, [0.5, 4], 0.01).sum;
		local = Decimator.ar(local, f * 8, 16).sum;
		local = -20.dbamp * local;
		local = local + Splay.ar(DelayC.ar(local, 4, { rrand(0.0, 4.0) } ! 6, 0.5));
		local;
	};

	var clip = {arg in, sigPluck;
		var sig = SoftClipAmp8.ar(in + sigPluck, -30.dbamp, 1);
		sig = Splay.ar(sig);
		sig = sig + PitchShift.ar(sig, 2, 0.25);
		LeakDC.ar(sig);
	};

	var local = fb.(f, cutoff);
	var pluck = osc2.(delay, sig, local);
	sig = clip.(sig, pluck);
	LocalOut.ar(sig);
	sig;
});


/////////////////////////////////////////
// route
~p[\flanger2] <<>.cutoff ~p[\cutoff];
~p[\flanger2] <<>.sig ~p[\fx1];
~p[\flanger2].play(vol:2)
~p[\flanger2].stop;





