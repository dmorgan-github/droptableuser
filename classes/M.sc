// module
Module {

    var <envir, <>libfunc, <fullpath, <props;

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
            libfunc = key
        }{
            if (key.notNil) {
                var path = App.librarydir ++ key.asString ++ ".scd";
                var pathname = PathName(path.standardizePath);
                fullpath = pathname.fullPath.debug("module");

                if (File.exists(fullpath)) {
                    var obj = File.open(fullpath, "r").readAllString.interpret;
                    libfunc = obj[\synth];
                    props = obj['props'];
                } {
                    Error("% node not found".format(key)).throw;
                }
            }
        }

        ^this;
    }
}

M : Module {

    var <synthModule, <filterModule, <outModule, <pitchModule, <envModule;
    var <synthdef, <synthname;

    *new {
        var res;
        res = super.new().prMInit();
        ^res;
    }

    osc {|key, cb|
        if (key.isKindOf(Symbol)) {
            synthname = key;
            key = "synth/%".format(key).asSymbol;
        };
        synthModule = Module(key);
        if (synthModule.props.notNil) {
            envir.putAll(synthModule.props);
        };
        cb.(synthModule);
        ^this;
    }

    env {|key, cb|
        if (key.isKindOf(Symbol)) {
            key = "env/%".format(key).asSymbol;
        };
        envModule = Module(key);
        if (envModule.props.notNil) {
            envir.putAll(envModule.props);
        };
        cb.(envModule);
        ^this;
    }

    filter {|key, type, cb|
        if (key.isKindOf(Symbol)) {
            key = "filter/%".format(key).asSymbol;
        };
        filterModule = Module(key);
        if (type.notNil) {
            filterModule.put('type', type)
        };
        if (filterModule.props.notNil) {
            envir.putAll(filterModule.props);
        };
        cb.(filterModule);
        ^this;
    }

    out {|key, cb|
        if (key.isKindOf(Symbol)) {
            key = "out/%".format(key).asSymbol;
        };
        outModule = Module(key);
        if (outModule.props.notNil) {
            envir.putAll(outModule.props);
        };
        cb.(outModule);
        ^this;
    }

    pitch {|key, cb|
        if (key.isKindOf(Symbol)) {
            key = "pitch/%".format(key).asSymbol;
        };
        pitchModule = Module(key);
        if (pitchModule.props.notNil) {
            envir.putAll(pitchModule.props);
        };
        cb.(pitchModule);
        ^this;
    }

    add {|name|
        name = name ?? synthname;
        synthdef = SynthDef(name.asSymbol, {
            var sig = this.func;
            sig = sig.();
            Out.ar(\out.kr(0), sig);
        }).add;

        "% synth created".format(name).inform;

        ^this;
    }

    *synthDesc {|name|
        ^SynthDescLib.global[name];
    }

    prMInit {

        synthname = "synth_%".format(UniqueID.next).asSymbol;

        this.libfunc = {

            var gatemode = ~gatemode;
            var detectsilence = ~detectsilence ?? false;
            var gate, vel, sig, filt, out, freq, env, doneaction;
            var hasgate;

            hasgate = ~hasgate ?? true;
            hasgate.debug("hasgate");
            if (hasgate) {
                gate = \gate.kr(1);
            } {
                gate = 1;
            };

            if (gatemode.debug("gate mode") == \retrig) {
                Env.asr(0, 1, \rel.kr(1)).kr(doneAction:Done.freeSelf, gate:gate);
                doneaction = Done.none;
                gate = \trig.tr(1);
            }{
                doneaction = Done.freeSelf;
            };

            vel = \vel.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "timbre"));
            freq = if (pitchModule.notNil) {pitchModule.func}{ Module('pitch/freq').func };
            env = if (envModule.notNil) {envModule.func}{ Module('env/adsr').func };

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
            }{ Module('out/splay').func };

            sig = sig.(freq, gate);
            sig = LeakDC.ar(sig);
            sig = filt.(sig, gate, freq, env);
            sig = sig * env;
            sig = sig * AmpCompA.ar(freq, 0) * \amp.kr(-6.dbamp);
            sig = sig * (1+vel);
            sig = sig * \gain.kr(1, spec:ControlSpec(0, 2, \lin, 0, 1, "vol"));

            if (detectsilence) {
                "detect silence enabled".postln;
                DetectSilence.ar(in: sig, amp: 0.00025, doneAction:Done.freeSelf);
            };

            sig = out.(sig);
            sig;
        };

        ^this;
    }
}

