G : D {

    deviceInit {
        this.prBuild;
    }

    prBuild {

        this.put(0, {

            var updateFreq = 15;
            var replyid = \bufposreplyid.kr(-1);
            var buf = \buf.kr(0);
            var freq = \freq.ar(20);
            var rate = \rate.ar(1);
            var overlap = \overlap.ar(2);
            var sig, env;
            var bufFrames = BufFrames.ir(buf);
            var trig, phase, dur;

            var freqLfo = {
                var freqLfoHz = \freqLfoHz.kr(0);
                var freqLfoDepth = \freqLfoDepth.kr(0);
                SinOsc.ar(freqLfoHz, Rand(0.0,2pi)) * freqLfoDepth;
            };

            var rateLfo = {
                var rateLfoHz = \rateLfoHz.kr(0);
                var rateLfoDepth = \rateLfoDepth.kr(0);
                SinOsc.ar(rateLfoHz, Rand(0.0,2pi)) * rateLfoDepth;
            };

            var grainRate = {
                var pulse = Impulse.ar(freq.lag(0.05));
                var dust = Dust.ar(freq.lag(0.05));
                var async = \async.kr(0);
                var trig = SelectX.ar(async, [pulse, dust]);
                trig;
            };

            var phasor = {

                var speedLfoHz = \speedLfoHz.kr(0);
                var speedLfoDepth = \speedLfoDepth.kr(0);
                var speedLfo = { SinOsc.ar(speedLfoHz, Rand(0.0,2pi)) * speedLfoDepth; };

                var startLfoHz = \startLfoHz.kr(0);
                var startLfoDepth = \startLfoDepth.kr(0);
                var startLfo = { SinOsc.ar(startLfoHz, Rand(0.0,2pi)) * startLfoDepth; };

                var endLfoHz = \endLfoHz.kr(0);
                var endLfoDepth = \endLfoDepth.kr(0);
                var endLfo = { SinOsc.ar(endLfoHz, Rand(0.0,2pi)) * endLfoDepth; };

                var speed = \speed.ar(1) + speedLfo.dup;
                var start = \startPos.kr(0) + startLfo.dup;
                var end = \endPos.kr(1) + endLfo.dup;

                Phasor.ar(
                    trig: 0.0,
                    rate: speed * BufRateScale.kr(buf),
                    start: start * bufFrames,
                    end: end * bufFrames,
                    resetPos: 0.0
                );
            };

            var grainDur = {
                var default = freq.reciprocal * overlap;

                var grainDurLfo = {
                    var grainDurLfoHz = \grainDurLfoHz.kr(0);
                    var grainDurLfoDepth = \grainDurLfoDepth.kr(0);
                    SinOsc.ar(grainDurLfoHz, Rand(0.0,2pi)) * grainDurLfoDepth;
                };
                var dur = \grainDur.kr(0) + grainDurLfo.dup;
                var which = dur > 0;
                Select.kr(which, [default, dur]).max(0);
            };

            var resLfo = {
                var resLfoHz = \resLfoHz.kr(0);
                var resLfloDepth = \resLfoDepth.kr(0);
                SinOsc.ar(resLfoHz) * resLfloDepth;
            };

            var filter = {|sig|
                var res = \res.kr(0) + resLfo.();
                var cutoff = \cutoff.kr(0).lag(0.1);
                var cutoffLfoHz = \cutoffLfoHz.kr(1/8);
                var cutoffLfloDepth = \cutoffLfoDepth.kr(0).linlin(0, 1, 1, 2);
                var lfo = SinOsc.ar(cutoffLfoHz).range(cutoffLfloDepth.reciprocal, cutoffLfloDepth);
                var which = cutoff > 0;
                var ffreq = (cutoff * lfo).clip(20, 20000);
                var moog = BMoog.ar(sig, ffreq, res.clip(0, 1));
                SelectX.ar(which, [sig, moog]);
            };

            var prob = \prob.kr(1);

            freq = freq + freqLfo.dup;
            rate = rate + rateLfo.dup;
            trig = grainRate.();
            phase = phasor.();
            dur = grainDur.();

            sig = GrainBuf.ar(
                numChannels: 1,
                trigger: CoinGate.ar(prob, trig),
                dur: dur,
                sndbuf: buf,
                rate: rate,
                pos: phase / bufFrames,
                interp: 2,
                pan: 0,
                envbufnum: -1,
                maxGrains: 512,
            );

            sig = LeakDC.ar(sig);
            sig = sig * \amp.kr(-10.dbamp);
            sig = filter.(sig);
            sig = LPF.ar(HPF.ar(sig, \hpf.kr(20)), \lpf.kr(2000));
            SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);
            sig;
        });

        this.wakeUp;
	}

    view {
        ^U(\buf, this)
    }
}