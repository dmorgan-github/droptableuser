Device : Ndef {

	*new {|key|
		var envir = this.dictFor(Server.default).envir;
		var res = envir[key];
		if (res.isNil) {
			res = this.createNew(key).deviceInit();

			res.wakeUp;
			res.ar(numChannels:2);
			res.play;
            /*
			res.filter(200, {|in| LPF.ar(in, \lpf.kr(20000).lag(0.01) )});
			res.filter(300, {|in| HPF.ar(in, \hpf.kr(20).lag(0.01) )});
			res.filter(400, {|in|

				// adapted from https://github.com/21echoes/pedalboard/blob/master/lib/fx/Compressor.sc
				var sig = HPF.ar(in, 25);
				var drive = \compress.kr(0.5);
				var ratio = LinExp.kr(drive, 0, 1, 0.25, 0.05);
				var threshold = LinLin.kr(drive, 0, 1, 0.9, 0.5);
				var gain = 1/(((1.0-threshold) * ratio) + threshold);
				gain = Select.kr(drive > 0.9, [
					gain,
					gain * LinExp.kr(drive, 0.9, 1, 1, 1.2);
				]);

				sig = Compander.ar(
					sig, sig,
					threshold,
					1.0,
					ratio,
					\clamp.kr(0.005),
					\relax.kr(0.1),
					gain
				);
				sig;
			});
            */

			res.filter(500, {|in| Limiter.ar(in, \limit.kr(1));});

            /*
			// use units to try to keep things together and provide sort hints
			res.addSpec(\lpf, ControlSpec(20, 20000, \lin, 0, 20000, "xxfilter"));
			res.addSpec(\wet200, ControlSpec(0, 1, \lin, 0, 1, "xxfilter"));

			res.addSpec(\hpf, ControlSpec(20, 10000, \lin, 0, 20, "xxfilter"));
			res.addSpec(\wet300, ControlSpec(0, 1, \lin, 0, 1, "xxfilter"));

			res.addSpec(\compress, ControlSpec(0, 1, \lin, 0, 0.5, "yycompress"));
			res.addSpec(\clamp, ControlSpec(0, 1, \lin, 0, 0.005, "yycompress"));
			res.addSpec(\relax, ControlSpec(0, 1, \lin, 0, 0.1, "yycompress"));
			res.addSpec(\wet400, ControlSpec(0, 1, \lin, 0, 0, "yycompress"));

            */

			res.addSpec(\limit, ControlSpec(0, 1, \lin, 0, 1.0, ""));
			res.addSpec(\wet500, ControlSpec(0, 1, \lin, 0, 1, ""));

            /*
			res.set(\wet400, 0);
            */
			res.set(\wet500, 1);

			res.vol = 1;

			res.postInit;

			ServerTree.add({
				\cmdperiod.debug(key);
				res.send;
			});
		}
		^res;
	}

	*createNew {|...args|
		^super.new(*args);
	}

	*doesNotUnderstand {|selector|
		^this.new(selector);
	}

	deviceInit {
		// override to initialize
	}

	postInit {
		// override to initialize after int
	}

	save {|path|

	}

	out_ {|bus=0|
		this.monitor.out = bus;
	}

	/*
	should come from NodeProxy extension
	getSettings {
		^this.getKeysValues.flatten.asDict;
	}
	*/

	addPreset {|num|
		P.addPreset(this, num, this.getSettings);
	}

	loadPreset {|num|
		var preset = P.getPreset(this, num);
		this.set(*preset.getPairs);
	}

	getPresets {
		^P.getPresets(this);
	}

	morph {|from, to, numsteps=20, wait=0.1|
		P.morph(this, from, to, numsteps, wait);
	}

	/*
	NOTE: defined extension on NodeProxy for view
	override on subclass
	view {}
	*/
}