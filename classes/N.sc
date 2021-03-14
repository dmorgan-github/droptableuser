/*
Node
*/
N : Device {

    var <uifunc, fx;

    fx_ {|name|
        fx = name;
        this.prBuild;
    }

    view {
        ^U(\ngui, this, uifunc.(this));
    }

    *loadFx {|fx|
        var path = App.librarydir ++ "fx/" ++ fx.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;

        if (File.exists(fullpath)) {
            var name = pathname.fileNameWithoutExtension;
            var obj = File.open(fullpath, "r").readAllString.interpret;
            ^obj
        } {
            Error("node not found").throw;
        }
    }

    prBuild {
        var obj = N.loadFx(fx);
        var func = obj[\synth];
        var specs = obj[\specs];
        uifunc = obj[\ui];
        this.filter(100, func);
        if (specs.isNil.not) {
            specs.do({arg assoc, i;
                //var key = "%/%".format(i, assoc.key).asSymbol;
                var key = assoc.key;
                this.addSpec(key, assoc.value);
            });
        };
    }

    *ls {arg dir;
        var path = App.librarydir ++ dir;
        PathName.new(path.asString)
        .entries.do({arg e; e.fullPath.postln;});
    }
}