~fs = ProxySpace.new;
~fs.clock = TempoClock.default.tempo_(60/60);
~fs.quant = 1.0;

~fs_bufs = ();
~fs_bufs[\b] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc2/cy/fingercymbals.wav");


~fs[\n] = ~smplr.(buf:~fs_bufs[\b]);
~fs[\n].set(\rate, 1, \start, 0.5, \end, 0.6);
~fs[\n][2] = \set -> Pbind(\trig, 1, \delta, 4, \amp, 1);
~fs[\n].stop
~fs[\n].play


~fs[\mix].play;
~fs[\mix][0] = ~fs[\n];
~fs[\mix][16] = \filter -> {arg in; FbC({arg fb; fb * 0.6 + in }, 0.375)};
~fs[\mix][18] = \filter -> {arg in; JPverb.ar(in, t60:[1,3], size:[3,5]) };
~fs[\mix].set(\wet16, 0.6, \wet18, 0.2);


Slew