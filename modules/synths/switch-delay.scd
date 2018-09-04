b = Buffer.read(s, Platform.resourceDir ++  "/sounds/a11wlk01.wav");
(
SynthDef('help-switchdelay-2', { arg out=0, bufnum, delaytime;
    Out.ar(out,
        Pan2.ar(
            SwitchDelay.ar(
                PlayBuf.ar(numChannels: 1, bufnum: bufnum, loop: 0) * 0.5,
                wetlevel: 0.6,
                delaytime: Select.kr(
                    Stepper.kr(Impulse.kr(0.25), 0, 0, 5),
                    #[ 0.02, 0.1, 0.725, 0.25, 0.5, 1 ]
                )
            )
        )
    );
}).add;
)

x = Synth('help-switchdelay-2', [\bufnum, b, \loop, 0, \delaytime, 2.0]);
x.free;

