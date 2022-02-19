/*
Synth
*/

/*
nice colors:
Color(0.60549101829529, 0.63466150760651, 0.86493694782257, 0.2)
Color(0.55233793258667, 0.65434362888336, 0.71119487285614, 0.2)
Color(0.77472245693207, 0.82329275608063, 0.75887560844421, 0.2)
Color(0.67403962612152, 0.74898204803467, 0.83484077453613, 0.2)
Color(0.43814084529877, 0.35949912071228, 0.8521347284317, 0.2)
Color(0.60353236198425, 0.85716576576233, 0.54857833385468, 0.2)
Color(0.84560143947601, 0.71142382621765, 0.53232064247131, 0.2)
Color(0.75822179317474, 0.58384845256805, 0.37344696521759, 0.2)
Color(0.46127707958221, 0.63891048431396, 0.49481935501099, 0.2)
Color(0.7760725736618, 0.79725716114044, 0.52006945610046, 0.2)
Color(0.61446368694305, 0.50829205513, 0.49966106414795, 0.2)
Color(0.68937842845917, 0.80199530124664, 0.8592972278595, 0.2)
Color(0.74614992141724, 0.8588672876358, 0.77721869945526, 0.2)
Color(0.67358100414276, 0.74493434429169, 0.40996670722961, 0.2)
*/
S : Pdef {

    var <node, <cmdperiodfunc, <>color;
    var <>isMono=false, <synth;
    var <isMonitoring, <nodewatcherfunc;
    var /*<ptrnproxy,*/ <metadata, <controlNames;

    *new {|key, synth|
        var res = Pdef.all[key];
        if (res.isNil) {
            res = super.new(key).prInit
        };
        if (synth.notNil) {
            res.synth = synth;
        };
        currentEnvironment[key] = res;
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
            var val = dict.select({|v, k| controlKeys.includes(k) });
            node.set(*val.getPairs);

            // this will update the settings on already playing
            // synths, otherwise you have to wait until the next
            // event
            if (controlNames.notNil) {
                val = dict.select({|v, k| controlNames.includes(k) });
                node.group.set(*val.getPairs);
            }
        });

        super.set(*args);
        ^this;
    }

    /*
    pset {|...args|
        this.ptrnproxy.set(*args);
    }
    */

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

    drone {
        var drone = this.envir.copy;
        drone['out'] = this.node.bus.index;
        drone['group'] = this.node.group;
        drone['sustain'] = inf;
        ^drone
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

    print {
        //this.envir.copy.parent_(nil).getPairs.asCode.postln;
        "(\nS('%').set(".format(this.key).postln;
        this.envir.copy.parent_(nil)
        .getPairs
        .pairsDo({|k, v|
            "\t".post;
            k.asCode.post;
            ", ".post;
            v.asCode.post;
            ",".postln;
        });
        ")\n)".postln;

        this.node.print;
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
                //\degree, Pfunc({|evt| if (evt[\deg].notNil) {evt[\deg]} {evt[\degree]} }),
                //\octave, Pfunc({|evt| if (evt[\oct].notNil) {evt[\oct]} {evt[\octave]} }),
                //\legato, Pfunc({|evt| if (evt[\leg].notNil) {evt[\leg]} {evt[\legato]} }),
                //\mtranspose, Pfunc({|evt| if (evt[\mtrans].notNil) {evt[\mtrans]} {evt[\mtranspose]} }),
                //\sustain, Pfunc({|evt| if (evt[\sus].notNil) {evt[\sus]} {evt[\sustain]} })
            ),
            //ptrnproxy,
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
        //ptrnproxy = PbindProxy();
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
            }/* {
                var default = cn.defaultValue;
                var spec = [0, default*2, \lin, 0, default].asSpec;
                this.addSpec(key, spec);
            }*/
        });

        metadata = synthdef.metadata;
        if (metadata.notNil and: {metadata[\specs].notNil} ) {
            metadata[\specs].keysValuesDo({|k, v|
                this.addSpec(k, v);
            })
        };

        if (this.getSpec.notNil) {
            this.getSpec.keys.do({|key|
                var spec = this.getSpec[key];
                this.set(key, spec.default);
            });
        };

        controlNames = SynthDescLib.global.at(synth).controlNames;

        this.set(\instrument, synth, \spread, 1, \pan, 0);
    }

    *initClass {
    }
}


