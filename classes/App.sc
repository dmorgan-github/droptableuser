App : IdentityDictionary {

	var < bufs;

	classvar <>all;

	*initClass {
		all = IdentityDictionary.new;
	}

	*new {arg key, server = Server.default;

		var res = all.at(key);

		if (res.isNil) {
			res = super.new(know:true).prInit(key, server);
		};

		^res;
	}

	*makeSynth {arg key, func, type = \pan, env = \gate;

		if (env == \gate) {

			SynthDef(key.asSymbol, {arg amp = 0.1, out = 0, pan = 0, gate = 1;
				var sig = SynthDef.wrap(func);
				sig = LeakDC.ar(sig) * amp;
				EnvGate.new(gate: gate);

				if (type == \pan) {
					OffsetOut.ar(out, Pan2.ar(sig, pan));
				} {
					OffsetOut.ar(out, Splay.ar(sig));
				};
			}).add;

		} {

			SynthDef(key.asSymbol, {arg amp = 0.1, out = 0, pan = 0;
				var sig = SynthDef.wrap(func);
				sig = LeakDC.ar(sig) * amp;
				DetectSilence.ar(sig, doneAction:2);

				if (type == \pan) {
					OffsetOut.ar(out, Pan2.ar(sig, pan));
				} {
					OffsetOut.ar(out, Splay.ar(sig));
				};
			}).add;
		};

	}

	*makeRetrigEnv {arg key, levels, times, curves, gate, releaseNode = nil, timeScale = 1, levelScale = 1;

		var num = 1e-6;
		var timeScaleKey = (key ++ 'timeScale').asSymbol;
		var levelScaleKey = (key ++ 'levelScale').asSymbol;
		var gateCtrl = {

			var rtn = gate;
			if (rtn.isNil) {
				var name = (key ++ 'gate').asSymbol;
				rtn = NamedControl.kr(name, 1);
			};
			rtn;

		}.value;

		levels = [levels[0]] ++ levels.collect({arg val, i;
			var num = i + 1;
			var name = (key ++ 'level' ++ num).asSymbol;
			NamedControl.kr(name, val);
		});

		times = [num] ++ times.collect({arg val, i;
			var num = i + 1;
			var name = (key ++ 'time' ++ num).asSymbol;
			NamedControl.kr(name, val);
		});

		curves = [curves[0]] ++ curves.collect({arg val, i;
			var num = i + 1;
			var name = (key ++ 'curve' ++ num).asSymbol;
			NamedControl.kr(name, val);
		});

		^EnvGen.kr(Env(levels, times, curves, releaseNode),
			gate: gateCtrl,
			levelScale: NamedControl.kr(levelScaleKey, levelScale),
			timeScale: NamedControl.kr(timeScaleKey, timeScale) );
	}

	*makeRetrigAmpEnv {arg atk, sus, rel, curve1, curve2, gate, releaseNode = nil;

		var num = 1e-6;

		var key = \e;

		var levels, times, curves;

		var gateCtrl = {
			var rtn = gate;
			if (rtn.isNil) {
				var name = (key ++ "gate").asSymbol;
				rtn = NamedControl.kr(name, 1);
			};
			rtn;

		}.value;

		levels = [0,0,1,0.7,0];
		times = [num, \atk.kr(atk), \sus.kr(sus), \rel.kr(rel)];
		curves = [0, \ecurve1.kr(curve1), 0, \ecurve2.kr(curve2)];

		^EnvGen.ar(Env(levels, times, curves), gate: gateCtrl, timeScale: NamedControl.kr(\dur, 1) );
	}

	*makeFreq {

		var lag = \lag.kr(0.0);
		var freq = \freq.kr(440).lag(lag);
		var dtune = \dtune.kr(0.1);
		^freq + [0, dtune];
	}

	prInit{arg prKey, server;

		bufs = BufEnvir(server);
		all.put(prKey, this);
		^this;
	}
}