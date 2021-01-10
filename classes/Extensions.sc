/*
TODO:
Pslide
Pindex
Pswitch
*/

+ Integer {
	peuclid {arg beats, offset=0, repeats=inf; ^Pbjorklund(this, beats, repeats, offset)}
	peuclid2 {arg beats, offset=0, repeats=inf; ^Pbjorklund2(this, beats, repeats, offset)}
}

+ Number {
	incr {arg step, repeats=inf; ^Pseries(this, step, inf)}
}

+ SequenceableCollection {
	pseq {arg repeats=inf, offset=0; ^Pseq(this, repeats, offset) }
	prand {arg repeats=inf; ^Prand(this, repeats) }
	pwrand {arg weights, repeats=inf; ^Pwrand(this, weights.normalizeSum, repeats)}
	pshuf {arg num=1, repeats=inf; ^Pn(Pshuf(this, num), repeats) }
	step {|durs, repeats=inf| ^Pstep(this, durs, repeats)}
	pdv {|repeats=inf, key='degree'| ^Pdv(this, key).repeat(repeats) }
}

+ Pattern {
	limit {arg num; ^Pfin(num, this.iter) }
	step {arg dur, repeats=inf; ^Pstep(this, dur, repeats)}
	latchprob {arg prob=0.5; ^Pclutch(this, Pfunc({ if (prob.coin){0}{1} }))}
	latch {arg func; ^Pclutch(this, Pfunc(func)) }
	//dd {arg repeats=inf; ^Dd(this, repeats)}
	// don't advance pattern on rests
	norest { ^Pclutch(this, Pfunc({|evt| evt.isRest.not })) }
}

+ Array {
	nums { ^this.asInteger.join("").collectAs({|chr| chr.asString.asInteger }, Array) }
}

+ NodeProxy {

	view {
		^U(\ngui, this);
	}

	addFx {|fx, wet=1, index|
		var idx = if (index.isNil) { (this.objects.indices.last ?? 0) + 10}{index};
		var obj = N.loadFx(fx);
		var func = obj[\synth];
		var specs = obj[\specs];
		this.filter(idx, func).set("wet%".format(idx).asSymbol, wet);
		if (specs.isNil.not) {
			specs.do({|assoc|
				this.addSpec(assoc.key, assoc.value);
			})
		};
		this.addSpec("wet%".format(idx).asSymbol, [0, 1, \lin, 0, 1].asSpec);
		"added % at index %".format(fx, idx).debug(this.key);
	}


	mix {arg index=0, obj, vol=1;

		if (obj.isKindOf(Function)) {
			this.put(index, \mix -> obj);
		} {
			if (obj.isNil) {
				this.put(index, obj);
			}{
				var key = obj.key;
				// not using \mix role so that we can show
				// helpful names in gui instead of \mix0, \mix1, etc
				if (obj.class == S) {
					//var l = (key ++ 'L').asSymbol;
					//var r = (key ++ 'R').asSymbol;
					this.put(index, { obj.node.ar * Control.names([key]).kr(vol) });
				}{
					//var l = (key ++ 'L').asSymbol;
					//var r = (key ++ 'R').asSymbol;
					this.put(index, {obj.ar * Control.names([key]).kr(vol) });
				};
				this.addSpec(key, [0, 1, \lin, 0, vol]);
			}
		};
	}
	nscope {
		^U(\scope, this);
	}

	forPattern {
		^Pbind(
			\out, Pfunc({this.bus.index}),
			\group, Pfunc({this.group})
		)
	}

	getSettings {
		^this.getKeysValues.flatten.asDict;
	}

	preset {
		var key = this.key;
		NdefPreset(key); // make a preset instance
		ProxyPresetGui(NdefPreset(key)); // and it's GUI. stores preset as text file
	}
}

+ S {
	kb {
		^U(\kb, this);
	}
	view {
		^U(\sgui, this);
	}
	nscope {
		^U(\scope, this.node);
	}
	microlab {
		Microlab().note(
			{|note, vel|
				vel = 127/vel;
				this.on(note, vel);
			},
			{|note|
				this.off(note);
			}
		);
	}
}

+ Pdef {
	sgui {
		^U(\sgui, this);
	}
}
/*
+ NodeProxy {

	put { | index, obj, channelOffset = 0, extraArgs, now = true |
		var container, bundle, oldBus = bus;

		if(obj.isNil) { this.removeAt(index); ^this };
		if(index.isSequenceableCollection) {
			^this.putAll(obj.asArray, index, channelOffset)
		};

		bundle = MixedBundle.new;
		container = obj.makeProxyControl(channelOffset, this);
		container.build(this, index ? 0); // bus allocation happens here

		if(this.shouldAddObject(container, index)) {
			// server sync happens here if necessary
			if(server.serverRunning) { container.loadToBundle(bundle, server) } { loaded = false; };
			this.prepareOtherObjects(bundle, index, oldBus.notNil and: { oldBus !== bus });
		} {
			format("failed to add % to node proxy: %", obj, this).postln;
			^this
		};

		this.putNewObject(bundle, index, container, extraArgs, now);
		this.changed(\source, [obj, index, channelOffset, extraArgs, now, container]);
	}
}
*/