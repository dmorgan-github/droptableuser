// module
M {

    var <synthModule, <filterModule, <outModule, <pitchModule, <envModule;
    var <envir, <libfunc, <fullpath, <synthdef;

    *new {|key|
        var res;
        res = super.new.prInit(key);
        ^res;
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

    put {|key, val|
        envir.put(key, val);
        ^this
    }

    osc {|key, cb|
        if (key.isKindOf(Symbol)) {
            key = "synth/%".format(key).asSymbol;
        };
        synthModule = M(key);
        cb.(synthModule);
        ^this;
    }

    env {|key, cb|
        if (key.isKindOf(Symbol)) {
            key = "env/%".format(key).asSymbol;
        };
        envModule = M(key);
        cb.(envModule);
        ^this;
    }

    filter {|key, cb|
        if (key.isKindOf(Symbol)) {
            key = "filter/%".format(key).asSymbol;
        };
        filterModule = M(key);
        cb.(filterModule);
        ^this;
    }

    out {|key, cb|
        if (key.isKindOf(Symbol)) {
            key = "out/%".format(key).asSymbol;
        };
        outModule = M(key);
        cb.(outModule);
        ^this;
    }

    pitch {|key, cb|
        if (key.isKindOf(Symbol)) {
            key = "pitch/%".format(key).asSymbol;
        };
        pitchModule = M(key);
        cb.(pitchModule);
        ^this;
    }

    def {|name|

        synthdef = SynthDef(name.asSymbol, {
            var sig = this.func;
            sig = sig.();
            Out.ar(\out.kr(0), sig);
        }).add;

        "% synth created".format(name).inform;

        ^this;
    }

    prInit {|key|

        envir = ();

        if (key.isNil) {

            // when no key is specified
            // we assume we are building a synth
            libfunc = {

                var gatemode = ~gatemode;
                var gate, vel, sig, filt, out, freq, env, doneaction;

                gate = \gate.kr(1);
                if (gatemode == \retrig) {
                    Env.asr(0, 1, \rel.kr(1)).kr(doneAction:Done.freeSelf, gate:gate);
                    doneaction = Done.none;
                    gate = \trig.tr(1);
                }{
                    doneaction = Done.freeSelf;
                };

                vel = \vel.kr(0);
                freq = if (pitchModule.notNil) {pitchModule.func}{ M('pitch/freq').func };
                env = if (envModule.notNil) {envModule.func}{ M('env/adsr').func };

                freq = freq.();
                env = env.(gate, doneaction);

                sig = if (synthModule.notNil) {
                    synthModule
                    .put('freq', freq)
                    .put('gate', gate)
                    .put('vel', vel)
                    .func
                }{ {|freq| SinOsc.ar(freq)} };

                filt = if (filterModule.notNil) {
                    filterModule
                    .put('freq', freq)
                    .put('gate', gate)
                    .put('vel', vel)
                    .func
                } { {|in| in} };

                out = if (outModule.notNil) {
                    outModule.func
                }{ M('out/splay').func };

                sig = sig.(freq, gate);
                sig = LeakDC.ar(sig);
                sig = filt.(sig, gate, freq, env);
                sig = sig * env;
                sig = sig * AmpCompA.ar(freq, 0) * \amp.kr(-6.dbamp) * (1+vel);
                sig = out.(sig);

                sig;
            };

        } {

            if (key.isKindOf(Function)) {
                libfunc = key
            } {
                var path = App.librarydir ++ key.asString ++ ".scd";
                var pathname = PathName(path.standardizePath);
                fullpath = pathname.fullPath.debug("module");

                if (File.exists(fullpath)) {
                    var obj = File.open(fullpath, "r").readAllString.interpret;
                    libfunc = obj[\synth];
                } {
                    Error("% node not found".format(key)).throw;
                }
            }
        };

        ^this;
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
}

/*
SynthLib {

    var <synthfunc, <>specs, <>name, <>presets, <>notes, <>envir;
    var <fullpath;

    *new {|key|
        ^super.new.prInit(key);
    }

    func {
        // NOTE: func.inEnvir won't work with Ndef sources
        // unless you wrap it in another function or create a synthdef first
        // there must be some kind of conflict with environments
        // it works ok with filters but just not with sources
        ^synthfunc.inEnvir(envir)
    }

    func_ {|val|
        synthfunc = val
    }

    put {|key, val|
        envir.put(key, val);
        ^this
    }

    prInit {|key|

        envir = ();
        if (key.isNil) {
            // no op
        } {
            var path = App.librarydir ++ key.asString ++ ".scd";
            var pathname = PathName(path.standardizePath);
            fullpath = pathname.fullPath;
            name = pathname.fileNameWithoutExtension.asSymbol;

            if (File.exists(fullpath)) {
                var obj = File.open(fullpath, "r").readAllString.interpret;
                synthfunc = obj[\synth];
                specs = obj[\specs];
                notes = obj[\notes];
                if (obj[\presets].notNil) {
                    presets = obj[\presets].asDict
                }
            } {
                Error("node not found").throw;
            }
        }
        ^this;
    }

    addSynthDef {|template=\adsr, name|
        name = name ?? {this.name};
        SynthLib.def(key:name, func:this.func, template:template, specs:this.specs)
    }

    *def {|key, func, template=\adsr, specs|
        var path = App.librarydir ++  "templates/" ++ template.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;

        if (File.exists(fullpath)) {
            var template = File.open(fullpath, "r").readAllString.interpret;
            template.(key.asSymbol, func, specs);
            "synth created".debug(key);
        } {
            Error("synth template not found").throw;
        };
    }

    *ls {|path|

        var fullpath = App.librarydir ++ (path ?? {"synths"});
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
        Document.open(fullpath)
    }

    *printSynthControls {|synth|
        SynthDescLib.all[\global]
        .synthDescs[synth]
        .controls.do({|cn|
            [cn.name, cn.defaultValue].postln
        });
    }

    *getSpecsPairs {|synth|
        var synthdef = SynthDescLib.global.at(synth.asSymbol);
        var metadata = synthdef.metadata;
        var result;
        if (metadata.notNil) {
            var specs = metadata[\specs];
            if (specs.notNil) {
                result = specs.asPairs
            }
        };
        ^result;
    }
}
*/

