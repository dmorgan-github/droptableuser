SuperCollider drumsample generator
Nikolaus Gradwohl2018-02-10T10:08:46+01:00

I noticed that my Volca Sample in my homestudio din't quite get the attantion and love it deserved so I desided to create a new sample pack for it. I wanted some fresh electronic samples so I wrote some SuperCollider scripts to create random drum Samples. I created a script for bassdrum, snare, hihats, clap, crash, tom and a metallic 'ding' sound - which I named 'Ding' because I could not come up with a more clever name. Each of the script generates 64 samples. I then chose 100 and organized them into sound banks and uploaded them to my Volca Sample.

Samples 00 to 19 are bass drums, 20 to 29 are clap samples, 30 to 39 is a crash, 40 to 49 is 'ding', 50 to 69 is closed and open hihats, 70 to 89 are snares and 90 to 99 are my tom samples. I'm not 100% satisfied by the ordering yet maybe I move the snare samples after the bassdrums and the hihats to the end of the list - the current ordering is created mainly for alphabetical reasons :-) but I really like the organisation in banks of 10.

To simplify things further I also created 10 empty patterns - the first one places bd-00 on slot 1, bd-10 on slot 2, sn-70 on slot 3, sn-80 on slot 4, ...

the second pattern places bd-01 on slot 1, bd-11 on slot 2, sn-71 on slot 3, sn-81 on slot 4, ... and so on. This way I can switch between the drumkits pretty fast. Since I mainly use my volca sample as a midi device, I usually don't need the patterns for anything else.

click here to listen to a track I made using this samples

If you want to create your own set of samples here are the supercollider scripts I used with a short description. If you create something nice with them please share a link in the comments.

Bassdrum
For the Bassdrum I combined a short noise burst with a bandpass filter sweep and a Sinewave with a linear pitch envelope.

SynthDef.new("bd", {
    arg  n=0.8, nl = 0.02, start=110, end=1, l1=0.1, l2=0.3, exp=1.7;
    var boom;
    e = pow(Line.ar(0.9,0,l2),exp);

    boom = BBandPass.ar(WhiteNoise.ar(),freq:Line.ar(100,10,nl))*Line.ar(1,0,nl)*n+
    SinOsc.ar(Line.ar(start, end, l1))*e;
    Out.ar(0,[boom,boom])

}).add;

{
    64.do{
        Synth.new("bd", ["n":rrand(0.8,0),"nl",rrand(0.03,0), "start",rrand(100.0,50.0),"end",rrand(100,10), "l1", rrand(0.1,0), "l2", rrand(0.8,0.1),"exp", rrand(1,4)]);
        1.6.wait;
    }
}.fork()
Clap
For the clap sound I generate a filtered short noise burst with a plucky envelope and mixed ten of the plugs with random delays between them.

SynthDef.new("clap", {
    arg delay = #[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], rel=0.1, freq=600;

    var osc = Mix.arFill(10, { arg i;
        PinkNoise.ar()*0.3*EnvGen.ar(Env([0,0,1,0],[delay[i], 0.001, rel]), curve: \exp , doneAction: 0);
    });

    var snd =  BHiPass.ar(osc,freq);
    Out.ar(0,Pan2.ar(snd))
}).add;

x = Synth.new("clap", ["delay",Array.fill(15,{rrand(0.001,0.1)}), "rel", rrand(0.05,0.2), "freq", rrand(100,2000)]);

{
    64.do{
        x = Synth.new("clap", ["delay",Array.fill(15,{rrand(0.001,0.1)}), "rel", rrand(0.05,0.2), "freq", rrand(100,2000)]);

        1.6.wait
    }
}.fork
Crash
The base sound of the crash are 12 rectangular waves at random frequencies that are run through a bandpass filter and shaped by an envelope. I also added a short pinknoise burst in the beginning of the sample.

SynthDef.new("crash", {
    arg freq = #[1600,200,199,388,785, 2784, 100,177,1384,1730,1255,1160], rel=0.6, noiseRel=0.01, noiseLevel=0.7;

    var osc = Mix.arFill(12, { arg i;
        Pulse.ar(freq[i])*0.3;
    });
    var e = EnvGen.ar(Env.perc(0.01, rel));

    var noiseOsc = PinkNoise.ar();
    var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel))*noiseLevel;

    var snd =  noiseOsc * noiseEnv + BHiPass4.ar(osc,1000)*e;
    Out.ar(0,Pan2.ar(snd))
}).add;


x = Synth.new("crash")

{
    64.do{
        x = Synth.new("crash", ["freq",Array.fill(12,{rrand(3000,500)}), "rel", rrand(1,0.2), "noiseRel",rrand(0.1,0), "noiseLevel", rrand(0,0.4)]);
        1.6.wait
    }
}.fork
Ding
This is a metallic sound created by mixing 7 random tuned sine waves.

SynthDef.new("ding", {
    arg freq = #[1600,200,177,384,730,1255,60], rel=0.1, noiseRel=0.01, noiseLevel=0.7;

    var osc = Mix.arFill(7, { arg i;
        SinOsc.ar(freq[i])*0.3;
    });
    var e = EnvGen.ar(Env.perc(0.01, rel));

    var noiseOsc = PinkNoise.ar();
    var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel))*noiseLevel;

    var snd =  noiseOsc * noiseEnv + osc*e;
    Out.ar(0,Pan2.ar(snd))
}).add;

{
    64.do{
        x = Synth.new("ding", ["freq",Array.fill(7,{rrand(2000,60)}), "rel", rrand(1,0.05), "noiseRel",rrand(0.1,0), "noiseLevel", rrand(0,0.4)]);
        1.6.wait
    }
}.fork
HiHat
The hats are created using pinknoise that is run throug a bandpass and shaped by an envelop. This is the only script that generates two samples per run. The two samples use differnt decay times but otherwise the same filter and level settings, this way I can create matching open and closed hihat pairs.

SynthDef("hh", {
    arg noiseRel = 0.4, noiseLevel=0.7, ffreq=10000, q=0.2;
    var noiseOsc = BBandPass.ar(PinkNoise.ar(), ffreq, q);
    var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel));
    var snd = noiseOsc * noiseEnv * 1.4;
    Out.ar(0,Pan2.ar(snd, 0, 1));
}).add;
{
    64.do{
        var noiseLevel = rrand(1,0.1),noiseRel=rrand(0.2,0.01), ffreq=rrand(10000,1000), q= rrand(1,0.2);
        x = Synth.new("hh",["noiseLevel", noiseLevel, "noiseRel", noiseRel, "ffreq", ffreq, "q", q]);
        1.5.wait;
        x = Synth.new("hh",["noiseLevel", noiseLevel, "noiseRel", noiseRel+rrand(0.1,0.6), "ffreq", ffreq, "q", q]);
        1.5.wait;

    }
}.fork
Snare
For the snare I used a similar technique as with the bassdrum, a short noiseclick and a pitchmodulated sine wave for the body, but I pitched it higher and used longer decay times on the noise part, to make it sound more snare like

SynthDef("sn", {
    arg startPitch = 6000, endPitch=60, clickLevel=0.7, pitchRel = 0.11, noiseLevel=1, noiseRel= 0.3;
    var pitchEnv = EnvGen.ar(Env([startPitch,410,endPitch],[0.005,0.01], curve:\exp));
    var clickOsc = SinOsc.ar(pitchEnv);
    var clickEnv = EnvGen.ar(Env.perc(0.001, pitchRel))*clickLevel;
    var noiseOsc = PinkNoise.ar();
    var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel))*noiseLevel;
    var snd = clickOsc *clickEnv + noiseOsc * noiseEnv;
    Out.ar(0,Pan2.ar(snd, 0, 1));
}).add;

{
    64.do{
        x = Synth.new("sn",["endPitch", rrand(500,50), "clickLevel",rrand(1,0.1), "pitchRel",rrand(0.01,0.6), "noiseLevel",rrand(1,0.1),"noiseRel",rrand(0.6,0.01)]);
        1.5.wait;
    }
}.fork
Tom
For the toms I also used the noise and the pitch modulated sines but instead of going only down I also allowed upward pitch modulations and a wider range of allowed random values

SynthDef("tom", {
    arg startPitch = 6000, endPitch=60, clickLevel=0.7, pitchRel = 0.11, noiseLevel=1, noiseRel= 0.3;
    var pitchEnv = EnvGen.ar(Env.perc(0.01, pitchRel));

    var clickOsc = SinOsc.ar(pitchEnv*(startPitch-endPitch)+endPitch);
    var clickEnv = EnvGen.ar(Env.perc(0.001, pitchRel))*clickLevel;
    var noiseOsc = PinkNoise.ar();
    var noiseEnv = EnvGen.ar(Env.perc(0.01, noiseRel))*noiseLevel;
    var snd =  noiseOsc * noiseEnv +clickOsc *clickEnv;
    Out.ar(0,Pan2.ar(snd, 0, 1));
}).add;

{
    64.do{
x = Synth.new("tom",["startPitch", rrand(500,60),"endPitch", rrand(500,50), "clickLevel",rrand(1,0.5), "pitchRel",rrand(0.05,0.9), "noiseLevel",rrand(0.5,0.1),"noiseRel",rrand(0.1,0.06)]);
        1.5.wait;
    }
}.fork