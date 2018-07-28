(
p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
b = Buffer.read(s, p);
~ms = 2000; // delay length in ms
~frames = ~ms/1000*s.sampleRate;
d = Buffer.alloc(s, ~frames);
)

(
d.zero;

y = {
	arg rate = 1, fb = 0.95;
    var in, delout, index;
    in = BufRd.ar(1,b,Phasor.ar(0, 1, 0, BufFrames.ir(b)),0,1);
	index = Phasor.ar(0, rate, 0, ~frames);
	in = fb * BufRd.ar(1,d,index) + in;
	IBufWr.ar(in, d, index, 1, 0);
	in!2;
}.play;

)

y.set(\rate, 2)
y.set(\rate, 0.5)
y.set(\rate, 1, \fb, 0.99)