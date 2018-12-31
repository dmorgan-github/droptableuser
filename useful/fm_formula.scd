(

SynthDef(\fm1, {
	var sig;
	var	mod_ratio = 2.8,   // 689/500
	car_freq = 130,
	mod_index = car_freq * mod_ratio * Line.ar(5, 0.01, 5);
	sig = SinOsc.ar(car_freq + (SinOsc.ar(car_freq * mod_ratio) * mod_index));
	Out.ar(0, sig);

}).add;

)


Synth(\fm1)
