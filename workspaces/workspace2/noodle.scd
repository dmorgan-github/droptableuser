

~one = ['a2', 'e2', 'a3', 'c3', 'e3', 'a4', 'b4', 'c4', 'e4' ].namecps;
~two = ['a2', 'e2', 'a3', 'c3', 'e3', 'c5', 'b5', 'f4', 'e4'].namecps;
~three = ['c2', 'g2', 'b3', 'c3', 'e3', 'g3', 'c5', 'e4', 'd4'].namecps;
~four = ['f2', 'c3', 'a3', 'c3', 'e3', 'f3', 'c5', 'f4', 'e4'].namecps;


~tri_poly = ProxySpace.new(s);
~tri_poly.quant = 1.0;

~tri_poly[\s1] = { ~tri.(freq:~one, func:{arg sig;sig.sum}) * ~tlinen.() };
(~tri_poly[\s1][2] = \set -> Pbind(

	\freq, Pseq([~one, ~two, ~three, ~four], inf).collect(`_),

	\delta, 1,
	\vdepth, 0.001,
	\lag, 0.0,
	\trig, 1,
	\atk, 0.01,
	\rel, 0.1,
	\sus, Pkey(\delta) * 0.5,
))
~tri_poly[\s1].play;
~tri_poly[\s1].stop;
~tri_poly[\s1].mold

///////////////////
// reverb
~tri_poly[\jpverb].clear
~tri_poly[\jpverb] = ~jpverb.(chans:~tri_poly[\s1].numChannels);
~tri_poly[\jpverb] <<> ~tri_poly[\s1];
~tri_poly[\jpverb].set(\wet, 0.5, \size, 10, \t60, 3)
~tri_poly[\jpverb].play;
~tri_poly[\jpverb].stop;
~tri_poly[\jpverb].vol = 0.3;

/////////////////
// fb delay
~tri_poly[\fb] = ~feedback.(chans:~tri_poly[\jpverb].numChannels);
~tri_poly[\fb] <<> ~tri_poly[\jpverb];
~tri_poly[\fb].set(\wet, 0.8, \decay, 0.7)
~tri_poly[\fb].play
~tri_poly[\fb].stop;
~tri_poly[\fb].vol = 0.5;


~bass = ProxySpace.new(s);
~bass.quant = 1.0;
~bass[\s1] = { ~saw.(freq:'A1'.namecps, func:{arg sig;sig!2}) * ~tperc.() };
~bass[\s1][2] = \set -> Pbind(\trig, 1, \degree, Pshuf([0,1,2,3], inf), \scale, Scale.minorPentatonic, \octave, 3, \rel, 0.4, \delta, 0.125, \lag, 0.0);
~bass[\s1].vol = 1;
~bass[\s1].play;
~bass[\s1].stop;

~bass[\varlag] = ~varlag.();
~bass[\varlag][2] = \set -> Pbind(\degree, Pshuf([0,1,2,3], inf), \scale, Scale.minorPentatonic, \octave, 6, \val, Pkey(\freq), \dur, 0.2)

~bass[\rlpf] = ~rlpf.(chans:~bass[\s1].numChannels);
~bass[\rlpf] <<> ~bass[\s1];
~bass[\rlpf].set(\rq, 0.2, \freq, ~bass[\varlag]);
//~bass[\rlpf][2] = nil\set -> Pbind(\degree, Pshuf([0,1,2,3], inf), \scale, Scale.minorPentatonic, \octave, 7)

~bass[\rlpf].play

App.record
s.stopRecording