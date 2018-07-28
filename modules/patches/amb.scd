~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 1.0;

(~p[\amb][0] = Pbind(

	\dur, 0.125,
	\sustain, 0.1,
	\scale, Scale.dorian,
	\mtranspose, Pstutter(8, Pseq([0,1,-2,2], inf)),
	\octave, 4,
	\degree, Pstutter(Pseq([2,4,6] * 2, inf), Prout({
		loop({
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
	\amp, 0.3
)
)

~p[\amb].vol = 1;
~p[\amb].play;
~p[\amb].stop;

(~p[\amp_del][0] = {
	var in = \in.ar([0,0]);
	var delayL = \delayL.kr(3).lag(0.1);
	var delayR = \delayR.kr(5).lag(0.1);
	var fx = DelayC.ar(in, 10, [delayL/4, delayR/4]);
	fx = RLPF.ar(fx, SinOsc.kr(0.1).range(220, 2200), \rq.kr(1).lag(0.01));
	fx
})

~p[\amp_del] <<> ~p[\amb];
~p[\amp_del].play;
~p[\amp_del].stop;


(~p[\amp_verb][0] = {

	var in = \in.ar([0,0]);
	var size1 = \size1.kr(5).lag(0.1);
	var size2 = \size2.kr(10).lag(0.1);
	var modDepth = \mdepth.kr(0.6);

	var fx = JPverb.ar(in, 5, size:size1);
	fx = JPverb.ar(fx, 10, size:10, modDepth:modDepth);
	fx;
})

~p[\amp_verb] <<> ~p[\amp_del];//~p[\amp_del];
~p[\amp_verb].play;
~p[\amp_verb].stop(fadeTime:10);


(~p[\eq][0] = {
	var in = \in.ar([0,0]);
	var amp = \amp.kr(0.1);
	var fx = BHiShelf.ar(in, 2200, 1, amp.ampdb);
	fx;
})

~p[\eq].vol = 0.5;
~p[\eq] <<> ~p[\amp_verb];
~p[\eq].play;
~p[\amp_verb].vol = 0.5;

(~p[\amp_del2][0] = {
	var in = \in.ar([0,0]);
	var fx = DelayC.ar(in, 10, 4);
	fx;
})
~p[\amp_del2] <<> ~p[\amp_verb];
~p[\amp_del2].vol = 0.5;
~p[\amp_del2].play;


/////////////////////////////////////////////
// ui actions
(
Fdef(\dc_0_1, {arg ctrl, x, y, modifiers, buttonNumber, clickCount;
	if(clickCount == 2) {
		if (~p[\amb].isMonitoring) {
			"stop amb".postln;
			~p[\amb].stop;
		} {
			"play amb".postln;
			~p[\amb].play;
		}
	}
});

Fdef(\mm_0_1, {arg ctrl, x, y, modifiers, buttonNumber, clickCount;
	y.debug("am vol");
	~p[\amb].vol = y
});

Fdef(\mu_0_2, {arg ctrl, x, y;

	var delayL = x.linlin(0,1,1,16).round;
	var delayR = y.linlin(0,1,1,16).round;
	[delayL, delayR].postln;
	~p[\amp_del].set(\delayL, delayL, \delayR, delayR);
});

Fdef(\dc_0_2, {arg ctrl;
	if (~p[\amp_del].isMonitoring) {
		"amp_del stop".postln;
		~p[\amp_del].stop;
	}{
		"amp_del start".postln;
		~p[\amp_del].play;
	}
});

Fdef(\mm_0_0, {arg ctrl, x, y, modifiers;

	var size1 = x.linlin(0,1,1,5);
	var size2 = size1 * 2;
	var mdepth = y;

	~p[\amp_verb].set(\size1, size1, \size2, size2, \modDepth, mdepth);
	~p[\eq].set(\amp, y);
	~p[\amp_del].set(\rq, y);
	~p[\amb_mix].set(\mix1, 0.1-y);
});
)

~grid_ui.(size:200,grid:3);

App.recordWorkspace("ws14");
s.stopRecording

