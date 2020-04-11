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

+ Array {
	pseq {arg repeats=inf, offset=0; ^Pseq(this, repeats, offset) }
	prand {arg repeats=inf; ^Prand(this, repeats) }
	pwrand {arg weights, repeats=inf; ^Pwrand(this, weights.normalizeSum, repeats)}
	dd {arg repeats=inf; ^Dd(this, repeats)}
	shuf {arg num=1, repeats=inf; ^Pn(Pshuf(this, num), repeats) }
}

+ Pattern {
	limit {arg num; ^Pfin(num, this.iter) }
	step {arg dur, repeats=inf; ^Pstep(this, dur, repeats)}
	latchprob {arg prob=0.5; ^Pclutch(this, Pfunc({ if (prob.coin){0}{1} }))}
	latch {arg func; ^Pclutch(this, Pfunc(func)) }
	dd {arg repeats=inf; ^Dd(this, repeats)}
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