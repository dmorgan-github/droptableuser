(

/*
frpresets = [// x_ = cannot delete or modify
            'x_flat', [[100, 0, 1], [250, 0, 1], [1000, 0, 1], [3500, 0, 1],
                [6000, 0, 1]],
            'x_loudness', [[78.0, 7.5, 0.65], [250, 0, 1], [890.0, -9.5, 3.55],
                [2800.0, 3.5, 1.54], [7400.0, 7.0, 1.0]],
            'x_telephone', [[600.0, -22.0, 0.7], [250, 0, 1], [1200.0, -2.0, 0.5],
                [1800.0, 1.0, 0.5], [4000.0, -22.0, 0.7]]
        ];
*/


func: {arg in;

	var sig = in;

	var ls_freq = \ls_freq.kr(0).lag(0.1);
	var ls_rs = \ls_rs.kr(1).lag(0.1);
	var ls_db = \ls_db.kr(0).lag(0.1);

	var lo_freq = \lo_freq.kr(100).lag(0.1);
	var lo_rq = \lo_rq.kr(1).lag(0.1);
	var lo_db = \lo_db.kr(0).lag(0.1);

	var mid_freq = \mid_freq.kr(1000).lag(0.1);
	var mid_rq = \mid_rq.kr(1).lag(0.1);
	var mid_db = \mid_db.kr(0).lag(0.1);

	var hi_freq = \hi_freq.kr(10000).lag(0.1);
	var hi_rq = \hi_rq.kr(1).lag(0.1);
	var hi_db = \hi_db.kr(0).lag(0.1);

	var hs_freq = \hs_freq.kr(20000).lag(0.1);
	var hs_rs = \hs_rs.kr(1).lag(0.1);
	var hs_db = \hs_db.kr(0).lag(0.1);

	sig = BLowShelf.ar(sig, ls_freq, ls_rs,ls_db);
	sig = BPeakEQ.ar(sig, lo_freq, lo_rq, lo_db);
	sig = BPeakEQ.ar(sig, mid_freq, mid_rq, mid_db);
	sig = BPeakEQ.ar(sig, hi_freq, hi_rq, hi_db);
	sig = BHiShelf.ar(sig, hs_freq, hs_rs, hs_db);
	sig = RemoveBadValues.ar(sig);

	sig;
},

specs: (
	ls_freq: [0,20000,\lin,0,0],
	ls_rs: [0,1,\lin,0,1],
	ls_db: [-18,18,\lin,0,0],

	lo_freq: [0,20000,\lin,0,100],
	lo_rq: [0,1,\lin,0,1],
	lo_db: [-18,18,\lin,0,0],

	mid_freq: [0,20000,\lin,0,1000],
	mid_rq: [0,1,\lin,0,1],
	mid_db: [-18,18,\lin,0,0],

	hi_freq: [0,20000,\lin,0, 10000],
	hi_rq: [0,1,\lin,0,1],
	hi_db: [-18,18,\lin,0,0],

	hs_freq: [0,20000,\lin,0,20000],
	hs_rs: [0,1,\lin,0,1],
	hs_db: [-18,18,\lin,0,0]
)
)
