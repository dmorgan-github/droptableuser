"https://freesound.org/people/juskiddink/sounds/109193/"
~bufs[\b1] = Buffer.read(s, "/Users/david/Downloads/109193__juskiddink__leq-acappella.wav");

~bufs[\b1].duration

/////////////////////////////////////////
// mod22
~p[\mod22].clear;
~p[\mod22].mold;
(~p[\mod22][0] = {

	var trig = \trig.tr;

	var osc1 = {

		var freq = 4; //30.790476190476.reciprocal
		var buf = ~bufs[\b1];
		var numFrames = BufFrames.kr(buf);

		//var pos1 = (Stepper.kr(trig, 0, 3, 7, 1) * 0.01);
		var pos = LFSaw.kr([\posrateL.kr(1).lag(0.1), \posrateR.kr(1.002).lag(0.1)]).range(0, 1);// * 0.01);

		//var trig = Changed.kr(pos);
		var rate = \rate.kr(1);//[\ratel.kr(1).lag(14), \rater.kr(1).lag(14)];//[1, 1.002];//Demand.kr(trig, 0, Drand([-1,1], inf)) * 0.midiratio;

		//var pos = [pos1, pos2];
		var startPos = numFrames * pos;
		var loop = 1;
		//var sig = PlayBuf.ar(2, buf, rate, Impulse.kr(0.5), startPos, loop);
		var sig = PlayBuf.ar(2, buf, rate, trig, startPos, loop);
		//var env = Env([1,1,0], [0, freq.reciprocal], 0).kr(gate:trig);
		//sig = FbC({arg fb; RLPF.ar(fb * 0.8, SinOsc.kr(1/4).range(880, 2200), 0.8) + sig}, 0.1).tanh + sig;
		sig ;//* env;
	};

	var sig = [
		osc1.()
	].sum;

	var env = Env.linen(sustainTime:0, releaseTime:0.2).kr(gate:trig);

	sig = sig * env * \amp.kr(0.dbamp);

	//sig = FbC({arg fb; FreqShift.ar(fb, [-3,3]) * 0.3 + sig}, [3/8, 5/8]) * 0.6 + sig;

	sig = JPverb.ar(sig, 5, 0, 5) * 0.4 + sig;

	sig = Splay.ar(sig.flatten, 1);
	sig;
};
//~p[\mod22].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);

(~p[\mod22][4] = \set -> Pbind(
	\rate, Pseq(([0, 3, 2, -2] -5).midiratio, inf),
	\dur, Pseq([1, 1], inf) * 0.25,
	\trig, 1,
	\amp, 0.1
))

//~p[\mod22].set(\posrateL, nil, \ratel, nil, \posrateR, nil, \rater, nil);
//~p[\mod22].set(\posrateL, 1, \ratel, 1, \posrateR, 1.002, \rater, 1);
~p[\mod22].play(vol:1, fadeTime:3);
~p[\mod22].stop;

App.saveWorkspace("ws14");

//////////////////////////////////////////////////////////////


(~p[\mod23][0] = {

	var trig = \trig.tr;

	var osc1 = {

		var freq = 4; //30.790476190476.reciprocal
		var buf = ~bufs[\b1];
		var numFrames = BufFrames.kr(buf);

		//var pos1 = (Stepper.kr(trig, 0, 3, 7, 1) * 0.01);
		var pos = LFSaw.kr([1, 1.02, 0.502]).range(0, 1);// * 0.01);

		//var trig = Changed.kr(pos);
		var rate = \rate.kr(1);//\rate.kr(1).lag(0.01);//[\ratel.kr(1).lag(14), \rater.kr(1).lag(14)];//[1, 1.002];//Demand.kr(trig, 0, Drand([-1,1], inf)) * 0.midiratio;

		//var pos = [pos1, pos2];
		var rev = Demand.kr(LFDClipNoise.kr(1/4), 0, Drand([-1,1], inf));
		var startPos = numFrames * pos;
		var loop = 1;
		var sig = PlayBuf.ar(2, buf, rate * rev, trig, startPos, loop);
		//var env = Env([1,1,0], [0, freq.reciprocal], 0).kr(gate:trig);
		//sig = FbC({arg fb; RLPF.ar(fb * 0.8, SinOsc.kr(1/4).range(880, 2200), 0.8) + sig}, 0.1).tanh + sig;
		Splay.ar(sig) ;//* env;
	};

	var sig = [
		osc1.()
	].sum;

	var env = Env.linen(sustainTime:2, releaseTime:2).kr(gate:trig);

	sig = sig * env * \amp.kr(0.dbamp);// * LFPulse.kr(SinOsc.kr([1/8, 1/32, 1/64]).range(2, 20));

	sig = FbC({arg fb; FreqShift.ar(fb, [-3,3]) * 0.3 + sig}, [3/8, 5/8]) * 0.6 + sig;

	sig = JPverb.ar(sig, 10, 0, 5) * 0.6 + sig;

	sig = Splay.ar(sig.flatten, 0.7);
	sig;
};
);

TempoClock.default.tempo_(60/60)


(~p[\mod23][4] = \set -> Pbind(
	\rate, Pseq(([0, 3, 2, -2]).midiratio.pyramid, inf),
	\dur, Pseq([2,4, 8], inf),
	\amp, 0.3,
	\trig, 1
))

//~p[\mod22].set(\posrateL, nil, \ratel, nil, \posrateR, nil, \rater, nil);
//~p[\mod22].set(\posrateL, 1, \ratel, 1, \posrateR, 1.002, \rater, 1);
~p[\mod23].play(vol:0.7, fadeTime:3);
~p[\mod23].stop;



~p[\mix][0] = {~p[\mod22] * 0.5};
~p[\mix][1] = {~p[\mod23] * 0.3};
(
~p[\mix][10] = \filter -> {arg in;
	var trig = \trig.tr;
	var freq = \freq.kr(432);
	var sig = SoftClipAmp8.ar(in, 10);
	//sig = FbC({arg fb; fb * 0.5 + sig}, [3/8, 5/8]).tanh * 0.6 + sig;
	sig = JPverb.ar(sig, 2, 0, 1/\freq.kr(432).lag(0.1), modDepth:0.5) * 0.4 + sig;
	Splay.ar(sig, spread:0.7);
}
)

(
~p[\mix][20] = \set -> Pbind(
	\octave, 2,
	\degree, Pseq([0, 3, 2, -2].midiratio, inf),
	\dur, Prand([0.5, 2, 1], inf) * 1,
	\trig, 1
)
)

App.saveWorkspace("ws15", rec:true);
~p[\mod23].play(vol:0.7, fadeTime:3);
~p[\mix].play(vol: 0.3);

~p[\mix].stop(fadeTime:5);
~p[\mod23].stop(fadeTime:20);

App.saveWorkspace("ws15", rec:true);
s.stopRecording


(
Tdef(\main, {

	~p[\mod23].play(vol:1, fadeTime:3);
	64.wait;
	~p[\mix].play(vol: 0.5);
	64.wait;
	~p[\mod22].play(vol:1, fadeTime:3);

}).play;
)

~mod22_win = App.guiHelper(~p[\mod22], "mod22");
~mod22_win.front;
s.stopRecording