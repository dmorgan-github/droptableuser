
// ~sd.synthdef.dump
// ~sd.synthdef.dumpUGens
SynthDefModule : Module {

    classvar <>defaultFunc;

    var <synthdef, <synthname, <synthdesc;
    var <modules;
    var <metadata;

    *new {
        var res;
        res = super.new().prSynthModuleInit();
        ^res;
    }

    evaluate {|val|

        var func;

        func = {|role, module|

            var myrole = role.asString;

            if ( "^(sig)([0-9]*)$|^(fil)([0-9]*)$|^(aeg)$|^(pit)$|^(voices)$".matchRegexp(myrole) ) {

                var result, index = 0;
                result = myrole.findRegexp("^(sig)([0-9]*)$");
                if (result.size > 0) {
                    index = if (result[2].size > 1) { result[2][1].asInteger };
                    if (module.isNil) {
                        "removing sig".debug("InstrProxyObserver");
                        this.removeAt(index)
                    }{
                        if (module.isKindOf(Function)) {
                            module = Module(module)
                        };
                        this.put(index, \sig -> module);  
                    }
                    
                };

                result = myrole.findRegexp("^aeg$");
                if (result.size > 0) {
                    if (module.isNil) {
                        "removing aeg".debug("InstrProxyObserver");
                        this.removeAt(10)
                    }{
                        if (module.isKindOf(Function)) {
                            module = Module(module)
                        };
                        this.put(10, \env -> module);  
                    }
                };

                result = myrole.findRegexp("^(fil)([0-9]*)$");
                if (result.size > 0) {
                    index = if (result[2].size > 1) { result[2][1].asInteger };
                    index = 20 + index;
                    if (module.isNil) {
                        "removing filter".debug("InstrProxyObserver");
                        this.removeAt(index)
                    }{
                        if (module.isKindOf(Function)) {
                            module = Module(module)
                        };
                        this.put(index, \fil -> module);  
                    }
                };

                result = myrole.findRegexp("^pit$");
                if (result.size > 0) {
                    if (module.isNil) {
                        "removing pitch model".debug("InstrProxyObserver");
                        this.removeAt(30)
                    }{
                        if (module.isKindOf(Function)) {
                            module = Module(module)
                        };
                        this.put(30, \pit -> module);  
                    }
                };

                result = myrole.findRegexp("^voices$");
                if (result.size > 0) {
                    if (module.isKindOf(Function)) {
                        module = Module(module)
                    };
                    this.set(\voices, module)
                };
            }
        };

        val.keysValuesDo({|k, v|
            func.(k, v)
        });
    }

    at {|num|
        ^modules[num];
    }  

    put {|num, val|

        if (val.isNil) {
            this.removeAt(num)
        } {

            var key, mod;
            mod = val;

            if (val.isKindOf(Association)) {

                key = val.key;
                mod = val.value; 

                // is this safe?
                if (currentEnvironment[mod.asSymbol].notNil) {
                    // TODO: addFunc
                    if (currentEnvironment[mod.asSymbol].isKindOf(Function)) {
                         mod = topEnvironment[mod.asSymbol];
                    }{
                        "% is not a function".format(key).throw
                    }
                } {
                    switch(key,
                        \pit, {
                            if (mod.isKindOf(Symbol)) {
                                mod = "pitch/%".format(mod).asSymbol;
                            };
                        },
                        \fil, {
                            if (mod.isKindOf(Symbol)) {
                                mod = "filter/%".format(mod).asSymbol;
                            };
                        },
                        \env, {
                            if (mod.isKindOf(Symbol)) {
                                mod = "env/%".format(mod).asSymbol;
                            };
                        },
                        \out, {
                            if (mod.isKindOf(Symbol)) {
                                mod = "out/%".format(mod).asSymbol;
                            };
                        },
                        \sig, {
                            if (mod.isKindOf(Symbol)) {
                                mod = "synth/%".format(mod).asSymbol;
                            };
                        }
                    );
                };

                if (mod.isKindOf(Module).not) {
                    var doc, key = mod;
                    mod = Module(mod);
                    doc = mod.doc;
                    if (doc.notNil) {
                        metadata.put(key, doc);
                    }
                };
                if (mod.props.notNil) {
                    this.setAll(mod.props);
                };
                modules.put(num, key -> mod);
                this.changed(\put, [num, key, mod]);
            }{
                "association not specified".warn
            } 
        }
    }

    removeAt {|num|
        if (modules[num].notNil) {
            modules.removeAt(num);
            this.changed(\put, [num, nil])
        }
    }

    add {|name|

        var sampleaccurate; 
        this.modules.do({|m| m.value.fullpath.debug("synthdefmodule") });

        sampleaccurate = envir['sampleaccurate'] ?? false;
        name = name ?? synthname;
        synthdef = SynthDef(name.asSymbol, {
            var sig = this.func;
            sig = sig.();
            if (sampleaccurate.debug("sampleaccurate")) {
                OffsetOut.ar(\out.kr(0), sig);
            }{
                Out.ar(\out.kr(0), sig);
            };
        }, metadata: envir).add;

        {
            synthdesc = SynthDescLib.global[name];
        }.defer(1);

        "synthdef added".debug(name);

        ^this;
    }

    visualize {
        SynthDefModule.visualize(synthdef);
    }

    *visualize {|synthdef|

        // this has a lot of dependencies
        // https://fredrikolofsson.com/f0blog/one-reason-why-i-love-sc/
        if (synthdef.respondsTo(\dot)) {
            var platform;
            var f, fn;
            fn = "/tmp/sc3-dot.dot";
            
            fork {

                f = File.new(fn, "w");
                synthdef.dot(f);
                f.close;
    
                if (thisProcess.platform.name == \osx) {
                    "dot -Tpdf % -o %.pdf".format(fn, fn).systemCmd;
                    "open %.pdf".format(fn).systemCmd;
                } {
                    RDot.view(fn);
                }  
            };
        } {
            "RDot quark not installed".warn
        }
    }

    *synthDesc {|name|
        ^SynthDescLib.global[name];
    }

    prSynthModuleInit {

        modules = Order();
        metadata = Dictionary.new;
        synthname = "synth_%".format(UniqueID.next).asSymbol;
        this.libfunc = defaultFunc;
        ^this;
    }

    *initClass {

        defaultFunc = {
            var me = ~module;
            var currentEnvir;
            var voices = ~voices;
            var detectsilence = ~detectsilence ?? false;
            var gate = DC.kr(1), vel;
            var sig, sigs = List.new, filts = List.new;
            var out, freq, env, doneaction;
            var hasgate;

            //if (gatemode.debug("gate mode") == \retrig) {
            if (voices.debug("voices") == \mono) {
                // for monosynths
                var killgate = \gate.kr(1);
                Env.asr(0.0, 1, \rel.kr(1)).kr(doneAction:Done.freeSelf, gate:killgate);
                doneaction = Done.none;
                gate = \trig.tr(0);
            }{
                hasgate = ~hasgate ?? true;
                if (hasgate.debug("hasgate")) {
                    // this is a trick to ensure the gate is opened
                    // before being closed if there is a race condition
                    gate = \gate.kr(1) + Impulse.kr(0);
                } {
                    gate = DC.kr(1);
                };
                doneaction = Done.freeSelf;
            };

            vel = \vel.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1));
            // default modules
            freq = Module('pitch/freq');
            env = Module('env/adsr');
            out = Module('out/splay');

            me.modules.do({|val, index|
                if (val.isKindOf(Association)) {
                    var key = val.key;
                    var mod = val.value;
                    switch(key,
                        \pit, {
                            freq = mod;
                        },
                        \fil, {
                            filts.add(mod);
                        },
                        \env, {
                            env = mod
                        },
                        \out, {
                            out = mod
                        },
                        \sig, {
                            sigs.add(mod);
                        }
                    )
                }
            });

            currentEnvir = me.envir.copy ++ ('voices': voices);
            freq = freq.setAll(currentEnvir).(gate);
            env = env.setAll(currentEnvir).(gate, doneaction);
            out = out.setAll(currentEnvir).func;
            // add current values to environment
            currentEnvir = currentEnvir ++ ('freq': freq, gate: gate, vel: vel);

            // combine the signals
            sig = sigs.inject(Silent.ar, {|a, b|
                var mul = 1;//b.mul ?? 1;
                a + ( b.setAll(currentEnvir).(freq, gate, env) * mul.debug("mul") ) 
            });
            //sig = LeakDC.ar(sig);

            // filters get applied in serial
            sig = filts.inject(sig, {|a, b|
                b.setAll(currentEnvir).(a, gate, freq, env) 
            });

            sig = sig * env;
            sig = LeakDC.ar(sig);
            sig = sig * AmpComp.ar(freq, 110) * \amp.kr(-13.dbamp) * vel;
           
            if (detectsilence) {
                detectsilence.debug("detect silence");
                DetectSilence.ar(in: sig, amp: 0.00025, doneAction:Done.freeSelf);
            };

            sig = out.(sig);
            sig;
        }
    }
}
