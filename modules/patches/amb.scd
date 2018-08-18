~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 1.0;

/////////////////////////////////////////////
// pattern
(~p[\amb][0] = Pbind(

	\dur, 0.5,
	\sustain, 0.1,
	\scale, Scale.dorian,
	\mtranspose, Pstutter(8, Pseq([0,1,-2,2], inf)),
	\octave, 4,
	\degree, Pstutter(Pseq([2,4,6] * 2, inf), Prout({
		loop({
			// it is not necessary to do it this way...
			var seq = Pwhite(0, 12, inf).clump(10).asStream;
			seq.next.do({arg val;

				if (0.2.coin) {
					(val + 7).yield;
				}{
					val.yield;
				}
			});
		})
	})),
	\amp, -12.dbamp
))

~p[\amb].vol = 1;
~p[\amb].play;
~p[\amb].stop;

/////////////////////////////////////////////
// delay
(~p[\amp_del][0] = {
	var in = \in.ar([0,0]);
	var delayL = \delayL.kr(3).lag(0.1);
	var delayR = \delayR.kr(5).lag(0.1);
	var fx = DelayC.ar(in, 10, [delayL/4, delayR/4]);
	fx = RLPF.ar(fx, SinOsc.kr(5).range(220, 2200), \rq.kr(1).lag(0.01));
	fx
})

~p[\amp_del] <<> ~p[\amb];
~p[\amp_del].play;
~p[\amp_del].stop;

/////////////////////////////////////////////
// reverb
(~p[\amp_verb][0] = {

	var in = \in.ar([0,0]);
	var size1 = \size1.kr(5).lag(0.1);
	var size2 = \size2.kr(10).lag(0.1);
	var modDepth = \mdepth.kr(0.6);

	var fx = JPverb.ar(in, 5, size:size1);
	//fx = JPverb.ar(fx, 10, size:5, modDepth:modDepth);
	fx;
})

~p[\amp_verb] <<> ~p[\amp_del];
~p[\amp_verb].play;
~p[\amp_verb].stop(fadeTime:10);

/////////////////////////////////////////////
// eq
(~p[\eq][0] = {
	var in = \in.ar([0,0]);
	var amp = \amp.kr(0.1);
	var fx = BHiShelf.ar(in, 2200, 1, amp.ampdb);
	fx;
})

~p[\eq].vol = 0.5;
~p[\eq] <<> ~p[\amp_verb];
~p[\eq].play;
~p[\eq].stop;


/////////////////////////////////////////////
// second delay
(~p[\amp_del2][0] = {
	var in = \in.ar([0,0]);
	var fx = DelayC.ar(in, 10, 4);
	fx;
	in;
})
~p[\amp_del2] <<> ~p[\amp_verb];
~p[\amp_del2].vol = 0.5;
~p[\amp_del2].play;
~p[\amp_del2].stop;

/////////////////////////////////////////////
// grain

(~p[\amb_grain][0] = {

	var in = \in.ar([0,0]);

	var buf = LocalBuf(s.sampleRate * 10, 1).clear;

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
	}.();

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

	var sig = GrainBufJ.ar(1,
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

/////////////////////////////////////////
// bufplay
~p[\bufplay].mold;
(~p[\bufplay][0] = {

	var in = \in.ar([0,0]);

	var buf = LocalBuf(s.sampleRate * 10, 1).clear;

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
	}.();

	var pos = \pos.kr(0) * BufFrames.kr(buf);
	var trig = \trig.tr;
	var loop = \loop.kr(1);
	var sig = PlayBufCF.ar(1, buf, rate:\rate.kr(1), trigger:trig, startPos:pos, loop:loop);
	Pan2.ar(sig, \pan.kr(0));
});

~p[\bufplay].set(\rec_loop, 1, \rec, 1, \plevel, 0.7, \rate, -0.5, \pos, 0, \trig, 0, \loop, 1)
~p[\bufplay] <<> ~p[\delayorama1];
~p[\bufplay].play;
~p[\bufplay].stop;


/////////////////////////////////////////
// ui
(
Fdef(\xy, {arg ctrl, x, y;

	var rate = x.linlin(0, 1, 0.1, 8).round;
	var rev = y;

	rate = Scale.dorian.degrees[rate];
	~p[\amb_grain].set(\rate, rate.midiratio, \rev, rev);
});

Fdef(\xy2, {arg ctrl, x, y;
	var speed = x.linlin(0,1,1/32, 32);
	var graindur = y.linlin(0,1,1/16,16);
	~p[\amb_grain].set(\speed, speed, \graindur, graindur);
});

Fdef(\xy3, {arg ctrl, x, y;
	~p[\mix1mix].set(\mix0, x * 0.1, \mix1, y)
});
)
(
var view = View().layout_(VLayout()).fixedSize_(200);

var hlayout = HLayout(

	VLayout(
		Slider2D().action_({arg ctrl;
			Fdef(\xy).value(ctrl, ctrl.x, ctrl.y);
		}),
		Slider2D().action_({arg ctrl;
			Fdef(\xy2).value(ctrl, ctrl.x, ctrl.y);
		})
	),
	VLayout(
		Slider2D().action_({arg ctrl;
			Fdef(\xy3).value(ctrl, ctrl.x, ctrl.y);
		})
	)
);

view.layout.add(hlayout);
view.front;
)

~p[\amb_grain].set(\rec, 1)
~p[\amb_grain].vol = 0.5;
~p[\amb_grain] <<> ~p[\gauss];
~p[\amb_grain].play;
~p[\amb_grain].stop;

/////////////////////////////////////////
// gauss
~p[\gauss].clear;
(
var circle = Library.at(\circle);
~p[\gauss][0] = Pbind(

	\dur, 0.5,
	\scale, Scale.dorian,
	\sustain, 2,
	//\mtranspose, Pstutter(32, Pseq([0,1,-2,2], inf)),
	//\degree, Pgauss(Pstutter(8, Pseq([0,2,4,6], inf)), Pstutter(16, Pseq([1,2,3,4], inf)), inf).round,

	\degree, Pseq([
		Pseq(circle[\first], 4),
		Pseq([\], 8),
		Pseq(circle[\fifth], 4),
		Pseq([\], 8),
		Pseq(circle[\second], 4),
		Pseq([\], 8),
		Pseq(circle[\seventh], 4),
		Pseq([\], 8),
	], inf),
	\octave, 5, //Pbjorklund(5, 7, inf).collect({arg val; if (val==0) {4}{5} }),
	\amp, 0.3,//Pfunc({|ev| ev[\octave].reciprocal * 0.5 }) * 2
));

~p[\gauss].vol = 1;
~p[\gauss].play;
~p[\gauss].stop;


/////////////////////////////////////////
// mix1mix
(~p[\mix1mix][0] = \mix -> {
	var sig = Mix.ar(~p[\amb_grain]) ;
	sig = RLPF.ar(sig, SinOsc.kr(SinOsc.kr(0.1).range(0.1, 5)).range(220, 2220), 0.5);
	sig;
})
~p[\mix1mix][1] = \mix -> { ~p[\gauss] };
~p[\mix1mix].set(\mix0, 0.08, \mix1, 0.7)
~p[\mix1mix].play;
~p[\mix1mix].stop;

/////////////////////////////////////////
// grain_verb
~p[\grain_verb].clear;
(~p[\grain_verb][0] = {

	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in,
		\t60.kr(1),
		\damp.kr(0),
		\size.kr(1),
		\earlyDiff.kr(0.707),
		\modDepth.kr(0.1),
		\modFreq.kr(2)
	);
	fx;
});
~p[\grain_verb] <<> ~p[\bufplay];//~p[\mix1mix];
~p[\grain_verb].vol = 1;
~p[\grain_verb].play;
~p[\grain_verb].stop;



(~p[\gauss_rev] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in,
        \t60.kr(1),
        \damp.kr(0),
		\size.kr([3,5]),
        \earlyDiff.kr(0.707),
        \modDepth.kr(0.1),
        \modFreq.kr(2));
	fx;
});

~p[\gauss_rev] <<> ~p[\gauss]
~p[\gauss_rev].play;
~p[\gauss_rev].stop;


App.recordWorkspace("ws14");
s.stopRecording


(~p[\filter][0] = {
	var in = \in.ar([0,0]);
	{in = MoogVCF.ar(in, SinOsc.kr(LFNoise2.kr(0.1).range(1,3)).range(220, 6666), 0.5, mul:1.5)}.dup(2);
	in;
});

~p[\filter].vol = 1;
~p[\filter] <<> ~p[\jpverb1];
~p[\filter].play;
~p[\filter].stop;

~p[\jpverb1].stop;


(~p[\wv][0] = {
	var in = \in.ar([0,0]);
	WaveLoss.ar(in);
});
~p[\wv] <<> ~p[\filter];
~p[\wv].play;
~p[\wv].stop;


(~p[\dec][0] = {
	var in = \in.ar([0,0]);
	Decimator.ar(in, 44100/\rate.kr(1), \bits.kr(24));
});
~p[\dec] <<> ~p[\wv];
~p[\dec].play;
~p[\dec].stop;

(
Slider2D().action_({arg ctrl;
	var x = ctrl.x.linlin(0,1,1,8);
	var y = ctrl.y.linlin(0,1,4,24);
	~p[\dec].set(\rate, x, \bits, y);
}).front
)




(
Slider2D().action_({arg ctrl;

	var x = ctrl.x.linlin(0,2,200,5000);
	var y = ctrl.y;
	~p[\filter].set(\freq, x, \res, y);
}).front;
)


(
{ // controlling index
	i = Latch.kr(
		LFSaw.kr(MouseX.kr(1.1, 30), 0, 5, 5),
		Impulse.kr(10));
	PMOsc.ar(300, 356, i, mul: 0.3)
}.scope(1)
)


(~p[\synth1][0] = {
    var i = Latch.kr(
		LFSaw.kr(MouseX.kr(1.1, 30), 0, 5, 5),
		Impulse.kr(10)
	);
	Splay.ar(PMOsc.ar(300, 356, i, mul: 0.3)) * 0.3;
});
(~p[\synth1].filter(2, {arg in;

	var fx = JPverb.ar(in,
		\t60.kr(1),
		\damp.kr(0),
		\size.kr(1),
		\earlyDiff.kr(0.707),
		\modDepth.kr(0.1),
		\modFreq.kr(2));
	fx;

}).set(\wet2, 0);
)

~p[\synth1].play;
~p[\synth1].stop;


(
Pdef(\outer, Pbind())
)



/////////////////////////////////////////
// synth1
~p[\synth1_verb].clear;
(~p[\synth1_verb][0] = {

	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in,
        \t60.kr(1),
        \damp.kr(0),
        \size.kr(1),
        \earlyDiff.kr(0.707),
        \modDepth.kr(0.1),
        \modFreq.kr(2));
	fx;
});
~p[\synth1_verb] <<> ~p[\synth1];
~p[\synth1_verb].play;
~p[\synth1_verb].stop;


(
{
	SinOsc.ar(
		Latch.kr(
			LFSaw.kr(Line.kr(0.1, 20, 60), 0, 500, 600),
			Impulse.kr(10)),
		mul: 0.3 //Volume of Blip
	)
}.scope(1))



(
{var freq, latchrate, index, ratio, env, rate;
	rate = 9;
	latchrate = rate*LFNoise0.kr(1/10, mul: 0.03, add: 1.6);
	index = Latch.kr(
		LFSaw.kr(latchrate, mul: 5, add: 6),
		Impulse.kr(rate)
	);
	freq = Latch.kr(
		LFSaw.kr(latchrate,
			mul: max(0, LFNoise1.kr(1/5, 14, 10)),
			add: LFNoise0.kr(1/7, 22, 50)),
		Impulse.kr(rate)
	).round(1).midicps;
	ratio = LFNoise1.kr(1/10, mul: 2.0, add: 5.0);
	env = EnvGen.kr(Env.perc(0, LFNoise0.kr(rate, 1, 1.5)/rate), Impulse.kr(rate),
		LFNoise1.kr([5, 5], 2, 1).max(0).min(0.8));
	PMOsc.ar(
		[freq, freq * 1.5],
		freq*ratio,
		index,
		mul: env //overall volume
)}.play
)


