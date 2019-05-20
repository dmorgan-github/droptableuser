(
Fdef(\delay, {arg maxdelay=1;
	{arg in;
		in = LPF.ar(HPF.ar(in, \delhi.kr(20)), \dello.kr(20000));
		FbC({arg fb; fb * \fb.kr(0.3) + in;}, maxdelay, \beatdur.kr(1) * [\delL.kr(3/4), \delR.kr(5/8)]);
	};
});

Fdef(\reverb, {
	{arg in;
		in = LPF.ar(HPF.ar(in, \revhi.kr(20)), \revlo.kr(20000));
		JPverb.ar(in, \t60.kr(1), 0, \size.kr(1));
	}
});
)