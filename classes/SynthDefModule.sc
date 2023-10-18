
// ~sd.synthdef.dump
// ~sd.synthdef.dumpUGens
SynthDefModule : DMModule {

    classvar <>defaultFunc;

    var <synthdef, <synthname, <synthdesc;
    var <modules;
    var <metadata;

    *new {
        var res;
        res = super.new().prSynthModuleInit();
        ^res;
    }

    parse {|str|

        var result;
        var parsestr = {|str|

            var exec, match;
            var getNextToken;
            var hasMoreTokens;
            var spec;
            var cursor = 0;

            // as pairs
            // "# unison numvoices=8 + squine + pluck > moogff > distort * perc : splay"
            // sig pluck sig squine env perc fil moog pit unison numvoices=8 exciter={Impulse.ar(0)*0.5} fil dfm1
            spec = [
                'sig', "^sig",
                'sig', "^\\+",
                'env', "^env",
                'env', "^\\*",
                'fil', "^fil",
                'fil', "^>",
                'out', "^out",
                'out', "^:",
                'pit', "^pit",
                'pit', "^#",
                'string', "^[a-zA-Z0-9!-\/:-@[-`{-~]+",
                nil, "^\\s+",
                nil, "^\,",
            ];

            hasMoreTokens = {
                cursor < str.size;
            };

            match = {|regex, str|
                var val = nil;
                var m = str.findRegexp(regex);
                if (m.size > 0) {
                    val = m[0][1];
                    cursor = cursor + val.size;
                };
                val;
            };

            getNextToken = {
                var getNext;
                var result = nil;
                getNext = {
                    if (hasMoreTokens.()) {
                        spec.pairsDo({|k, v|
                            if (result.isNil) {
                                var val = match.(v, str[cursor..]);
                                //[k, v, val].debug("match");
                                if (val.notNil) {
                                    if (k.isNil) {
                                        getNext.()
                                    }{
                                        result = (
                                            type: k,
                                            val: val
                                        );
                                    }
                                }
                            }
                        });
                    };
                };

                getNext.();

                if (result.isNil) {
                    "unexpected token %".format(str[cursor]).throw
                };
                result;
            };

            exec = {|list|

                var exit = false;
                var context;
                while ({ hasMoreTokens.() and: { exit.not } }, {
                    var token = getNextToken.();
                    //token.debug("token");
                    switch(token['type'],
                        // entities
                        'sig', {
                            context = list[\sig]
                        },
                        'env', {
                            context = list[\env]
                        },
                        'fil', {
                            context = list[\fil]
                        },
                        'out', {
                            context = list[\out]
                        },
                        'pit', {
                            context = list['pit']
                        },
                        'string', {
                            context.add(token['val'].asSymbol)
                        }
                    );
                });

                list;
            };
            exec.(
                (
                    sig: List.new,
                    env: List.new,
                    fil: List.new,
                    out: List.new,
                    pit: List.new
                )
            );
        };

        result = parsestr.(str);
        result.keysValuesDo({|k, v, i|
            var list = v;
            list.do({|val, j|
                var num = i * 10 + j;
                this.put(num, k -> val)
            });
        });
        ^this;
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

                if (mod.isKindOf(DMModule).not) {
                    var doc, key = mod;
                    mod = DMModule(mod);
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
        if (synthdef.respondsTo(\dot)) {
            var platform;
            var f, fn;
            fn = "/tmp/sc3-dot.dot";
            
            fork {

                // refactor to: https://github.com/scztt/Deferred.quark/blob/master/Deferred.sc
                await {|done|
                    f = File.new(fn, "w");
                    synthdef.dot(f);
                    f.close;
                    done.value(\ok);
                };

                if (thisProcess.platform.name == \osx) {
                    await{|done|
                        "dot -Tpdf % -o %.pdf".format(fn, fn).systemCmd;
                        done.value(\ok);
                    };
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
            var gatemode = ~gatemode;
            var detectsilence = ~detectsilence ?? false;
            var gate = DC.kr(1), vel;
            var sig, sigs = List.new, filts = List.new;
            var out, freq, env, doneaction;
            var hasgate;

            if (gatemode.debug("gate mode") == \retrig) {
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
            freq = DMModule('pitch/freq');
            env = DMModule('env/adsr');
            out = DMModule('out/splay');

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

            currentEnvir = me.envir.copy ++ ('gatemode': gatemode);
            freq = freq.setAll(currentEnvir).(gate);
            env = env.setAll(currentEnvir).(gate, doneaction);
            out = out.setAll(currentEnvir).func;
            // add current values to environment
            currentEnvir = currentEnvir ++ ('freq': freq, gate: gate, vel: vel);

            // combine the signals
            sig = sigs.inject(Silent.ar, {|a, b| 
                a + b.setAll(currentEnvir).(freq, gate, env);
            });
            //sig = LeakDC.ar(sig);

            // filters get applied in serial
            sig = filts.inject(sig, {|a, b|
                b.setAll(currentEnvir).(a, gate, freq, env) 
            });

            sig = sig * env;
            sig = LeakDC.ar(sig);
            sig = sig * AmpCompA.ar(freq, 0) * \amp.kr(-13.dbamp) * vel;
           
            if (detectsilence) {
                detectsilence.debug("detect silence");
                DetectSilence.ar(in: sig, amp: 0.00025, doneAction:Done.freeSelf);
            };

            sig = out.(sig);
            sig;
        }
    }
}
