(
~num_synths = 8;
~num_lfos = 4;
~lfo_rate_max = 10;
~specs = SynthDescLib.global.at(\subtractr).metadata[\specs];

~update_lfos = {arg whichkey, ratekey, levelkey, ndef;

	var node = Ndef(ndef);
	var rate = node.get(\rate);
	var level = node.get(\level);
	var which = node.get(\which);
	var val;

	val = rate.linlin(0, ~lfo_rate_max, 0, 1);
	~ui.sendMsg("/1/" ++ ratekey, val);

	val = level;
	~ui.sendMsg("/1/" ++ levelkey, val);

	~ui.sendMsg("/1/" ++ whichkey, 1);
};

~update_ui = {arg key, index=0, settings=();

	var specs = ~specs;

	var freqmulfunc = {arg key;
		var spec = specs.detect({arg assoc; assoc.key == key}).value;
		var default = if (settings[key].isNil.not) {settings[key]} {spec.default};
		var val = default.nearestInList([-24, -12, -7, -5, 0, 5, 7, 12, 24].midiratio);
		~ui.sendMsg("/1/" ++ key, spec.unmap(val));
	};

	var lfofunc = {arg wave;

		var ratepath = "/1/%lforate".format(wave);
		var levelpath = "/1/%lfolevel".format(wave);
		var lfopath = "/1/%lfo".format(wave);

		if (key.isNil) {
			~ui.sendMsg(ratepath, 0);
			~ui.sendMsg(levelpath, 0);
			~num_lfos.do({arg i;
				var num = ~num_lfos-i;
				var path = lfopath ++ "/%/1".format(num);
				~ui.sendMsg(path, 0);
			});
		}{
			var lfokey = (key ++ '_' ++ wave ++ 'lfo').asSymbol;
			var ndef = Ndef(lfokey);
			var which = ndef.get(\which) ?? 0;
			var rate = ndef.get(\rate) ?? 0;
			var level = ndef.get(\level) ?? 0;

			~ui.sendMsg(ratepath, rate.linlin(0, ~lfo_rate_max, 0, 1));
			~ui.sendMsg(levelpath, level);
			~num_lfos.do({arg i;
				var num = ~num_lfos-i;
				var path = lfopath ++ "/%/1".format(num);
				~ui.sendMsg(path, which == i);
			});
		};
	};

	lfofunc.('tri');
	lfofunc.('saw');
	lfofunc.('pulse');
	lfofunc.('sine');

	specs.do({arg assoc;
		var key = assoc.key;
		var spec = assoc.value;
		var path = ('/1/' ++ key).asSymbol;
		var default = if (settings[key].isNil.not) {settings[key]} {spec.default};
		var unmapped = spec.unmap(default);
		if (unmapped.isNaN.not) {
			~ui.sendMsg(path.asString, unmapped);
		};
	});

	{
		var cutoffspec = specs.detect({arg assoc; assoc.key == \cutoff}).value;
		var resspec = specs.detect({arg assoc; assoc.key == \res}).value;
		var fwhichspec = specs.detect({arg assoc; assoc.key == \fwhich}).value;

		var cutoffdefault = if (settings[\cutoff].isNil.not) {settings[\cutoff]} {cutoffspec.default};
		var resdefault = if (settings[\res].isNil.not) {settings[\res]} {resspec.default};
		var fwhichdefault = if (settings[\fwhich].isNil.not) {settings[\fwhich]} {fwhichspec.default};

		~ui.sendMsg("/1/cutoffres", cutoffspec.unmap(cutoffdefault), resspec.unmap(resdefault));
		~ui.sendMsg("/1/fwhich/1/1", fwhichdefault == 0);
		~ui.sendMsg("/1/fwhich/1/2", fwhichdefault == 1);
	}.();

	if (key.isNil.not) {
		~ui.sendMsg("/1/synth%".format(index), key);
	};

	freqmulfunc.(\trifreqmul);
	freqmulfunc.(\sawfreqmul);
	freqmulfunc.(\pulsefreqmul);
	freqmulfunc.(\sinefreqmul);
};

~lfofunc = {arg id, key, prop;

	var ndefid = (id ++ '_' ++ key).asSymbol;
	var path = "/1/%%".format(key, "rate");

	Ndef(ndefid, {
		var which = \which.kr(0);
		var rate = \rate.kr(1);
		var focus = \focus.kr(1);
		var level = \level.kr(0);
		var lfos = [
			SinOsc.ar(rate),
			LFSaw.ar(rate),
			LFTri.ar(rate),
			LFNoise2.ar(rate)
		];
		var sig = SelectXFocus.ar(which, lfos, focus) * level;
		sig.lag(0.005);
	});

	OscCtrl.path(path.asSymbol, {arg val;
		var myval = val[0].linlin(0, 1, 0, 10);
		Ndef(ndefid).set(\rate, myval);
		~ui.sendMsg("/1/log", "%: %".format(\rate, myval.trunc(0.0001)));
	});

	path = "/1/%%".format(key, "level");
	OscCtrl.path(path.asSymbol, {arg val;
		var myval = val[0];
		Ndef(ndefid).set(\level, myval);
		~ui.sendMsg("/1/log", "%: %".format(\level, myval.trunc(0.0001)));
	});

	~num_lfos.do({arg i;
		var num = i + 1;
		var path = "/1/%/%/1".format(key, num);
		var index = ~num_lfos-1-i;
		var mykey = (prop ++ 'lfo').asSymbol;
		~current.set(mykey, Ndef(ndefid));

		OscCtrl.path(path.asSymbol, {arg val;
			var state = val[0];
			if (state == 1) {
				Ndef(ndefid).set(\which, index);
				~ui.sendMsg("/1/log", "%: %".format(\which, index));
			};
		});
	});
};

~subtractr_system_load = {arg index;
	var current = ~subtractrs[index];
	if (current.isNil.not) {
		~current = current;
		~update_ui.(~current.key, index, ~current.props);
	};
};

~subtractr_system_new = {

	if (~subtractrs.size < ~num_synths) {

		var id = App.idgen.asSymbol;
		var synth = S(id, \subtractr);
		var num, path;
		~subtractrs = ~subtractrs.add(synth);
		num = ~subtractrs.size - 1;
		~subtractr_system_load.(num);

		// set up lfos
		~lfofunc.(id, \trilfo, \triwidth);
		~lfofunc.(id, \sawlfo, \sawsync);
		~lfofunc.(id, \pulselfo, \pulsewidth);
		~lfofunc.(id, \sinelfo, \sineskew);

		// buttons are reverse order top to bottom
		path = "/1/synths/%/1".format(~num_synths-num);
		~ui.sendMsg(path, 1);
	}
};

~init = {

	var specs = ~specs;
	var freqmulmap, cutoffspec, resspec, fwhichspec;

	~ui = NetAddr("10.0.1.65", 9000);
	~current = nil;
	~subtractrs = List.new;

	// register osc listeners for all of the specs
	specs.do({arg assoc;
		var key = assoc.key;
		var path = ('/1/' ++ key).asSymbol;
		var spec = assoc.value;
		OscCtrl.path(path, {arg val;
			var myval = val[0];
			var mappedval = spec.map(myval);
			~ui.sendMsg("/1/log", "%: %".format(key, mappedval.trunc(0.0001)));
			~current.set(key, mappedval);
		});
	});

	// fwhich toggle
	OscCtrl.path('/1/fwhich/1/1', {arg val;
		var state = val[0];
		if (state == 1) {
			~ui.sendMsg("/1/log", "%: %".format(\fwhich, 0));
			~current.set(\fwhich, 0);
		}
	});

	// fwhich toggle
	OscCtrl.path('/1/fwhich/1/2', {arg val;
		var state = val[0];
		if (state == 1) {
			~ui.sendMsg("/1/log", "%: %".format(\fwhich, 1));
			~current.set(\fwhich, 1);
		}
	});

	cutoffspec = specs.detect({arg assoc; assoc.key == \cutoff}).value;
	resspec = specs.detect({arg assoc; assoc.key == \res}).value;
	fwhichspec = specs.detect({arg assoc; assoc.key == \fwhich}).value;

	// filter cutoff and res
	OscCtrl.path('/1/cutoffres', {arg val;
		var cutoff = cutoffspec.map(val[0]);
		var res = resspec.map(val[1]);
		~ui.sendMsg("/1/log", "%: %; %: %".format(\cutoff, cutoff.trunc(0.0001), \res, res.trunc(0.0001)));
		~current.set(\cutoff, cutoff, \res, res);
	});

	// octave mappings
	freqmulmap = {arg key;
		var spec = specs.detect({arg assoc; assoc.key == key}).value;
		OscCtrl.path(('/1/' ++ key).asSymbol, {arg val;
			var myval = val[0];
			myval = spec.map(myval);
			myval = myval.nearestInList([-24, -12, -7, -5, 0, 5, 7, 12, 24].midiratio);
			~ui.sendMsg("/1/log", "%: %".format(key, myval.trunc(0.0001)));
			~current.set(key, myval);
		});
	};

	freqmulmap.(\trifreqmul);
	freqmulmap.(\sawfreqmul);
	freqmulmap.(\pulsefreqmul);
	freqmulmap.(\sinefreqmul);

	// record button
	OscCtrl.path('/1/rec', {arg val;
		var state = val[0];
		if (state == 1) {
			\rec.postln;
			App.saveWorkspace("s1", rec:true);
		}{
			\stoprec.postln;
			s.stopRecording;
		}
	});

	// reset button
	OscCtrl.path('/1/reset', {arg val;
		var state = val[0];
		if (state == 1) {
			~init.();
		};
	});

	// new button
	OscCtrl.path('/1/new', {arg val;
		var state = val[0];
		if (state == 1) {
			~subtractr_system_new.();
		}
	});

	// launch synth button
	~num_synths.do({arg i;

		var num = i + 1;
		var path = "/1/synths/%/1".format(num);
		// clear display
		~ui.sendMsg("/1/synth%".format(i), "");
		~ui.sendMsg(path, 0);

		OscCtrl.path(path.asSymbol, {arg val;
			var state = val[0];
			if (state == 1) {
				// buttons are in reverse order
				~subtractr_system_load.(~num_synths-1-i);
			};
		});
	});
	~update_ui.();
};
)


~current.set(\dur, 0.25);
~current.set(\degree, Pseries(0, 1).fold(0, 4))
~current.play;
~current.stop;
