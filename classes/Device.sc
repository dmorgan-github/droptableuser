// TODO: inherit from NodeProxy instead of Ndef
Device : Ndef {

	*new {|key|

        var mykey = key ?? {"n_%".format(UniqueID.next).asSymbol};
		var envir = this.dictFor(Server.default).envir;
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

	/*
	should come from NodeProxy extension
	getSettings {
		^this.getKeysValues.flatten.asDict;
	}
	*/

    /*
	addPreset {|num|
		P.addPreset(this, num, this.getSettings);
	}

	loadPreset {|num|
		var preset = P.getPreset(this, num);
		this.set(*preset.getPairs);
	}

	getPresets {
		^P.getPresets(this);
	}

	morph {|from, to, numsteps=20, wait=0.1|
		P.morph(this, from, to, numsteps, wait);
	}
    */

	/*
	NOTE: defined extension on NodeProxy for view
	override on subclass
	view {}
	*/
}