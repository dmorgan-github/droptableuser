~p.push;

/////////////////////////////////////////
// t4 settings

Pdefn(\t4_mtranspose, 0);
Pdefn(\t4_root, 0);
Pdefn(\t4_scale, Scale.dorian);
Pdefn(\t4_dur, 0.25);
Pdefn(\t4_degrees, Pseq([0], inf));

/////////////////////////////////////////
// t4 base pattern
(
Pdef(\t4_base,

	Pbind(
		\type, \set,
		\id, Pfunc({arg evt; evt[\node].nodeID;}),
		\args, #[\trig, \freq, \amp],// ++ params.keys.asArray,
		\trig, 1,
		\scale, Pdefn(\t4_scale),
		\mtranspose, Pdefn(\t4_mtranspose),
		\root, Pdefn(\t4_root),
		\amp, Pkey(\amp) * 1
	)
);
)

/////////////////////////////////////////
// t4
(
var envir = currentEnvironment;

var patterns = [
	{
		var p = Pbind(
			\amp, -3.dbamp,
			\octave, 3,
			\degree, 0,
			\foo, 1,
			\dur, Pbjorklund2(5, 8, inf) * 0.25,
		);

		var n = {

			var trig = \trig.tr;
			var env = Env.perc(releaseTime:1).kr(gate:trig);

			var car_freq = \freq.kr(432);
			var	mod_ratio = 0.5;
			var mod_index = car_freq * mod_ratio * Env([12, 12, 0.1], [0, 1], -4).kr(gate:trig);
			var sig = SinOsc.ar(car_freq + (SinOsc.ar(car_freq * mod_ratio) * mod_index));
			sig = Pan2.ar(sig, \pan.kr(0)) * env * \amp.kr(-3.dbamp);
			sig;
		};

		(k:\t4_1, p:p, n:n);
	},

	{
		var p = Pbind(
			\amp, -18.dbamp,
			\octave, 6,
			\degree, Prand([1,3,4], inf),
			\dur, Prand([0.25, 0.5, 1, 2], inf),
		);

		var n = {

			var trig = \trig.tr;
			var env = Env.perc(releaseTime:1).kr(gate:trig);

			var car_freq = \freq.kr(432);//\freq.kr(432);
			var	mod_ratio = 2.5;
			var mod_index = car_freq * mod_ratio * Env([3, 3, 0.1],[0, 0.2],0).kr(gate:trig);
			var sig = SinOsc.ar(car_freq + (SinOsc.ar(car_freq * mod_ratio) * mod_index));
			sig = Pan2.ar(sig, \pan.kr(0)) * env * \amp.kr(-3.dbamp);
			sig;
		};

		(k:\t4_2, p:p, n:n);
	},

	{
		var p = Pbind(
			\amp, -18.dbamp,
			\octave, 6,
			\degree, 2,
			\dur, Prand([0.125, 0.5, 2, 4], inf),
		);

		var n = {

			var trig = \trig.tr;
			var env = Env.perc(releaseTime:1).kr(gate:trig);

			var car_freq = \freq.kr(432);//\freq.kr(432);
			var	mod_ratio = 1.751;
			var mod_index = car_freq * mod_ratio * Env([0.1, 0.1, 2],[0, 0.05], -4).kr(gate:trig);
			var sig = SinOsc.ar(car_freq + (SinOsc.ar(car_freq * mod_ratio) * mod_index));
			sig = Pan2.ar(sig, \pan.kr(0)) * env * \amp.kr(-3.dbamp);
			sig;
		};

		(k:\t4_3, p:p, n:n);
	},

	{
		var p = Pbind(
			\amp, -8.dbamp,
			\octave, 6,
			\degree, 0,
			\foo, 2,
			\dur, Pseq([Rest(1), 1], inf),
		);

		var n = {

			var trig = \trig.tr;
			var env = Env.perc(releaseTime:1).kr(gate:trig);

			var car_freq = \freq.kr(432);//\freq.kr(432);
			var	mod_ratio = [1.751, 2.1];
			var mod_index = car_freq * mod_ratio * Env([3, 3, 0.1],[0, 0.1], -4).kr(gate:trig);
			var sig = SinOsc.ar(car_freq + (SinOsc.ar(car_freq * mod_ratio) * mod_index));
			sig = Pan2.ar(sig.sum, \pan.kr(0)) * env * \amp.kr(-3.dbamp);
			sig;
		};

		(k:\t4_4, p:p, n:n);
	}

].collect({arg func, i;
	var obj = func.();
	var key = obj[\k];
	var pat = obj[\p];
	var node = obj[\n];
	if (node.isKindOf(Function)) {
		envir[key] = node;
		node = envir[key];
	};
	Pdef(\t4_base) <> Pbind(\node, Pfunc({node})) <> pat;
});

{
	var toMerge = List();
	var mergeFunc = {arg events;
		//events.detect({arg e; e[\foo] == 1})
		var event = events.detect({arg e; e[\foo] == 1});
		if (event.isNil.not) {
			event;
		} {
			event = events.detect({arg e; e[\foo] == 2});
			if (event.isNil.not) {
				event;
			}{
				events.choose;
			}
		}
	};
	Pdef(\t4_filter, Pfunc({arg event;

		// collect parallel events
		if (event[\delta] < 0.000001) {
			toMerge.add(event);
			// replace current event with silence
			event = Event.silent(event[\delta], event);
		} {
			// last parallel event will have non-zero delta
			if (toMerge.size > 0) {
				// add event to accumulation
				toMerge.add(event);
				// call logic to create merged event
				event = mergeFunc.(toMerge).put(\delta, event[\delta]);
				// start all over
				toMerge.clear();
			}
		};
		event;
	}));
}.();

Pdef(\t4_main, {
	"init".debug(\t4_main);
	Pdef(\t4_filter) <> Ppar(patterns, inf);
});
)

/////////////////////////////////////////
// t4 play

~t4_1.play;
~t4_1.stop;
~t4_2.play;
~t4_3.play;
~t4_4.play;
Pdef(\t4_main).play;
Pdef(\t4_main).stop;



(
var t4_1 = ~t4_1;
var t4_2 = ~t4_2;
var t4_3 = ~t4_3;
var t4_4 = ~t4_4;
var t4_del = ~t4_del;
var t4_mix = ~t4_mix;
var t4_rev = ~t4_rev;
Pdef(\t4_player, {
	t4_del.play;
	t4_mix.play;
	t4_rev.play;

	Pdef(\t4_main)
})
)

Pdef(\t4_player).play;
Pdef(\t4_player).stop;




(
~t4_del = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.3 + in}, [1.4/4, 4/4]);
	fx
}
)
~t4_del.play(vol:0.2);
~t4_del <<> ~t4_2;


~t4_mix[0] = \mix -> {~t4_1.ar};
~t4_mix[1] = \mix -> {~t4_2.ar};
~t4_mix[2] = \mix -> {~t4_3.ar};
~t4_mix[3] = \mix -> {~t4_4.ar};


~t4_mix.play;
~t4_mix.stop;

(
~t4_rev = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 5, 0, 5);
	fx
}
)

~t4_rev.play(vol:0.4);
~t4_rev <<> ~t4_mix;
