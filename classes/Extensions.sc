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
	dd {arg repeats=inf; ^Dd(this, repeats)}
	pshuf {arg num=1, repeats=inf; ^Pn(Pshuf(this, num), repeats) }
}

+ Pattern {
	limit {arg num; ^Pfin(num, this.iter) }
	step {arg dur, repeats=inf; ^Pstep(this, dur, repeats)}
	latchprob {arg prob=0.5; ^Pclutch(this, Pfunc({ if (prob.coin){0}{1} }))}
	latch {arg func; ^Pclutch(this, Pfunc(func)) }
	dd {arg repeats=inf; ^Dd(this, repeats)}
}

+ NodeProxy {
	ngui {
		^U(\ngui, this);
	}
	mix {arg index=0, obj, stopmonitor=false;

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
					var l = (key ++ 'L').asSymbol;
					var r = (key ++ 'R').asSymbol;
					this.put(index, { obj.node.ar * Control.names([key]).kr(1.0) });
					if (stopmonitor) {
						obj.node.stop;
					}
				}{
					var l = (key ++ 'L').asSymbol;
					var r = (key ++ 'R').asSymbol;
					this.put(index, {obj.ar * Control.names([key]).kr(1.0) });
					if (stopmonitor) {
						obj.stop;
					}
				}
			}
		};
	}
	nscope {
		^U(\scope, this);
	}
}

+ S {
	kb {
		^U(\kb, this);
	}
	gui {
		^U(\sgui, this);
	}
	scope {
		^U(\scope, this.node);
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