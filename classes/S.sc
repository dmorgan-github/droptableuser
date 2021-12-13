/*
Synth
*/

S : Pdef {

    var <node, <cmdperiodfunc, <>color;
    var <>isMono=false, <synth;
    var <isMonitoring, <nodewatcherfunc;
    var <ptrnproxy, <metadata;

    *new {|key, synth|
        var res = Pdef.all[key];
        if (res.isNil) {
            res = super.new(key).prInit
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

    set {|...args|

        var controlKeys = this.node.controlKeys;
        Server.default.makeBundle(Server.default.latency, {
            var dict = args.asDict;
            var val = dict.select({|v, k| controlKeys.includes(k)  });
            node.set(*val.getPairs)
        });

        super.set(*args);
        ^this;
    }

    pset {|...args|
        this.ptrnproxy.set(*args);
    }

    synth_ {|synthname|
        this.prInitSynth(synthname);
    }

    fx {|index, fx, wet=1|
        this.node.fx(index, fx, wet);
    }

    fxchain {
        ^this.node.fxchain
    }

    controlKeys {|except|
        var keys = envir.keys(Array).sort;
        except = except ++ [];
        ^keys.reject({|key|
            except.includes(key)
        })
    }

    view {
        ^U(\sgui, this)
    }

    kill {|ids|
        ids.asArray.do({|id|
            Synth.basicNew(this.synth, Server.default, id).free
        });
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
                }),
                // enable some aliases
                \degree, Pfunc({|evt| if (evt[\deg].notNil) {evt[\deg]} {evt[\degree]} }),
                \octave, Pfunc({|evt| if (evt[\oct].notNil) {evt[\oct]} {evt[\octave]} }),
                \legato, Pfunc({|evt| if (evt[\leg].notNil) {evt[\leg]} {evt[\legato]} }),
                \mtranspose, Pfunc({|evt| if (evt[\mtrans].notNil) {evt[\mtrans]} {evt[\mtranspose]} }),
                \sustain, Pfunc({|evt| if (evt[\sus].notNil) {evt[\sus]} {evt[\sustain]} })
            ),
            ptrnproxy,
            pattern,
            Pbind(
                \out, Pfunc({node.bus.index}),
                \group, Pfunc({node.group}),
            )
        );

        super.source = PfsetC({ { this.changed(\stop) } },
            Plazy({

                synth = synth ?? {\default};

                if (isMono) {
                    Pmono(synth, \trig, 1) <> chain
                }{
                    Pbind() <> chain
                }
            })
        );

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
        node = D("%_chain".format(this.key).asSymbol);
        node.color = color;
        node.addDependant(nodewatcherfunc);

        node.play;
        ptrnproxy = PbindProxy();
        super.source = Pbind();
        this.set(\amp, -12.dbamp);
        this.quant = 4.0;

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
        var synthdef;
        synth = argSynth;

        synthdef = SynthDescLib.global.at(synth);
        if (synthdef.isNil) {
            synth = \default;
            synthdef = SynthDescLib.global.at(synth);
        };

        synthdef
        .controls.reject({|cn|
            [\freq, \pitch, \trigger, \trig,
                \in, \buf, \gate, \glis, \bend, \out].includes(cn.name.asSymbol)
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

        metadata = synthdef.metadata;
        if (metadata.notNil and: {metadata[\specs].notNil} ) {
            metadata[\specs].keysValuesDo({|k, v|
                this.addSpec(k, v);
            })
        };

        this.getSpec.keys.do({|key|
            var spec = this.getSpec[key];
            this.set(key, spec.default);
        });

        this.set(\instrument, synth);
        this.set(\root, 0, \mtranspose, 0, \legato, 0.7);

    }

    *initClass {
    }
}


