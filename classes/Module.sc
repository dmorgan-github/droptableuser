// module
Module {

    var <>envir, <>libfunc, <fullpath, <props, <view, <doc;

    *new {|key|
        var res;
        res = super.new.prModuleInit(key);
        ^res;
    }

    doesNotUnderstand {|selector ...args|
        if (selector.isSetter) {
            var key = selector.asGetter;
            this.envir.put(key, args[0]);
        }
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

    prModuleInit {|key|

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


