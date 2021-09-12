/*
Synth
*/

S : Pdef {

    var <node, <cmdperiodfunc, <>color;
    var <isMono=false, <instrument;
    var <isMonitoring, <nodewatcherfunc;

    *new {|key|
        var res = Pdef.all[key];
        if (res.isNil) {
            res = super.new(key).prInit.synth(key);
        };

        ^res;
    }

    *doesNotUnderstand {|key|
		var res = Pdef.all[key];
		if (res.isNil){
			res = S(key);
		};
		^res;
	}

    @ {|val, adverb|

        if (adverb.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            this.set(adverb, val);
        }
    }

    synth {|synth, template=\adsr|
        this.prInitSynth(synth, template);
    }

    mono {|synth, template=\mono|
        isMono = true;
        this.prInitSynth(synth, template);
    }

    fx {|index, fx, wet=1|
        this.node.fx(index, fx, wet);
    }

    vstctrls {
        ^this.node.vstctrls
    }

    view {
        U(\sgui, this)
    }

    out {
        ^this.node.monitor.out
    }

    out_ {|bus|
        this.node.monitor.out = bus
    }

    source_ {|pattern|

        var chain = Pchain(
            Pbind(
                // not sure of the implications with multichannel expansion
                \node_set, Pfunc({|evt|
                    Server.default.makeBundle(Server.default.latency, {
                        var current = evt;
                        var exceptArgs = current[\exceptArgs];
                        var args = node.controlKeys(except: exceptArgs);
                        current = current.select({|v, k| args.includes(k) });
                        node.set(*current.getPairs)
                    })
                })
            ),
            pattern,
            Pbind(
                \out, Pfunc({node.bus.index}),
                \group, Pfunc({node.group})
            )
        );

        super.source = Plazy({
            if (isMono) {
                Pmono(instrument, \trig, 1) <> chain
            }{
                chain
            }
        });
    }

    prInit {
        clock = W.clock;
        color = Color.rand;
        nodewatcherfunc = {|obj, what|
            if ((what == \play) or: (what == \stop)) {
                isMonitoring = obj.isMonitoring
            }
        };
        node = D(this.key);
        node.addDependant(nodewatcherfunc);

        node.play;
        this.source = Pbind();
        //this.set(\nkey, this.key, \type, \composite, \types, [\note, \nset]);

        cmdperiodfunc = {
            {
                node.wakeUp;
                if (isMonitoring) {
                    \cmdperiod.debug(node.key);
                    node.play
                };
            }.defer(0.5)
        };
        ServerTree.add(cmdperiodfunc);
        ^this
    }

    prInitSynth {|argSynth, argTemplate=\adsr|
        var meta, synthdef;
        instrument = argSynth;
        //if (argSynth.isFunction) {
        //    instrument = "synth_%".format(this.key).asSymbol;
        //    S.def(instrument, argSynth, argTemplate);
        //};

        synthdef = SynthDescLib.global.at(instrument);
        if (synthdef.isNil) {
            instrument = \default;
            synthdef = SynthDescLib.global.at(instrument);
        };

        synthdef
        .controls.reject({|cn|
            [\freq, \pitch, \trigger, \trig, \in, \buf, \gate, \glis, \bend].includes(cn.name.asSymbol)
        }).do({|cn|
            var key = cn.name.asSymbol;
            var spec = Spec.specs[key];
            if (spec.notNil) {
              this.addSpec(key, spec);
            }
        });

        meta = synthdef.metadata;
        if (meta.notNil and: {meta[\specs].notNil} ) {
            meta[\specs].keysValuesDo({|k, v|
                this.addSpec(k, v);
            })
        };

        this.set(\instrument, instrument);
    }

    *initClass {
        /*
        Event.addEventType(\nset, {|server|
          ~id = Ndef(~nkey).nodeID;
          ~args = Ndef(~nkey).controlKeys(except: ~exceptArgs);
          ~eventTypes[\set].value(~server);
        });
        */
    }
}


SynthLib {

    var <func, <specs, <name;

    *new {|key|
        ^super.new.prInit(key);
    }

    prInit {|key|
        var path = App.librarydir ++ key.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;
        name = pathname.fileNameWithoutExtension.asSymbol;

        if (File.exists(fullpath)) {
            var name = pathname.fileNameWithoutExtension;
            var obj = File.open(fullpath, "r").readAllString.interpret;
            func = obj[\synth];
            specs = obj[\specs];
        } {
            Error("node not found").throw;
        }
        ^this;
    }

    toSynthDef {|template=\adsr|
        SynthLib.def(this.name, this.func, template, this.specs)
    }

    *def {|inKey, inFunc, inTemplate=\adsr, specs|
        var path = App.librarydir ++  "templates/" ++ inTemplate.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;

        if (File.exists(fullpath)) {
            var template = File.open(fullpath, "r").readAllString.interpret;
            template.(inKey, inFunc, specs);
        } {
            Error("synth template not found").throw;
        };
    }

    *printSynths {
        SynthDescLib.all[\global].synthDescs
        .keys
        .reject({|key|
            key.asString.beginsWith("system") or: key.asString.beginsWith("pbindFx_")
        })
        .asArray
        .sort
        .do({|val| val.postln})
    }

    *printSynthControls {|synth|
        SynthDescLib.all[\global]
        .synthDescs[synth]
        .controls.do({|cn|
            [cn.name, cn.defaultValue].postln
        });
    }
}



