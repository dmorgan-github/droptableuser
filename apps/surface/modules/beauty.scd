(
~beautybuf = Buffer.alloc(s, s.sampleRate * 1, 1);

SynthDef(\beauty,
{
        arg delays = #[0.4, 0.7, 0.8, 0.9], pans = #[-1, -0.7, 0.6, 1], noiseamp = 0.03, hpf = #[20, 60],
		average = #[8000, 14000], srate = 44100, smooths = #[300, 400], lpf = #[13000, 15000];

        var phase, feedback, sig, local;
        local = LocalIn.ar(2);
        sig = WhiteNoise.ar(noiseamp);
        phase = DelTapWr.ar(~beautybuf, sig + local);
        feedback = DelTapRd.ar(~beautybuf, phase, delays);
        feedback = Pan2.ar(feedback[0], pans[0]) + Pan2.ar(feedback[1], pans[1]) + Pan2.ar(feedback[2], pans[2]) + Pan2.ar(feedback[3], pans[3]);
        feedback = HPF.ar(feedback, hpf);
        feedback = feedback * (0.02 / (Lag.ar(AverageOutput.ar(abs(feedback), Impulse.kr((average/srate).reciprocal)), smooths/srate).clip(0.0001, 1)));
        feedback = LPF.ar(feedback, lpf);
        LocalOut.ar(feedback);
        Out.ar(0, (feedback));
}
).add;

)

//run one by one:

a = Synth(\beauty); // sounds weird, why?
a.set(\delays, [0.2, 0.3, 0.4, 0.5] * 0.35); //THERE we go
a.set(\delays, [0.2, 0.3, 0.4, 0.5] * 0.15); //THERE we go
a.set(\lpf, [4300, 4000]);
a.set(\hpf, [300, 900]);
a.free;


"http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/Feedback-questions-converting-a-lloopp-maxmsp-patch-and-some-sc-code-in-progress-td7581807.html"




~beauty = NodeProxy.audio;

(
~beauty[0] = {

	/*
	var srate = 44100;

	var smooths = #[300, 400];

	var average = #[8000, 14000];

	//var in =Saw.ar([100,102]) * Decay2.ar(Impulse.ar(1));

	var in = WhiteNoise.ar(\noise.kr(0.1));// * Decay2.ar(Dust.ar(1));

	var fbNode = FbNode(2, 1.0);

	var sig = Mix.ar([
		fbNode.delay(\delay1.kr(0.1)),
		fbNode.delay(\delay2.kr(0.2)),
		fbNode.delay(\delay3.kr(0.3)),
		fbNode.delay(\delay4.kr(0.4))
	]);

	sig = (in + sig);
	//sig = HPF.ar(sig, 440);
	//sig = LPF.ar(sig, 1200);

	fbNode.write( (sig * \decay.kr(0.2)).tanh );

	sig.tanh;
	*/

	//var sig = Saw.ar([100,102]) * Decay2.ar(Impulse.ar(1));
	//var fb = FbC({arg fb; LPF.ar(fb, 1200)*0.8 + sig; }, 2.37 );
	//(sig + fb) * 0.1


	var sig = WhiteNoise.ar(0.1);
	var delay = DelayC.ar(sig, 1, SinOsc.ar(20).range(0.001, 0.1) );
	delay * 0.5;
}
)


~beauty.vol = 1
~beauty.play
~beauty.stop
~beauty.set(\delay1, 0.5)
~beauty.set(\delay2, 0.6)
~beauty.set(\delay3, 0.7)
~beauty.set(\delay4, 0.8)


(
Slider().action_({arg ctrl; ~beauty.set(\decay, ctrl.value)}).front;
Slider().action_({arg ctrl; ~beauty.set(\delay1, ctrl.value) }).front;
)



(
{
	var in = Saw.ar([100,102]) * Decay2.ar(Impulse.ar(1) );

	var fbNode = FbNode(2, 1.0);

	var sig = Mix.ar([
		fbNode.delay(\delay1.kr(0.1)),
		fbNode.delay(\delay2.kr(0.2)),
		fbNode.delay(\delay3.kr(0.3)),
		fbNode.delay(\delay4.kr(0.4))
	]);

	fbNode.write(in + (sig*0.1) );
	// if you want, you can use FbNode as a normal multi-tap delay, just by not adding in the
	// feedback signal here.

	sig;

}.play;
)





(
{
	var fbNode = FbNode(1);
	var signal = SinOsc.ar(100, fbNode * Line.kr(0,2,10) );
		// the FbNode is used to modulate the SinOsc's phase

	fbNode.write(signal);
	signal ! 2;
}.play;
)


(
{
	var in = WhiteNoise.ar*Line.kr(1,0,0.05);
	var n = 10;
	var fbNodes = {FbNode( 1, rrand(0.1,1.0) )}!n;
		// create n mono FbNodes, each with a different max delay time.

	var signals = n.collect {
		arg i;
		// the nodes are arranged in a circle, with each one getting some feedthough from
		// the nodes on either side.
		var signal = in + (fbNodes[i].delay*0.4)
			+ (fbNodes[(i+1)%n].delay*0.3)
			+ (fbNodes[(i-1)%n].delay*0.3);
		fbNodes[i].write(signal);
	};

	Splay.ar(signals);
}.play;
)

MultiSliderView().size_(4).thumbSize_(5).front


Server.default.options.blockSize/Server.default.sampleRate;




(
~granulator1[100] = \filter -> {arg in;

	//var sig = FbC({arg fb; fb * 0.6 + in});
	var sig, delay, delay2;
	sig = Disintegrator.ar(in * 0.1) + in;
	sig = sig * Decay2.ar(Impulse.ar(1));
	delay = FbC({arg fb; LPF.ar(fb, 880) * 0.6 + sig}, 2.38);//DelayC.ar(sig, 2.38, 2.38);
	delay2 = FbC({arg fb; LPF.ar(fb, 2000) * 0.7 + sig}, 3.5);//DelayC.ar(sig, 2.38, 2.38);
	sig + delay + delay2;
};
)






0.7 * 60 * 2