Evt {

	*on {arg event, obj, func;
		NotificationCenter.register(this, event, obj, func);
	}

	*off {arg event, obj;
		NotificationCenter.unregister(this, event, obj);
	}

	*trigger {arg event, data = Dictionary.new, defer = nil;
		if (defer.isNil, {
			NotificationCenter.notify(this, event, data);
		}, {
			{NotificationCenter.notify(this, event, data);}.defer(defer);
		});
	}

	*clear {
		NotificationCenter.clear;
	}
}

Dbind {

	var <key;

	var <lfos;

	var <pdef;

	var <ndef;

	var <>monitor;

	var <>obj;

	classvar <>all;

	*new {arg key, config;

		// TODO: simplify this method
		// TODO: need to rebuild pattern if mode changes

		// TODO: set fadetimes for ndef and pdefs...
		var res = all.at(key);
		var instrument;
		var dict = IdentityDictionary.new(know:true);
		var hasConfig = config.isFunction;

		dict.put(\mode, \poly);
		dict.put(\pattern, []);

		// ensure synth is created
		if (hasConfig, {

			config.value(dict);
			instrument = dict[\synth];

			if (dict[\synth].isFunction, {

				instrument = key;
				SynthDef(instrument, {arg amp = 0.5, out = 0, pan = 0, gate = 1;

					var sig = SynthDef.wrap(dict[\synth]);
					sig = LeakDC.ar(sig) * amp;
					Env.asr().kr(gate: gate, doneAction:2);
					OffsetOut.ar(out, Pan2.ar(sig, pan));
					//OffsetOut.ar(out, Splay.ar(sig) );
				}).add;
			});
		});

		// create the object if necessary
		if(res.isNil) {
			res = super.new.prAdd(key, instrument, dict);
		};

		// update if config passed in
		if (hasConfig, {

			res.setMonitor(dict[\monitor] ? true);

			// TODO: when pattern is set here
			// it should not call set. this needs to reset
			// the whole pattern through the pdef
			// not the pbindef
			res.set(*dict[\pattern]);

			if (dict[\map].isNil.not, {

				dict[\map].keysValuesDo({arg k,v;
					res.map( k, v );
				});
			});

			if (dict[\filter].isNil.not, {

				dict[\filter].keysValuesDo({arg k,v;
					res.filter( k, v );
				});
			});
		});

		^res
	}

	set {arg ... pairs;

		var pbindefId = ("p_" ++ this.key).asSymbol;
		Pbindef(pbindefId, *pairs);

		^this;
	}

	map {arg name, func;

		if (func.isNil or: func.isFunction.not) {

			this.lfos[name.asSymbol].free;
			this.lfos.removeAt(name.asSymbol);
			this.set(name.asSymbol, nil);
		} {

			var id = (this.key ++ name).asSymbol;
			var ndef = Ndef(id, func);
			this.lfos[name.asSymbol] = ndef;
			this.set(name.asSymbol, ndef.bus.asMap);
		};

		^this;
	}

	filter {arg index, func;

		if (func.isNil or: func.isFunction.not, {

			this.ndef[index] = nil;
		}, {

			this.ndef[index] = \filter -> func;
		});

		^this;
	}

	on {arg event, func;

		Evt.on(event, this.key, func);
		^this;
	}

	off {arg event;

		Evt.off(event, this.key);
		^this;
	}

	reset {

		var pbindefId = ("p_" ++ this.key).asSymbol;
		var ndefId = ("n_" ++ this.key).asSymbol;
		var pdefId = ("pdef_" ++ this.key).asSymbol;

		Ndef(ndefId).free;
		Pbindef(pbindefId).clear;
		Pdef(pdefId).clear;
		lfos.values.collect(_.free);

		// this should force it to be rebuilt
		all.removeAt(this.key);

		^this;
	}

	play {

		this.pdef.play;
	}

	stop {

		this.pdef.stop;
	}

	prAdd {arg newKey, instrument, dict;

		var pbindefId = ("p_" ++ newKey).asSymbol;
		var pdefId = ("pdef_" ++ newKey).asSymbol;
		var ndefId = ("n_" ++ newKey).asSymbol;
		var pattern;

		lfos = IdentityDictionary.new(know:true);

		Ndef(ndefId).clear;
		Ndef(ndefId).ar(2);
		Ndef(ndefId).quant = 0.0;
		Ndef(ndefId).fadeTime = 0.0;

		Pbindef(pbindefId).clear;
		if (dict.mode == \poly, {

			pattern = Pbindef(pbindefId, \instrument, instrument);
		}, {

			pattern = Pchain(Pmono(instrument), Pbindef(pbindefId, \foo, 1));
		});

		Pbindef(pbindefId).quant = 1.0;
		Pdef(pdefId).clear;
		Pdef(pdefId,
			Pfset({

				lfos.values.collect(_.send);
				if (this.monitor) {
					Ndef(ndefId).play;
				} {
					Ndef(ndefId).stop;
					if (Ndef(ndefId).group.isPlaying.not) {
						// recover after a cmd-period
						Ndef(ndefId).group = Group.new;
					}
				};

				~out = Ndef(ndefId).bus;
				~group = Ndef(ndefId).group;
			}, pattern)
		);

		obj = dict;
		key = newKey;
		pdef = Pdef(pdefId);
		ndef = Ndef(ndefId);
		monitor = true;
		all.put(key, this);
		^this;
	}

	setMonitor {arg val;

		this.monitor = val;
		if (this.monitor == true, {
			this.ndef.play;
		}, {
			this.ndef.stop;
		});
	}

	*hasGlobalDictionary { ^true }

	*initClass {
		all = IdentityDictionary.new;
	}
}