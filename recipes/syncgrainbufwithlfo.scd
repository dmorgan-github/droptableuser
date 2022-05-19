
//https://scsynth.org/t/syncing-grainbuf-with-an-lfo-that-modulates-its-playback-rate/5837

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
SynthDef(\bufstretch, {|buf|
    var bufdur, maxrate, minrate, lfo_rate, phasor_avg,
    reset_trig, inverse_trig, integral, integrated_mean,
    phasor_rate, phasor_rate_inv, phasor, graintrig, graindur, sig;
    bufdur = BufDur.ir(buf);
    maxrate = \maxrate.ar(4.0);
    minrate = \minrate.ar(0.1);
    reset_trig = Changed.ar(maxrate) + Changed.ar(minrate) / 2;
    inverse_trig = reset_trig <= 0;
    lfo_rate = LocalIn.ar(1).poll(label: "calculated lfo rate");
    phasor_rate = SinOsc.ar(lfo_rate, \phase.kr(pi/2)).range(minrate, maxrate);
    phasor_rate_inv = phasor_rate.linlin(minrate, maxrate, maxrate, minrate);
    phasor_avg = (phasor_rate + phasor_rate_inv) / 2;
    integral = FOS.ar(phasor_avg, inverse_trig, DC.ar(0), inverse_trig);
    integrated_mean = integral / Sweep.ar(reset_trig, SampleRate.ir);
    LocalOut.ar(integrated_mean / bufdur);
    phasor = Sweep.ar(1, phasor_rate / bufdur);
    graintrig = Impulse.ar(\trigrate.kr(20));
    graindur = \trigrate.kr.reciprocal * \overlap.kr(2);
    sig = GrainBuf.ar(2, graintrig, graindur, buf, BufRateScale.ir(buf), phasor);
    Out.ar(0, sig);
}).add;
)

x = Synth(\bufstretch, [buf: b]);
x.set(\maxrate, 6);
x.set(\minrate, 0.6);
x.free