/*
NOTE: can record with nodeproxy
https://doc.sccode.org/Classes/RecNodeProxy.html
*/
D : NodeProxy {

    classvar <all, <defaultout;

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
                Limiter.ar(LeakDC.ar(sig));
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

            res.monitor.out = defaultout;
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


    rec {|beats=4, preLevel=0, cb|

        // how to coordinate clocks?
        var clock = TempoClock.default;
        var seconds = clock.beatDur * beats;
        var buf = B.alloc(this.key, seconds * Server.default.sampleRate, 1);
        var bus = this.bus;
        var group = this.group;

        clock.schedAbs(clock.nextTimeOnGrid(1), {

            var synth = Synth(\rec, [\buf, buf, \in, bus, \preLevel, preLevel, \run, 1], target:group, addAction:\addToTail);
            synth.onFree({
                {
                    cb.(buf);
                }.defer
            });
            nil;
        });
    }

    *initClass {

        all = IdentityDictionary.new;
        defaultout = 4;

        StartUp.add({
            SynthDef(\rec, {
                var buf = \buf.kr(0);
                var in = In.ar(\in.kr(0), 2).asArray.sum;
                var sig = RecordBuf.ar(in, buf,
                    \offset.kr(0),
                    \recLevel.kr(1),
                    \preLevel.kr(0),
                    \run.kr(1),
                    \loop.kr(0),
                    1,
                    doneAction:Done.freeSelf);
                Out.ar(0, Silent.ar(2));
            }).add;

        });
    }
}