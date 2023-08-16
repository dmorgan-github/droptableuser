
/*
Lfo : Ndef {

    *new {|key, source|
        ^super.new(key, source).prInit;
     }

    sine {|freq=1, min=0, max=1|
        this[0] = { SinOsc.kr(\freq.kr(freq)).range(\min.kr(min), \max.kr(max)) };
        this.set(\freq, freq, \min, min, \max, max);
        ^this;
    }

    tri {|freq=1, min=0, max=1|
        this[0] = { LFTri.kr(\freq.kr(freq)).range(\min.kr(min), \max.kr(max)) };
        this.set(\freq, freq, \min, min, \max, max);
        ^this
    }

    rampup {|freq=1, min=0, max=1|
        this[0] = { LFSaw.kr(\freq.kr(freq)).range(\min.kr(min), \max.kr(max)) };
        this.set(\freq, freq, \min, min, \max, max);
        ^this
    }

    rampdown {|freq=1, min=0, max=1|
        this[0] = { LFSaw.kr(\freq.kr(freq).neg).range(\min.kr(min), \max.kr(max)) };
        this.set(\freq, freq, \min, min, \max, max);
        ^this
    }

    func {|val|
        this[0] = val;
        ^this
    }

    curves {|levels, times, curve, min=0, max=1|
        this[0] = {
            var dur = times.sum;
            var env = Env(levels, times, curve);
            var index = LFSaw.ar(dur.reciprocal, iphase:1).range(0, dur);
            // DemandEnvGen??
            IEnvGen.ar(env, index).linlin(-1, 1, min, max)
        };
        this.set(\min, min, \max, max)
    }

    curves2 {|env, min=0, max=1|
        this[0] = {
            var index;
            var dur = env.times.sum * \timescale.kr(1);
            index = LFSaw.ar(dur.reciprocal, iphase:1).range(0, dur);
            // DemandEnvGen??
            IEnvGen.ar(env, index).linlin(-1, 1, \min.kr(min), \max.kr(max))
        };
        this.set(\min, min, \max, max)
    }

    curves3 {|signal|
        /*
        ~sf = SoundFile.openRead("/Users/david/Documents/supercollider/resources/AKWF/AKWF_0005/AKWF_0401.wav")
        ~data = Signal.newClear(~sf.numFrames)
        ~sf.readData(~data)
        ~data = ~data.resamp1(128)
        ~data.plot
        ~env = Env(~data, {1/127}.dup(127), 0)
        */
    }

    prInit {
        this.quant = 1.0;
        ^this;
    }
}

PLfo {

  *sine {|dur=1, min=0, max=1, phase=0|
      //^Pseg(Pseq([min, max], inf), Pseq([dur], inf), \sine)
      var num = 64;
      ^Pseg(Signal.sineFill(num, [1], [phase * pi]).asArray.pseq, [1/num].pseq * dur).linlin(-1, 1, min, max);
  }

  *tri {|dur=1, min=0, max=1|
      ^Pseg(Pseq([min, max], inf), Pseq([dur], inf), \lin)
  }

  *rampup {|dur=1, min=0, max=1|
      ^Pseg(Pseq([min, max], inf), Pseq([dur, 0], inf), \lin)
  }

  *rampdown {|dur=1, min=0, max=1|
      ^Pseg(Pseq([max, min], inf), Pseq([dur, 0], inf), \lin)
  }
}
