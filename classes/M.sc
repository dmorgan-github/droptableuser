// module
Module {

    var <>envir, <>libfunc, <fullpath, <props, <view, <doc;

    *new {|key|
        var res;
        res = super.new.prInit(key);
        ^res;
    }

    *exists {|key|
        var path = App.librarydir ++ key.asString ++ ".scd";
        ^File.exists(path.standardizePath);
    }

    value {|...args|
        ^this.func.value(*args)
    }

    func {
        // NOTE: func.inEnvir won't work with Ndef sources
        // unless you wrap it in another function or create a synthdef first
        // there must be some kind of conflict with environments
        // it works ok with filters but just not with sources
        ^libfunc.inEnvir(envir)
    }

    func_ {|val|
        libfunc = val
    }

    // TODO: need to change so that it is aligned
    // with set and put in M subclass
    put {|key, val|
        envir.put(key, val);
        ^this
    }

    putAll {|... dictionaries|
		dictionaries.do {|dict|
			dict.keysValuesDo {|key, value|
				this.put(key, value)
			}
		}
	}

    *ls {|path|

        var fullpath = App.librarydir ++ (path ?? {"synth"});
        var pn = PathName(fullpath);
        pn.entries.do({|obj|
            if ( obj.isFolder ) {
                "%/".format(obj.folderName).postln
            }{
                obj.fileName.postln;
            }
        })
    }

    open {
        if (fullpath.notNil) {
            Document.open(fullpath)
        } {
            "module file not loaded".warn
        }
    }

    prInit {|key|

        envir = ();

        if (key.isKindOf(Function)) {
            key.asCode.debug("module");
            libfunc = key
        }{
            if (key.notNil) {
                var path = App.librarydir ++ key.asString ++ ".scd";
                var pathname = PathName(path.standardizePath);
                fullpath = pathname.fullPath.debug("module");

                if (File.exists(fullpath)) {
                    var file = File.open(fullpath, "r");
                    var obj = file.readAllString.interpret;
                    libfunc = obj[\synth] ?? {obj[\func]};
                    props = obj['props'];
                    view = obj['view'];
                    doc = obj['doc'];
                    file.close;
                } {
                    Error("% node not found".format(key)).throw;
                }
            }
        }

        ^this;
    }
}

Ui : Module {

    *new {|key|
        var res;
        key = "ui/%".format(key).asSymbol;
        res = super.new(key);
        ^res;
    }

    view {|...args|
        ^this.value(*args);
    }

    gui {|...args|
        ^this.view(*args).front
    }

}

// ~sd.synthdef.dump
// ~sd.synthdef.dumpUGens
M : Module {

    var <synthdef, <synthname;
    var <modules;
    var <metadata;

    *new {
        var res;
        res = super.new().prMInit();
        ^res;
    }

    at {|num|
        ^modules[num];
    }

    set {|key, val|
        super.put(key, val);
        this.changed(\set, [key, val]);
    }
   
    put {|num, val|

        var key, mod;
        mod = val;

        if (val.isKindOf(Association)) {

            key = val.key;
            mod = val.value;

            if (mod.isKindOf(Array)) {
                var props, temp;
                temp = mod[0];
                props = mod[1..].asDict;
                mod = temp;
                this.envir.putAll(props);
            };

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

            if (mod.isKindOf(Module).not) {
                var doc, key = mod;
                mod = Module(mod);
                doc = mod.doc;
                if (doc.notNil) {
                    metadata.put(key, doc);
                }
            };
            if (mod.props.notNil) {
                envir.putAll(mod.props);
            };
            modules.put(num, key -> mod);
            this.changed(\put, [num, key, mod]);
        } {
            if (val.isNil) {
                modules.put(num, nil);
                envir.put(num, nil);
            } {
                envir.put(num, val)
            };
            this.changed(\put, [num, val]);
        };
    }

    removeAt {|num|
        if (modules[num].notNil) {
            modules.removeAt(num);
            this.changed(\put, [num, nil])
        }
    }

    add {|name|

        var sampleaccurate = envir['sampleaccurate'] ?? false;
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

        "synthdef added".debug(name);

        ^this;
    }

    *synthDesc {|name|
        ^SynthDescLib.global[name];
    }

    prMInit {

        modules = Order();
        metadata = Dictionary.new;
        synthname = "synth_%".format(UniqueID.next).asSymbol;

        this.libfunc = {
            // TODO: this might be easier
            // sendGate
            // Override SynthDef behavior for the gate argument. 
            // If the SynthDef as gate, setting sendGate = false prevents the release message from being sent.
            var currentEnvir;
            var gatemode = ~gatemode;
            var detectsilence = ~detectsilence ?? false;
            var gate = DC.kr(1), vel;
            var sig, filt, sigs = List.new, filts = List.new;
            var out, freq, env, doneaction;
            var hasgate;

            if (gatemode.debug("gate mode") == \retrig) {
                var killgate = \gate.kr(1);
                Env.asr(0.0, 1, \rel.kr(1)).kr(doneAction:Done.freeSelf, gate:killgate);
                doneaction = Done.none;
                gate = \trig.tr(0);
            }{
                hasgate = ~hasgate ?? true;
                hasgate.debug("hasgate");
                if (hasgate) {
                    // this is a trick to ensure the gate is opened
                    // before being closed if there is a race condition
                    gate = \gate.kr(1) + Impulse.kr(0);
                } {
                    gate = DC.kr(1);
                };
                doneaction = Done.freeSelf;
            };

            vel = \vel.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1));
            freq = Module('pitch/freq');
            env = Module('env/asr');
            out = Module('out/splay');

            modules.do({|val, index|
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
                            sigs.add( mod );
                        }
                    )
                }
            });

            currentEnvir = envir.copy ++ ('gatemode': gatemode);
            freq = freq.putAll(currentEnvir).func;
            env = env.putAll(currentEnvir).func;
            out = out.putAll(currentEnvir).func;

            freq = freq.(gate);
            env = env.(gate, doneaction);
            currentEnvir = currentEnvir ++ ('freq': freq, gate: gate, vel: vel);

            sig = {|freq, gate|
                var snd = 0;
                if (sigs.size > 0) {
                    sigs.do({|m|
                        m.putAll(currentEnvir);
                        snd = snd + m.func.(freq, gate);
                    });
                } {
                    snd = Module({|freq, gate| SinOsc.ar(freq) }).func.(freq, gate)
                };
                snd
            };

            filt = {|sig, gate, freq, env|
                filts.do({|m|
                    m.putAll(currentEnvir);
                    sig = m.(sig, gate, freq, env);
                });
                sig;
            };

            sig = sig.(freq, gate);
            if (envir.freeself.debug("freeself").isNil) {
                sig = sig * env;
            };
            sig = LeakDC.ar(sig);
            sig = filt.(sig, gate, freq, env);
            sig = LeakDC.ar(sig);
            sig = sig * AmpCompA.ar(freq, 0) * \amp.kr(-20.dbamp) * vel;
            sig = sig * env;

            if (detectsilence) {
                detectsilence.debug("detect silence");
                DetectSilence.ar(in: sig, amp: 0.00025, doneAction:Done.freeSelf);
            };

            sig = out.(sig);
            sig;
        };

        ^this;
    }
}

