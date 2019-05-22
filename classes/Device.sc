V {
	var <key, order;

	classvar all;

	*new {arg key, voice, cb;
		^super.new.init(key, voice, cb);
	}

	init {arg inKey, inVoice, inCb;
		var obj;
		key = inKey.asSymbol;
		order = Order.new;
		obj = all.at(key);
		if (obj.isNil) {
			obj = this;
			all.put(key, obj);
		};
		if (inVoice.isNil.not) {
			Ndef(key)[0] = Library.at(\voices, inVoice).(inCb);
		};
		^obj;
	}

	fx_ {arg index=1, inVal, wet=1 ...args;
		var func, settings, reset = false;
		if (inVal.class == Function) {
			func = inVal;
		} {
			func = Library.at(\fx, inVal).performKeyValuePairs(\value, args);
		};

		// since reloading the filter interrupts
		// the ongoing sound we want to try to prevent that
		// by checking to see if the user is updating the filter def
		settings = order.at(index);
		if (settings.isNil) {
			order.put(index, (\func:func.asCompileString));
			reset = true;
		} {
			if (settings[\func] != func.asCompileString) {
				reset = true;
			};
			if (args.includes(\reset)) {
				reset = true;
			}
		};
		if (reset) {
			"reset fx %".format(index).debug("V: " ++ this.key);
			Ndef(this.key).filter(index, func);
		};
		Ndef(this.key).set(('wet' ++ index).asSymbol, wet)
		.set(*args.asPairs);
		^this;
	}

	removeAt_ {arg index=1;
		order.removeAt(index);
		Ndef(this.key).removeAt(index);
		^this;
	}

	set_ {arg ...args;
		Ndef(this.key).set(*args.asPairs);
		^this;
	}

	asNode {
		^Ndef(this.key);
	}

	clear {
		order.clear;
		Ndef(this.key).clear;
	}

	*clearAll {
		all.clear
	}

	*initClass {
		all = IdentityDictionary.new;
	}
}

M {
	var <key, order;

	classvar all;

	*new {arg key;
		^super.new.init(key);
	}

	init {arg inKey;
		var obj;
		order = Order.new;
		obj = all.at(inKey);
		if (obj.isNil) {
			var node;
			key = inKey.asSymbol;
			obj = this;
			all.put(key, obj);
		};
		^obj;
	}

	v_ {arg index=0, voice, mix=1;
		var node = Ndef(this.key);
		node[index] = \mix -> {voice.asNode.ar};
		node.set(('mix' ++ index).asSymbol, mix);
		^this;
	}

	fx_ {arg index=1, inVal, wet=0.5 ...args;
		var func, settings, reset = false;
		if (inVal.class == Function) {
			func = inVal;
		} {
			func = Library.at(\fx, inVal).performKeyValuePairs(\value, args);
		};

		// since reloading the filter interrupts
		// the ongoing sound we want to try to prevent that
		// by checking to see if the user is updating the filter def
		settings = order.at(index);
		if (settings.isNil) {
			order.put(index, (\func:func.asCompileString));
			reset = true;
		} {
			if (settings[\func] != func.asCompileString) {
				reset = true;
			};
			if (args.includes(\reset)) {
				reset = true;
			}
		};
		if (reset) {
			"reset fx %".format(index).debug("M: " ++ this.key);
			Ndef(this.key).filter(index, func);
		};
		Ndef(this.key).set(('wet' ++ index).asSymbol, wet)
		.set(*args.asPairs);
		^this;
	}

	removeAt_ {arg index=1;
		order.removeAt(index);
		Ndef(this.key).removeAt(index);
		^this;
	}

	set_ {arg ...args;
		Ndef(this.key).set(*args.asPairs);
		^this;
	}

	asNode {
		^Ndef(this.key);
	}

	clear {
		order.clear;
		Ndef(this.key).clear;
	}

	*clearAll {
		all.clear
	}

	*initClass {
		all = IdentityDictionary.new;
	}
}

P {
	var <key;

	*new {arg key, func ...args;
		// by convention the key should match the key
		// of an instance of M so that all the nodes
		// are activated and monitoring for audio
		^super.new.init(key, func, args);
	}

	init {arg inKey, inFunc, inArgs;
		key = inKey.asSymbol;
		if (inFunc.isNil.not) {
			this.prBuild(inFunc, inArgs);
		};
		^Pdef(key);
	}

	prBuild {arg inFunc, inArgs;
		var patterns = inFunc.();
		var pbinds = patterns.collect({arg val, i;
			var key = val.key; // could be an array
			var pairs = val.value; // pattern params

			// get the superset of unique args
			// for the specified ndef(s) where the ndef(s)
			// have matching controlnames
			var evtargs = {
				var setargs = [];
				var keys = pairs.reject({arg val, i; i.odd});
				key.asArray.do({arg val, i;
					var ctrls = Ndef(val).controlNames.collect({arg val; val.name}).asSet.sect(keys.asSet);
					setargs = setargs ++ ctrls;
				});
				// freq argument is implied by other properties
				setargs.asSet.asArray ++ if (keys.includes(\degree) || keys.includes(\note) || keys.includes(\midinote)) {\freq};
			}.();
			var props = [\type, \set,
				\id, Pfunc({ key.asArray.collect({arg val; Ndef(val.asSymbol).nodeID }) }),
				\args, evtargs] ++ pairs.asPairs;
			//props.postln;
			Pbind(*props)
		});
		Pdef(this.key, {arg monitor=true, fadeTime=0;

			(this.key.asArray ++ inArgs).do({arg val, i;
				var node = Ndef(val);
				if ((node.rate == \audio) && node.isMonitoring.not && monitor){
					node.play(fadeTime:fadeTime)
				};
			});

			Ppar(pbinds);
		});
	}
}