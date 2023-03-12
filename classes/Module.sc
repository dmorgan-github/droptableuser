// module
Module {

    classvar <>libraryDir;

    var <>envir, <>libfunc, <fullpath, <props, <view, <doc, <presets;

    *new {|key|
        var res;
        res = super.new.prModuleInit(key);
        ^res;
    }

    doesNotUnderstand {|selector ...args|
        if (selector.isSetter) {
            var key = selector.asGetter;
            this.set(key, args[0]);
        }
    }

    *exists {|key|
        var path;
        path = libraryDir ++ key.asString;
        if (key.asString.endsWith(".scd").not) {
            path = path ++ ".scd";
        };
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

    set {|key, val|
        envir.put(key, val);
        this.changed(\set, [key, val]);
        ^this
    }

    setAll {|... dictionaries|
        dictionaries.do {|dict|
            dict.keysValuesDo {|key, value|
                this.set(key, value)
            }
        }
    }

    *ls {|path|

        var fullpath = libraryDir ++ (path ?? {"synth"});
        var pn = PathName(fullpath);
        pn.postln;
        pn.entries.do({|obj|
            if ( obj.isFolder ) {
                "%/".format(obj.folderName).postln
            }{
                obj.fileName.postln
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

    prModuleInit {|key|

        envir = ();

        if (key.isKindOf(Function)) {
            key.asCode;
            libfunc = key
        }{
            if (key.notNil) {
                var path, pathname;

                path = libraryDir ++ key.asString;
                if (key.asString.endsWith(".scd").not) {
                    path = path ++ ".scd";
                };
                pathname = PathName(path.standardizePath);
                fullpath = pathname.fullPath;

                if (File.exists(fullpath)) {
                    var file = File.open(fullpath, "r");
                    var obj = file.readAllString.interpret;
                    libfunc = obj[\synth] ?? {obj[\func]};
                    props = obj['props'];
                    view = obj['view'];
                    doc = obj['doc'];
                    presets = obj['presets'];
                    file.close;
                } {
                    Error("% module not found".format(path)).throw;
                }
            }
        }

        ^this;
    }
}


