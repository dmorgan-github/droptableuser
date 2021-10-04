
SynthLib {

    var <func, <specs, <name;

    *new {|key|
        ^super.new.prInit(key);
    }

    prInit {|key|
        var path = App.librarydir ++ key.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;
        name = pathname.fileNameWithoutExtension.asSymbol;

        if (File.exists(fullpath)) {
            var name = pathname.fileNameWithoutExtension;
            var obj = File.open(fullpath, "r").readAllString.interpret;
            func = obj[\synth];
            specs = obj[\specs];
        } {
            Error("node not found").throw;
        }
        ^this;
    }

    toSynthDef {|template=\adsr|
        SynthLib.def(this.name, this.func, template, this.specs)
    }

    *def {|inKey, inFunc, inTemplate=\adsr, specs|
        var path = App.librarydir ++  "templates/" ++ inTemplate.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;

        if (File.exists(fullpath)) {
            var template = File.open(fullpath, "r").readAllString.interpret;
            template.(inKey, inFunc, specs);
            "synth created".debug(inKey);
        } {
            Error("synth template not found").throw;
        };
    }

    *ls {
        SynthDescLib.all[\global].synthDescs
        .keys
        .reject({|key|
            key.asString.beginsWith("system") or: key.asString.beginsWith("pbindFx_")
        })
        .asArray
        .sort
        .do({|val| val.postln})
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

