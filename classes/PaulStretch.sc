PaulStretch {
    // Paulstretch for SuperCollider
    // Based on the Paul's Extreme Sound Stretch algorithm by Nasca Octavian PAUL
    // https://github.com/paulnasca/paulstretch_python/blob/master/paulstretch_steps.png
    //
    // By Jean-Philippe Drecourt
    // http://drecourt.com
    // April 2020
    //
    // Arguments:
    // out: output bus (stereo output)
    // bufnum: the sound buffer. Must be Mono. (Use 2 instances with Buffer.readChannel for stereo)
    // envBufnum: The grain envelope buffer created as follows:
    //// envBuf = Buffer.alloc(s, s.sampleRate, 1);
    //// envSignal = Signal.newClear(s.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
    //// envBuf.loadCollection(envSignal);
    // pan: Equal power panning, useful for stereo use.
    // stretch: stretch factor (modulatable)
    // window: the suggested grain size, will be resized to closest fft window size
    // amp: amplification
    var <key;
    var listenerfunc;

    *new {arg path;
        var key = ('n_' ++ UniqueID.next).asSymbol;
        ^super.new.prInit(key, path);
    }

    prInit {arg inKey, inPath;

        var envBuf, envSignal, buffer;
        var server = Server.default;
        var node;

        listenerfunc = {arg obj, prop, params; [obj, prop, params].postln;};
        node = Ndef(inKey, {

            var bufnum = \buf.kr(0);
            var envBufnum = \envbuf.kr(0);
            var pan = \pan.kr(0);
            var stretch = \stretch.kr(50);
            var window = \window.kr(0.25);
            var amp = \amp.kr(1);

            var trigPeriod, sig, chain, trig, pos, fftSize;
            // Calculating fft buffer size according to suggested window size
            fftSize = 2**floor(log2(window*SampleRate.ir));
            // Grain parameters
            // The grain is the exact length of the FFT window
            trigPeriod = fftSize/SampleRate.ir;
            trig = Impulse.ar(1/trigPeriod);
            pos = Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod/stretch));
            // Extraction of 2 consecutive grains
            // Both grains need to be treated together for superposition afterwards
            sig = [GrainBuf.ar(1, trig, trigPeriod, bufnum, 1, pos, envbufnum: envBufnum),
                GrainBuf.ar(1, trig, trigPeriod, bufnum, 1, pos + (trigPeriod/(2*stretch)), envbufnum: envBufnum)]*amp;
            // FFT magic
            sig = sig.collect({ |item, i|
                chain = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
                // PV_Diffuser is only active if its trigger is 1
                // And it needs to be reset for each grain to get the smooth envelope
                chain = PV_Diffuser(chain, 1 - trig);
                item = IFFT(chain, wintype: -1);
            });
            // Reapply the grain envelope because the FFT phase randomization removes it
            sig = sig*PlayBuf.ar(1, envBufnum, 1/(trigPeriod), loop:1);
            // Delay second grain by half a grain length for superposition
            sig[1] = DelayC.ar(sig[1], trigPeriod/2, trigPeriod/2);
            // Panned output
            //Out.ar(out, Pan2.ar(Mix.new(sig), pan));
            Splay.ar(sig.sum, \spread.kr(1), center:pan) * amp;
        });

        if (inPath.isKindOf(Buffer)) {
            buffer = inPath;
            if (buffer.numChannels > 1) {
                "buffer is 2 channels. only 1 channel buffers can be used".warn;
            };
            node.set(\buf, buffer.bufnum);
        }{
            Buffer.read(server, inPath, action:{arg buf;
                buffer = buf;
                node.set(\buf, buffer.bufnum);
                if (buffer.numChannels > 1) {
                    "buffer is 2 channels. only 1 will be used".warn;
                    Buffer.readChannel(server, inPath, channels:[0], action:{arg buf;
                        buffer = buf;
                        node.set(\buf, buffer.bufnum);
                    });
                }
            });
        };

        // The grain envelope
        envBuf = Buffer.alloc(server, server.sampleRate, 1);
        envSignal = Signal.newClear(server.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
        envBuf.loadCollection(envSignal);

        if (node.dependants.size == 0) {
            node.addDependant(listenerfunc);
        };
        if (this.dependants.size == 0) {
            this.addDependant(listenerfunc);
        };
        // wake sets up the node for audio
        node.wakeUp;
        node.set(\envbuf, envBuf.bufnum);

        ^node;
    }
}
