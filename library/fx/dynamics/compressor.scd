(
synth: {|in|

    /*
    var sig = in;
    var ratio = \compressratio.kr(4, spec:ControlSpec(1, 40, \lin, 0, 4, "compress"));
    var thresh = \compressthresh.kr(0, spec:ControlSpec(-80, 0, \lin, 0, 0, "compress"));
    var atk = \compressatk.kr(0.1, spec:ControlSpec(0.001, 10, \lin, 0, 0.1, "compress"));
    var rel = \compressrel.kr(0.1, spec:ControlSpec(0.001, 10, \lin, 0, 0.1, "compress"));
    var makeup = \compressmakeup.kr(0.5, spec:ControlSpec(0, 80, \lin, 0, 0.5, "compress"));
    var automakeup = \compressautomakeup.kr(1, spec:ControlSpec(0, 1, \lin, 1, 1, "compress"));
    */

    /*
    sig = DCompressor.ar(sig,
        ratio:ratio,
        threshold:thresh,
        attack:atk,
        release:rel,
        makeup:makeup,
        automakeup:automakeup
    );
    */

    /*
    # 1882 SC4
> k: RMS/peak (0 to 1)
> k: Attack time (ms) (1.5 to 400)
> k: Release time (ms) (2 to 800)
> k: Threshold level (dB) (-30 to 0)
> k: Ratio (1:n) (1 to 20)
> k: Knee radius (dB) (1 to 10)
> k: Makeup gain (dB) (0 to 24)
< k: Amplitude (dB) (-40 to 12)
< k: Gain reduction (dB) (-24 to 0)
> a: Left input
> a: Right input
< a: Left output
< a: Right output
    */

/*
    sig = SoftKneeCompressor.ar(
        in,
        thresh: thresh,
        ratio: ratio,
        knee: 6,
        attack: atk,
        release: rel,
        makeUp: 0,
        rms: 0
    );
    */

    var sig;
    var attack = \compress_atk.kr(0.01, spec:ControlSpec(0.0000001,0.1, \exp, units:"compress"));
    var release = \compress_rel.kr(0.1, spec:ControlSpec(0.0000001,0.4, \exp, units:"compress"));
	var dry, drywet, t, o, r, c, e, lookahead;
	var kneelag;
	var bias;

    t = \compress_thresh.kr(-6, spec:ControlSpec(0,-120, units:"compress"));

	dry = in;

    in = dry * \compress_trim.kr(0, spec:ControlSpec(0, 60, units:"compress")).dbamp;

	e = in.mean;

    e = HPF.ar( e, \compress_hpf.kr(50, spec:ControlSpec(10, 1000, units:"compress")) );

	e = EnvDetect.ar(e, attack, release);
	// e = e.abs.lagud(attack, release);

	// how much we are over by
	o = e.ampdb.excess(t);

	// scale the excess value by ratio
    r = \compress_ratio.kr(4, spec:ControlSpec(1,20, \exp, units:"compress"));
	c = ( max(o, 0.0) ) * (r.reciprocal - 1);

    kneelag = attack * \compress_knee.kr(0.0, spec:ControlSpec(0.0, 10, units:"compress"));

	c = c.lag( kneelag );
	c = c.dbamp;

    lookahead = \compress_lookahead.kr(0, spec:ControlSpec(0.0, 1, units:"compress"));
	in = DelayC.ar( in, 0.5, ( attack + release + kneelag * lookahead).lag(0.4) ); // lookahead
	in = in * c;
    in = in	* \compress_gain.kr(0, spec:ControlSpec(0,60, units:"compress")).dbamp;
    bias = K2A.ar(\compress_bias.kr(0.0, spec:ControlSpec(0.0, 0.5, units:"compress")));

    in = Select.ar(
        \compress_saturate.kr(1, spec:ControlSpec(0, 1, \lin, 1, units:"compress")),
        [in, (in + bias).softclip - bias]
    );
	in = LeakDC.ar(in);

    drywet = \compress_mix.kr(1, spec:ControlSpec(0,1, \lin, 0, 1, units:"compress"));

	sig = Mix([
		in * drywet,
		DelayC.ar( dry * (1 - drywet), 0.5, ( attack + release + kneelag * lookahead).lag(0.4) )
	]);

    sig;
},
credits: "https://github.com/alikthename/Musical-Design-in-Supercollider/blob/master/16_compression.sc"
)
