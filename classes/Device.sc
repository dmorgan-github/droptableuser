V {
	var <key;

	classvar <>all;

	*new {arg key, voice, cb;
		^super.new.init(key, voice, cb);
	}

	init {arg inKey, inVoice, inCb;
		var obj;
		obj = all.at(inKey);
		if (obj.isNil) {
			key = inKey.asSymbol;
			Ndef(key)[0] = Fdef(inVoice).(inCb);
			obj = this;
			all.put(key, obj);
		};
		^obj;
	}

	fx_ {arg inKey, index=1, wet=0.5 ...args;
		var func;
		if (inKey.class == Function) {
			func = inKey;
		} {
			func = Fdef(inKey);
			func = func.(*args);
		};
		Ndef(this.key).filter(index, func)
		.set(('wet' ++ index).asSymbol, wet)
		.set(args.asPairs);
		^this;
	}

	removeAt_ {arg index=1;
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
		Ndef(this.key).clear;
	}

	*clearAll {
		all.clear
	}

	*initClass {
		all = IdentityDictionary.new;
	}
}

D {
	var <key;

	classvar <>all;

	*new {arg key ...args;
		^super.new.init(key, args);
	}

	init {arg inKey;
		var obj;
		obj = all.at(inKey);
		if (obj.isNil) {
			var node;
			key = inKey.asSymbol;
			obj = this;
			all.put(key, obj);
		};
		^obj;
	}

	voice_ {arg voice, index=0, mix=1;
		var node = Ndef(this.key);
		node[index] = \mix -> {voice.asNode.ar};
		node.set(('mix' ++ index).asSymbol, mix);
		^this;
	}

	fx_ {arg inKey, index=1, wet=0.5 ...args;
		var func;
		if (inKey.class == Function) {
			func = inKey;
		} {
			func = Fdef(inKey);
			func = func.(*args);
		};
		Ndef(this.key).filter(index, func)
		.set(('wet' ++ index).asSymbol, wet)
		.set(args.asPairs);
		^this;
	}

	pattern_ {arg func;
		var patterns = func.();
		var pbinds = patterns.collect({arg val, i;
			var key = val.key; // could be an array
			var evt = val.value; // pattern event

			// get the superset of unique event args
			// for the specified ndef(s) where the ndef(s)
			// have matching controlnames
			var evtargs = {
				var eventkeys = evt.keys;
				var setargs = [];
				key.asArray.do({arg val, i;
					var ctrls = Ndef(val).controlNames.collect({arg val; val.name}).asSet.sect(eventkeys.asSet);
					setargs = setargs ++ ctrls;
				});
				setargs.asSet.asArray ++ if (evt.keys.includes(\degree) || evt.keys.includes(\note)) {\freq};
			}.();
			var props = [\type, \set,
				\id, Pfunc({ key.asArray.collect({arg val; Ndef(val.asSymbol).nodeID }) }),
				\args, evtargs] ++ evt.asPairs;
			Pbind(*props)
		});
		Pdef(key, {arg monitor=true, fadeTime=0;
			var node = Ndef(this.key);
			if (node.isMonitoring.not && monitor){
				node.play(fadeTime:fadeTime)
			};
			Ppar(pbinds);
		});
		^this;
	}

	removeAt_ {arg index=1;
		Ndef(this.key).removeAt(index);
		^this;
	}

	set_ {arg ...args;
		Ndef(this.key).set(args.asPairs);
		^this;
	}

	asNode {
		^Ndef(this.key);
	}

	asPattern {
		^Pdef(this.key);
	}

	clear {
		Ndef(this.key).clear;
	}

	*clearAll {
		all.clear
	}

	*initClass {
		all = IdentityDictionary.new;
	}
}