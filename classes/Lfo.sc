Lfo : Ndef {

  *new {|key|
      ^super.new(key);
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
}

PLfo {

  *sine {|dur=1, min=0, max=1|
      ^Pseg(Pseq([min, max], inf), Pseq([dur], inf), \sine)
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
