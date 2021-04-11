G : Device {

    deviceInit {
        this.prBuild;
    }

    prBuild {

        this.put(0, {

            var updateFreq = 15;
            var freq = \freq.ar(20);
            var buf = \buf.kr(0);
            var grainenv = \grainenv.kr(-1);
            var pitch = \pitch.kr(1);
            var replyid = \bufposreplyid.kr(-1);
            var graindur = \graindur.kr(0.1);

            var density = {
                var sync = \sync.kr(1);
                Select.ar(sync, [Dust.ar(freq), Impulse.ar(freq)]);
            }.();

            var phase = {
                var speed = \pb.kr(1);
                var posrand = \posrand.kr(0);
                var start = \startPos.kr(0) * BufFrames.kr(buf);
                var end = \endPos.kr(1) * BufFrames.kr(buf);
                var phase = Phasor.ar(0, speed * BufRateScale.kr(buf), start, end);
                phase = phase + LFNoise1.kr(100).bipolar(posrand * SampleRate.ir);
                phase = phase/BufSamples.kr(buf);
                phase
            }.();

            var pan = {
                var pan = \pan.kr(0);
                var panHz = \panHz.kr(0.1);
                var panRand = \panRand.kr(0);
                pan + LFNoise1.kr(panHz).bipolar(panRand);
            }.();

            var grainAmp = {
                var amp = \grainamp.kr(1);
                var ampHz = \ampHz.kr(0.1);
                var ampRand = \ampRand.kr(0);
                amp + LFNoise1.kr(ampHz).bipolar(ampRand);
            }.();

            var sig = GrainBufJ.ar(
                numChannels:2,
                trigger: density,
                dur: graindur,
                sndbuf: buf,
                rate: pitch,
                pos: phase,
                interp: 2,
                grainAmp: grainAmp,
                pan: pan,
                envbufnum: grainenv
            );

            sig = sig * \amp.kr(0.3) * AmpCompA.kr(freq) * \vel.kr(1);
            SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase * BufFrames.kr(buf)], replyid);
            sig;
        });

        this.wakeUp;
	}

    view {
        ^U(\buf, this)
    }
}