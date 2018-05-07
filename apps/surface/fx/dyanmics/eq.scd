(
func: {arg in;

	var freqlo = \freqlo.kr.range(\freqlo_min.kr(30), \freqlo_max.kr(250)).lag(0.1);
	var freqlors = \freqlors.kr.range(\freqlors_min.kr(0), \freqlors_max.kr(1)).lag(0.1);
	var freqlodb = \freqlodb.kr.range(\freqlodb_min.kr(0), \freqlodb_max.kr(1)).lag(0.1).ampdb;

	var freq1 = \freq1.kr.range(\freq1_min.kr(100), \freq1_max.kr(1000)).lag(0.1);
	var freq1rs = \freq1rs.kr.range(\freq1rs_min.kr(0), \freq1rs_max.kr(1)).lag(0.1);
	var freq1db = \freq1db.kr.range(\freq1db_min.kr(0), \freq1db_max.kr(1)).lag(0.1).ampdb;

	var freq2 = \freq2.kr.range(\freq2_min.kr(250), \freq2_max.kr(3500)).lag(0.1);
	var freq2rs = \freq2rs.kr.range(\freq2rs_min.kr(0), \freq2rs_max.kr(1)).lag(0.1);
	var freq2db = \freq2db.kr.range(\freq2db_min.kr(0), \freq2db_max.kr(1)).lag(0.1).ampdb;

	var freq3 = \freq3.kr.range(\freq3_min.kr(1000), \freq3_max.kr(6000)).lag(0.1);
	var freq3rs = \freq3rs.kr.range(\freq3rs_min.kr(0), \freq3rs_max.kr(1)).lag(0.1);
	var freq3db = \freq3db.kr.range(\freq3db_min.kr(0), \freq3db_max.kr(1)).lag(0.1).ampdb;

	var freqhi = \freqhi.kr.range(\freqhi_min.kr(3500), \freqhi_max.kr(20000)).lag(0.1);
	var freqhirs = \freqhirs.kr.range(\freqhirs_min.kr(0), \freqhirs_max.kr(1)).lag(0.1);
	var freqhidb = \freqhidb.kr.range(\freqhidb_min.kr(0), \freqhidb_max.kr(1)).lag(0.1).ampdb;

	in = BLowShelf.ar(in, freqlo, freqlors, freqlodb);
	in = BPeakEQ.ar(in, freq1, freq1rs, freq1db);
	in = BPeakEQ.ar(in, freq2, freq2rs, freq2db);
	in = BPeakEQ.ar(in, freq3, freq3rs, freq3db);
	in = BHiShelf.ar(in, freqhi, freqhirs, freqhidb);
	LeakDC.ar( RemoveBadValues.ar(in) );
},
specs: (
	freqlo: [30, 250, \lin, 0, 100],
	freqlors: [0, 1, \lin, 0, 1],
	freqlodb: [0, 1, \lin, 0, 1],

	freq1: [100, 1000, \lin, 0, 250],
	freq1rs: [0, 1, \lin, 0, 1],
	freq1db: [0, 1, \lin, 0, 1],

	freq2: [250, 3500, \lin, 0, 1000],
	freq2rs: [0, 1, \lin, 0, 1],
	freq2db: [0, 1, \lin, 0, 1],

	freq3: [1000, 6000, \lin, 0, 3500],
	freq3rs: [0, 1, \lin, 0, 1],
	freq3db: [0, 1, \lin, 0, 1],

	freqhi: [3500, 20000, \lin, 6000],
	freqhirs: [0, 1, \lin, 0, 1],
	freqhidb: [0, 1, \lin, 0, 1]
)

)