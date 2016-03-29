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

	var <>trace;

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
					sig = LeakDC.ar(sig)  * amp;
					//sig = Normalizer.ar(sig);
					// add env to handle releasing the synth
					Env.asr(attackTime:0.0001).kr(gate: gate, doneAction:2);

					// TODO: should be able to configure different panning/stereo options, etc.
					OffsetOut.ar(out, Pan2.ar(sig, pan));
				}).add;
			});
		});

		// create the object if necessary
		if(res.isNil) {
			res = super.new.prAdd(key, instrument, dict);
		};

		// update if config passed in
		if (hasConfig, {

			// Does this make sense?
			//res.reset;

			res.setMonitor(dict[\monitor] ? true);

			res.setTrace(dict[\trace] ? false);

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

		// TODO: using trace loses reference to pdef
		// calling play repeatedly creates new patterns
		// which will overlap. may need a new pattern class
		// to allow the ability to toggle trace
		if (this.trace) {
			this.pdef.trace.play;
		} {
			this.pdef.play;
		}
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

	setTrace {arg val;

		this.trace = val;
	}

	*hasGlobalDictionary { ^true }

	*initClass {
		all = IdentityDictionary.new;
	}
}

DslcrPhrase {

	var <wholebeats;

	var <upbeats;

	var <downbeats;

	var <backbeats;

	var <count;

	var <slices;

	var <beats;

	var <cumulative;

	var <delta;

	*new {arg cumulative, count, slices, beats, wholebeats, upbeats, downbeats, backbeats, delta;

		^super.new.prInit(cumulative, count, slices, beats, wholebeats, upbeats, downbeats, backbeats, delta);
	}

	prInit {arg pCumulative, pCount, pSlices, pBeats, pWholebeats, pUpbeats, pDownbeats, pBackbeats, pDelta;

		cumulative = pCumulative;
		count = pCount;
		slices = pSlices;
		beats = pBeats;
		wholebeats = pWholebeats;
		upbeats = pUpbeats;
		downbeats = pDownbeats;
		backbeats = pBackbeats;
		delta = pDelta;
		^this;
	}
}

DslcrSlice {

	var <delta;
	var <slice;
	var <dir;
	var <amp;

	*new {arg delta, slice, dir, amp;

		^super.new.prInit(delta, slice, dir, amp);
	}

	prInit {arg delta, slice, dir, amp;

		this.delta = delta;
		this.slice = slice;
		this.dir = dir;
		this.amp = amp;
	}
}

Dslcr {

	*build {arg key, buf, beats = 8, beatDiv = 2, sliceMaker, amp = 0.1, clock = TempoClock.default;

		// buffer info
		var numFrames = buf.numFrames;
		var sampleRate = buf.sampleRate;

		// length in seconds of sample
		var len = numFrames/sampleRate;

		// beats per second
		var bps = beats/len;

		// number of slices
		var slices = beats * beatDiv;

		// frames per slice
		var fps = numFrames/slices;

		// info about phrase beats
		var wholebeats = (0..slices-1).select({arg item; item.even } );
		var upbeats = (0..slices-1).select({arg item; item.odd } );
		var downbeats = wholebeats.select({arg item, i; i.even  });
		var backbeats = wholebeats.select({arg item, i; i.odd  });
		var delta = (slices/beats).reciprocal;

		// yields slice data to the pattern
		var rtn = Routine({

			var queue = LinkedList.new;
			var count = 0;
			var cumulative = List.new;

			inf.do({arg i;

				var event;
				var phrase;
				var phrasePos = count % beats;

				if (phrasePos.equalWithPrecision(0.1)) {
					cumulative = List.new;
				};

				if (queue.isEmpty) {
					phrase = DslcrPhrase(cumulative, count, slices, beats, wholebeats, upbeats, downbeats, backbeats, delta);
					sliceMaker.value(phrase, queue);
				};

				event = queue.popFirst;
				count = count + event[\delta];
				cumulative.add(event);
				[event[\delta], event[\slice] * fps, event[\dir]].yield;
			});
		});

		^Dbind(key.asSymbol, {arg config;
			config.synth = \smplr_m;
			config.pattern = [
				[\delta, \startPos, \dir], rtn,
				\buf, buf,
				\rate, Pfunc({ clock.tempo }) / bps * Pkey(\dir),
				\amp, amp,
				\dur, Pfunc({ clock.beatDur }) * Pkey(\delta),
				\curve, -4 * Pkey(\dir)
			]
		});
	}
}


