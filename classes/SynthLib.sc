
SynthLib {

    var <synthfunc, <>specs, <>name, <>presets, <>notes, <>envir;

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
            var fullpath = pathname.fullPath;
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

        /*
        SynthDescLib.all[\global].synthDescs
        .keys
        .reject({|key|
            key.asString.beginsWith("system") or: key.asString.beginsWith("pbindFx_")
        })
        .asArray
        .sort
        .do({|val| val.postln})
        */
    }

    *open {|path|
        var fullpath = App.librarydir ++ path;
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

