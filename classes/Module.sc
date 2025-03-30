M : Module {
}

Module {

    classvar <>libraryDir;

    var <>envir, <>libfunc, <fullpath, <view, <doc, <presets;
    //var <props;
    var <key;
    // TODO: need to have more structured subsclasses of modules
    // so appropriate properties can be added
    //var <>mul=1;

    *new {|key|
        var res;
        res = super.new.prModuleInit(key);
        ^res;
    }

    doesNotUnderstand {|selector ...args|
        if (selector.isSetter) {
            var key = selector.asGetter;
            this.set(key, args[0]);
        } {
            ^this.get(selector)
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
        if (libfunc.notNil) {
            ^libfunc.inEnvir(envir)
        } {
            ^libfunc
        }
    }

    func_ {|val|
        libfunc = val
    }

    set {|...pairs|
        pairs.pairsDo({|k, v|
            //[k].debug("module set");
            envir.put(k, v);
            this.changed(\set, [k, v]);    
        })
        
        ^this
    }

    get {|key|
        ^envir[key.asSymbol]
    }

    setAll {|... dictionaries|
        dictionaries.do {|dict|
            dict.keysValuesDo {|key, value|
                this.set(key, value)
            }
        }
    }

    printOn {|stream|
        var str;
		super.printOn(stream);
        str = if (this.doc.notNil) { this.doc }{ this.func.asCompileString };
		stream << " doc: " << str
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

    prModuleInit {|id|

        envir = (
            know: true,
            module: this
        );

        if (id.isKindOf(Function)) {
            id.asCode;
            libfunc = id;
            fullpath = 'func'
        }{
            if (id.notNil) {

                var path;
                var loadModule;

                loadModule = {|path|
                    var pathname = PathName(path.standardizePath);
                    var fullpath = pathname.fullPath;
                    var file = File.open(fullpath, "r");
                    var obj = file.readAllString.interpret;
                    libfunc = obj[\synth] ?? {obj[\func]};
                    //props = obj['props'];
                    view = obj['view'];
                    doc = obj['doc'];
                    presets = obj['presets'];
                    file.close;
                };

                key = id.asSymbol;
                if (id.asString.endsWith(".scd").not) {
                    id = id ++ ".scd";
                };

                if (thisProcess.nowExecutingPath.notNil) {
                    path = PathName(thisProcess.nowExecutingPath).pathOnly ++ id.asString;
                };

                if (path.notNil and: { File.exists(path) }) {
                    loadModule.(path.debug("module"))
                } {
                    path = libraryDir ++ id.asString;
                    if (File.exists(path)) {
                        loadModule.(path.debug("module"))
                    } {
                        Error("% module not found".format(path)).throw    
                    }
                };
            }
        }

        ^this;
    }
}


