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


SynthDef(\fm, {
		arg freq=500, mRatio=1, cRatio=1,
		index=1, iScale=5, cAtk=4, cRel=(-4),
		amp=0.2, atk=0.01, rel=3, pan=0,
		out=0, fx=0, fxsend=(-25);
		var car, mod, env, iEnv;

		//index of modulation
		iEnv = EnvGen.kr(
			Env(
				[index, index*iScale, index],
				[atk, rel],
				[cAtk, cRel]
			)
		);

		//amplitude envelope
		env = EnvGen.kr(Env.perc(atk,rel,curve:[cAtk,cRel]),doneAction:2);

		//modulator/carrier
		mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * iEnv);
		car = SinOsc.ar(freq * cRatio + mod) * env * amp;

		car = Pan2.ar(car, pan);

		//direct out/reverb send
		Out.ar(out, car);
		Out.ar(fx, car * fxsend.dbamp);
	}).add;


Hi List,

I was just looking at the implementation for PMOsc:

*ar { arg carfreq,modfreq,pmindex=0.0,modphase=0.0,mul=1.0,add=0.0;
		^SinOsc.ar(carfreq, SinOsc.ar(modfreq, modphase, pmindex),mul,add)
	}

and noticed that there's no operation that wraps the modulator within +-8pi as instructed in the SinOsc help file. This omission produces results that are outside the boundaries of "classic" FM/PM synthesis if the modulation index exceeds 8pi, for example:

s.boot;

//classic FM implementation with no direct phase manipulation
{SinOsc.ar(500 + SinOsc.ar(4, mul:4*40)) * 0.2!2}.play;

//PMOsc seems to clip the modulator signal between +-8pi resulting in a pitch "staircasing" effect
{PMOsc.ar(500, 4, 40) * 0.2!2}.play;

//I would expect PMOsc to produce this sound instead
{SinOsc.ar(500, SinOsc.ar(4, mul:40).mod(2pi)) * 0.2!2}.play;

Is this accidental or intentional?
