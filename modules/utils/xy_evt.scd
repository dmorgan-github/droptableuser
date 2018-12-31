(
~ringz = {

	var trig = \trig.tr;
	var freq = \freq.kr;
	var sig = Latch.ar(BrownNoise.ar, trig);
	sig = Formlet.ar(sig, freq, 0.001, 1) * AmpCompA.kr(freq) * -20.dbamp;
	sig = Limiter.ar(sig, 0.7);
	sig = Pan2.ar(sig, LFNoise2.kr(1)) * \amp.kr(-12.dbamp);
	sig;
};
~delay = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.3 + in}, 3/8);
	fx;
};
~verb = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 10, 0, 5);
	fx;
};
)

~delay <<> ~ringz;
~verb <<> ~delay;
~verb.play;
~ringz.play;
~delay.play;

(
~bass = {

	var freq = \freq.kr;
	var trig = \trig.tr;
	var width = SinOsc.kr(1/8).range(0.3, 0.6);
	var sig = SinOsc.ar(freq, 0, 0.5);
	var env = Env.linen(sustainTime:2, releaseTime:4).kr(gate:trig);
	//sig = DFM1.ar(sig, 880, 0.9);
	sig = Splay.ar(sig) * env * AmpCompA.kr(freq/2) * \amp.kr(-3.dbamp);
	sig;
};
~squiz = {
	var in = \in.ar([0,0]);
	var fx = Squiz.ar(in, 2, 1);
	fx;
};
~verb2 = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 10, 0, 5);
	fx
};
)

~bass.play(vol:0.5);
~squiz.play(vol:0);
~squiz.stop;
~verb2.play(vol:1)

~squiz <<> ~bass;
~verb2 <<> ~bass;

(
~sine = {

	var trig = \trig.tr;
	var freq = \freq.kr;
	var sig = SinOsc.ar(freq);
	var env = Env.perc.kr(gate:trig);
	//sig = RLPF.ar(sig, SinOsc.kr(15).range(2000, 4500), 0.3);
	sig = Splay.ar(sig) * env * \amp.kr(-35.dbamp);
	sig;
};
~verb4 = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 10, 0, 5);
	fx
};
~fbdel = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.7 + in}, 5/16);
	fx
};
)
~sine.play;
~verb4.play;

~fbdel.play;
~verb4 <<> ~sine;
~fbdel <<> ~sine;

(
~pluck = {

	var trig = \trig.tr;
	var freq = \freq.kr;
	var sig = SinOsc.ar(freq);
	var env = Env.linen.kr(gate:trig);
	sig = Splay.ar(sig) * env * \amp.kr(-25.dbamp);
	sig;
};

~verb3 = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 10, 0, 5);
	fx
}
)

~verb3.play;
~pluck.play;

~verb3 <<> ~pluck;

/////////////////////////////////////////
// app
q = q ? ();
q.seq = ((60 + Scale.dorian.semitones) ++ (72-7 + Scale.dorian.semitones).reverse);//.scramble;
q.ringz = { (type:\set, args: #[\trig, \freq], trig:1, freq:432) };
q.bass = { (type:\set, args: #[\trig, \freq], trig:1, freq:432); };
q.sine = { (type:\set, args: #[\trig, \freq], trig:1, freq:432) };
q.pluck = { (type:\set, args: #[\trig, \freq], trig:1, freq:432) };
q.midi1 = { (type:\midi, midiout: m, chan: 1) };
q.playnote = {arg self, func, note;
	var evt = func.();
	evt.midicmd = \noteOn;
	evt.midinote = note;
	evt.play;
	thisThread.clock.sched(0.1, {
		var evt = func.();
		evt.midicmd = \noteOff;
		evt.midinote = note;
		evt.play;
		//~server.sendBundle(~server.latency,
		//*["/n_set", ~id, "gate", releaseTime].flop);
		nil
	});
};




(
Evt.on(\trig, \bass, {arg val;
	/*
	if (val.mod(8) == 0) {
		var note = q.seq.wrapAt(val);
		q.bass[\freq] = (note.midicps/4);
		q.bass[\id] = ~bass.nodeID;
		q.bass.play;
	};
	*/
});

{
	var cnt = 0;
	Evt.on(\trig, \ringz, {arg data;

		var ps = data[\ps];
		var incr = data[\incr];
		var note = q.seq.wrapAt(incr);

		cnt = cnt + 1;

		ps.par( Pn( (midinote: note, sustain:0.5), 1) );

		[cnt, cnt.mod(8)];
		if (cnt.mod(8) == 0) {
			ps.par( Pn( (midinote: note + 12), 1), 1 );
		};

		if (cnt.mod(13) == 0){
			ps.par( Pbind(\foo, Pseries(0, 1, 12), \midinote, note + Pkey(\foo), \dur, 0.125) )
		};

		/*
		var ps = dict[\ps];

		var note = q.seq.wrapAt(dict[\incr]);
		//q.ringz[\freq] = note.midicps;
		//q.ringz[\id] = ~ringz.nodeID;
		//q.ringz.play;

		var evt = q.midi1;
		evt.midicmd = \noteOn;
		evt.midinote = note;
		ps.par(evt);

		evt = q.midi1;
		evt.midicmd = \noteOff;
		evt.midinote = note;
		ps.par(evt, 0.1);

		*/
	});

}.();

Evt.on(\xtrig, \xy, {arg val;

	/*
	if (0.2.coin) {
		var note = q.seq.wrapAt(val);
		q.sine[\freq] = (note + 24).midicps;
		q.sine[\id] = ~sine.nodeID;
		q.sine.play;
	}
	*/
});
Evt.on(\ytrig, \xy, {arg val;

	/*
	if (val.mod(2) == 0){
		var note = q.seq.wrapAt(val);
		q.pluck[\freq] = (note + 7).midicps;
		q.pluck[\id] = ~pluck.nodeID;
		q.pluck.play;
	}
	*/
});
Evt.on(\clock, \xy, {
	//\clock.postln;
});
)




(
Pdef(\seq,
	Pspawner({arg ps;

		var xdivs = [5];
		var ydivs = [3,7];

		var xincr = 0;
		var yincr = 0;

		inf.do({arg i;

			var xfound = false;
			var yfound = false;

			xdivs.do({arg div;
				if ( (i.mod(div) == 0) && xfound.not) {
					xfound = true;
					xincr = xincr + 1;
				};
			});

			ydivs.do({arg div;
				if ( (i.mod(div) == 0) && yfound.not) {
					yfound = true;
					yincr = yincr + 1;
					xincr = xincr + yincr.mod(4).asInt;
				};
			});

			if (xfound || yfound) {
				if (xfound){
					Evt.trigger(\xtrig, (incr:xincr, ps:ps, count:i));
				};
				if (yfound) {
					Evt.trigger(\ytrig, (incr:xincr, ps:ps, count:i));
				};
				Evt.trigger(\trig, (incr:xincr, ps:ps, count:i));
			};

			Evt.trigger(\clock, (count:i, ps:ps));

			ps.wait(0.25);
		});
	})
);
)
Pdef(\seq).play;
Pdef(\seq).stop;