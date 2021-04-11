D : NodeProxy {

    classvar <all;

    var <>key;

    *new {|key|

        var res;

        if (key.isNil) {
            Error("key is required").throw;
        };

        res = all[key];

        if (res.isNil) {

            res = super.new(Server.default, rate:\audio, numChannels:2)
            .prInit(key);

            res.wakeUp;
            res.vol = 1;
            res.postInit;

            res.filter(1000, {|in|
               var sig = Select.ar(CheckBadValues.ar(in, 0, 0), [in, DC.ar(0), DC.ar(0), in]);
               Limiter.ar(sig);
            });

            ServerTree.add({
                \cmdperiod.debug(key);
                res.send;
            });

            // if we're using a synthdef as a source
            // copy the specs if they are defined
            res.addDependant({|node, what, args|
                if (what == \source) {
                    var obj = args[0];
                    //"source detected".debug(key);
                    if (obj.isKindOf(Symbol)) {
                        var def = SynthDescLib.global.at(obj);
                        if (def.notNil) {
                            if (def.metadata.notNil and: {def.metadata[\specs].notNil}) {
                                "adding specs from % synthdef".format(obj).debug(key);
                                def.metadata[\specs].keysValuesDo({|k, v|
                                    node.addSpec(k, v.asSpec);
                                });
                            }
                        }
                    }
                }
            });

            all[key] = res;
        };

        ^res;
    }

    prInit {|argKey|
        key = argKey;
        ^this.deviceInit
    }

	*doesNotUnderstand {|selector|
		^this.new(selector);
	}

    deviceInit {
        // override to initialize
    }

    postInit {
        // override to initialize after init
    }

    out_ {|bus=0|
        this.monitor.out = bus;
    }

    *initClass {
        all = IdentityDictionary.new;
    }
}