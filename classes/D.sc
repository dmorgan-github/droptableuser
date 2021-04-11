D : NodeProxy {

    var <>key;

    *new {|key|

        var mykey = key ?? {"d_%".format(UniqueID.next).asSymbol};
        var res = super.new(Server.default, rate:\audio, numChannels:2).deviceInit().key_(mykey);
		res.wakeUp;
		res.vol = 1;
		res.postInit;
        ServerTree.add({
            \cmdperiod.debug(mykey);
            res.send;
        });
		^res;
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