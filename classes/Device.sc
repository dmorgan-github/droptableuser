// TODO: inherit from NodeProxy instead of Ndef
Device : Ndef {

	*new {|key|

        var mykey = key ?? {"n_%".format(UniqueID.next).asSymbol};
		var envir = this.dictFor(Server.default).envir.postln;
		var res = envir[mykey];

		if (res.isNil) {
			res = this.createNew(mykey).deviceInit();

			res.wakeUp;
			res.ar(numChannels:2);
			res.play;
			res.vol = 1;
			res.postInit;

			ServerTree.add({
				\cmdperiod.debug(mykey);
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

	out_ {|bus=0|
		this.monitor.out = bus;
	}
}