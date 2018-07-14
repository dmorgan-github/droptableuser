
~n1 = ProxySpace.new(s);

~bufs[\met] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/sounds/metalic.wav");

~n1[\snd].mold

(~n1[\snd][0] = {

	var buf = ~bufs[\met];
	var rate = \rate.kr(0.5);
	var start = \start.kr(0);
	var curve = \curve.kr(0);

	var numFrames = BufFrames.kr(buf);
	var startFrame = start * numFrames;
	var bufDur = BufDur.kr(buf);

	var phase = Env.circle([startFrame, numFrames], [bufDur * rate.reciprocal], curve).ar();
	var sig = BufRd.ar(1, buf, phase, loop:0, interpolation: 4);
	//var env = Env.linen(0, dur, 0).kr(doneAction:0);
	sig = sig;// * env;

	sig = sig * Pan2.ar(sig, \pan.kr(0)) * \amp.kr(1);

	sig;

});


(~n1[\snd].filter(8, {arg in;

	//var sig = PitchShift.ar(in, 0.1, 2, 0.1, 0.1);
	//JPverb.ar(sig);

	var chain;
	chain = FFT(LocalBuf(2048), in.sum);
	//chain = PV_BinScramble(chain, MouseX.kr , 0.1, MouseY.kr > 0.5 );
	//chain = PV_MagNoise(chain);
	//chain = PV_MagBelow(chain, 10);
	//chain = PV_MagAbove(chain, 10);
	//chain = PV_PhaseShift(chain, LFNoise2.kr(1, 180, 180));
	//chain = PV_MagSmear(chain, MouseX.kr(0, 100));
	chain = PV_RandComb(chain, 0.95, Impulse.kr(0.4));
	//chain = PV_BinShift(chain, 1, MouseX.kr(-128, 128) );
	chain = IFFT(chain);
	//in;

	//JPverb.ar(chain);
	chain;

}).set(\wet8, 1);
)

(~n1[\snd].filter(10, {arg in;

	var chain;
	chain = FFT(LocalBuf(2048), in.sum);
	chain = PV_BinScramble(chain, MouseX.kr, 0.1, MouseY.kr > 0.5 );
	chain = IFFT(chain);
	chain;

}).set(\wet10, 1))

(~n1[\snd].filter(20, {arg in;
	in = PitchShift.ar(in, 0.1, pitchRatio:0.5, pitchDispersion:0.1, timeDispersion:0.1);
	JPverb.ar(in);
}).set(\wet20, 0.6))

~n1[\snd].play
~n1[\snd].stop

App.recordWorkspace("ws5");
s.stopRecording



