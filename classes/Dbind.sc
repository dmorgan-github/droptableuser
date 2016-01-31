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

	classvar <>all;

	*new {arg key ... pairs;

		var res = all.at(key);
		if(res.isNil) {
			res = super.new.addNew(key, pairs);
		} {
			res.set(*pairs);
		}

		^res
	}

	set {arg ... pairs;

		var pbindefId = ("p_" ++ this.key).asSymbol;
		Pbindef(pbindefId, *pairs);
		^this;
	}

	map {arg name, func;

		var id = (this.key ++ name).asSymbol;
		var ndef = Ndef(id, func);
		this.lfos[name.asSymbol] = ndef;
		this.set(name.asSymbol, ndef.bus.asMap);
		^this;
	}

	filter {arg index, obj;

		if (obj.isNil, {
			this.ndef[index] = nil;
		}, {
			this.ndef[index] = \filter -> obj;
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

	play {
		this.pdef.play;
	}

	stop {
		this.pdef.stop;
	}

	addNew {arg newKey, pairs;

		var pbindefId = ("p_" ++ newKey).asSymbol;
		var pdefId = ("pdef_" ++ newKey).asSymbol;
		var ndefId = ("n_" ++ newKey).asSymbol;

		Ndef(ndefId).clear;
		Ndef(ndefId).ar(2);
		Ndef(ndefId).quant = 0.0;
		Ndef(ndefId).fadeTime = 0.0;

		Pbindef(pbindefId).clear;
		Pbindef(pbindefId, *pairs);
		Pbindef(pbindefId).quant = 1.0;

		Pdef(pdefId).clear;
		Pdef(pdefId,
			Pfset({
				lfos.values.collect(_.send);
				Ndef(ndefId).play;
				~out = Ndef(ndefId).bus;
				~group = Ndef(ndefId).group;
			}, Pbindef(pbindefId))
		);

		key = newKey;
		lfos = IdentityDictionary.new(know:true);
		pdef = Pdef(pdefId);
		ndef = Ndef(ndefId);

		all.put(key, this);
		^this;
	}

	*hasGlobalDictionary { ^true }

	*initClass {
		all = IdentityDictionary.new;
	}
}