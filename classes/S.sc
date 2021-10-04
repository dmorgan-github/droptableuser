/*
Synth
*/

S : Pdef {

    var <node, <cmdperiodfunc, <>color;
    var <isMono=false, <synth;
    var <isMonitoring, <nodewatcherfunc;
    var <ptrnproxy;

    *new {|key, synth|
        var res = Pdef.all[key];
        if (res.isNil) {
            var mysynth = synth ? key;
            res = super.new(key).prInit.synth_(mysynth);
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

    pset {|...args|
        this.ptrnproxy.set(*args);
    }

    synth_ {|synthname|
        if (synthname != synth) {
            // synth is already initialized
            this.prInitSynth(synthname);
        }
    }

    mono {|synthname, template=\mono|
        isMono = true;
        this.prInitSynth(synthname, template);
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
            ptrnproxy,
            pattern,
            Pbind(
                \out, Pfunc({node.bus.index}),
                \group, Pfunc({node.group})
            )
        );

        super.source = Plazy({
            if (isMono) {
                Pmono(synth, \trig, 1) <> chain
            }{
                chain
            }
        });

        ^this;
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
        ptrnproxy = PbindProxy();
        this.source = Pbind();
        this.set(\amp, -12.dbamp);

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

    prInitSynth {|argSynth|
        var meta, synthdef;
        synth = argSynth;

        synthdef = SynthDescLib.global.at(synth);
        if (synthdef.isNil) {
            "synth not found".debug(synth);
            synth = \default;
            synthdef = SynthDescLib.global.at(synth);
        };

        synthdef
        .controls.reject({|cn|
            [\freq, \pitch, \trigger, \trig, \in, \buf, \gate, \glis, \bend].includes(cn.name.asSymbol)
        }).do({|cn|
            var key = cn.name.asSymbol;
            var spec = Spec.specs[key];
            if (spec.notNil) {
                this.addSpec(key, spec);
            } {
                var default = cn.defaultValue;
                var spec = [0, default*2, \lin, 0, default].asSpec;
                this.addSpec(key, spec);
            }
        });

        meta = synthdef.metadata;
        if (meta.notNil and: {meta[\specs].notNil} ) {
            meta[\specs].keysValuesDo({|k, v|
                this.addSpec(k, v);
            })
        };

        this.getSpec.keys.do({|key|
            var spec = this.getSpec[key];
            this.set(key, spec.default);
        });

        this.set(\instrument, synth);
    }

    *initClass {
    }
}


