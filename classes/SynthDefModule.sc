
// ~sd.synthdef.dump
// ~sd.synthdef.dumpUGens
SynthDefModule : Module {

    classvar <>defaultFunc;

    var <synthdef, <synthname, <synthdesc;
    var <modules;
    //var <metadata;

    *new {
        var res;
        res = super.new().prSynthModuleInit();
        ^res;
    }

    evaluate {|val|

        var func;

        func = {|role, module|

            var myrole = role.asString;

            var result, index = 0;
            result = myrole.findRegexp("^(sig)([0-9]*)$");
            if (result.size > 0) {
                index = if (result[2].size > 1) { result[2][1].asInteger };
                if (module.isNil) {
                    "removing sig".debug("SynthDefModule");
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
                    "removing aeg".debug("SynthDefModule");
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
                    "removing filter".debug("SynthDefModule");
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
                    "removing pitch model".debug("SynthDefModule");
                    this.removeAt(30)
                }{
                    if (module.isKindOf(Function)) {
                        module = Module(module)
                    };
                    this.put(30, \pit -> module);  
                }
            };

            result = myrole.findRegexp("^out$");
            if (result.size > 0) {
                if (module.isNil) {
                    "removing out model".debug("SynthDefModule");
                    this.removeAt(40)
                }{
                    if (module.isKindOf(Function)) {
                        module = Module(module)
                    };
                    this.put(40, \out -> module);  
                }
            };

            result = myrole.findRegexp("^voices$");
            if (result.size > 0) {
                if (module.isKindOf(Function)) {
                    module = Module(module)
                };
                this.set(\voices, module)
            };
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

                if (mod.isKindOf(Symbol)) {
                    switch(key,
                        \pit, { mod = "pitch/%".format(mod).asSymbol },
                        \fil, { mod = "filter/%".format(mod).asSymbol },
                        \env, { mod = "env/%".format(mod).asSymbol },
                        \out, { mod = "out/%".format(mod).asSymbol },
                        \sig, { mod = "synth/%".format(mod).asSymbol}
                    );
                };

                if (mod.isKindOf(Module).not) {
                    var doc, key = mod;
                    mod = Module(mod);
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
        var result = Deferred();

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
        }, metadata: envir)
        .add(completionMsg: {
            result.value = true;   
        });

        result.wait();
        synthdesc = SynthDescLib.global[name];
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
            var gate, vel;
            var sig, sigs = List.new, filts = List.new;
            var out, freq, env;

            //gate = \gate.kr(1) + Impulse.kr(0);
            //if (voices == 'mono') {
            //    gate = (1 - \trig.tr(0)) * gate
            //};
            
            vel = \vel.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1));

            me.modules.do({|val, index|
                if (val.isKindOf(Association)) {
                    var key = val.key;
                    var mod = val.value;
                    switch(key,
                        \pit, { freq = mod },
                        \fil, { filts.add(mod) },
                        \env, { env = mod },
                        \out, { out = mod },
                        \sig, { sigs.add(mod) }
                    )
                }
            });

            if (freq.isNil) {
                freq = Module('pitch/freq');
            };

            if (env.isNil) {
                env = Module('env/adsr');
            };

            if (out.isNil) {
                out = Module('out/pan2');
            };

            currentEnvir = me.envir.copy ++ ('voices': voices);
            env =  env.setAll(currentEnvir).();

            if (voices == 'mono') {
                gate = \gate.kr(1) + Impulse.kr(0);
                gate = (1 - \trig.tr(0)) * gate
            }{
                if (env.releaseNode.isNil) {
                    gate = 1;
                }{
                    gate = \gate.kr(1) + Impulse.kr(0);   
                }
            };

            if (env.isKindOf(Env)) { 
                env = EnvGen.ar(env, gate, doneAction:Done.freeSelf);
            };
            freq = freq.setAll(currentEnvir).(gate);
            out = out.setAll(currentEnvir).func;
            // add current values to environment
            //currentEnvir = currentEnvir ++ ('freq': freq, gate: gate, vel: vel);

            // combine the signals
            sig = sigs.inject(Silent.ar, {|a, b|
                var mul = 1;//b.mul ?? 1;
                a + ( b.setAll(currentEnvir).(freq, gate, env) * mul ) 
            });

            // filters get applied in series
            sig = filts.inject(sig, {|a, b|
                b.setAll(currentEnvir).(a, gate, freq, env) 
            });

            sig = sig * env;
            sig = LeakDC.ar(sig);
            sig = sig * AmpCompA.ar(freq) * \amp.kr(-13.dbamp) * vel;
           
            if (detectsilence) {
                detectsilence.debug("detect silence");
                DetectSilence.ar(in: sig, amp: 0.00025, doneAction:Done.freeSelf);
            };

            sig = out.(sig);
            sig;
        }
    }
}
