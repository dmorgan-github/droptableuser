Monome {

    var <envir, <func;

    classvar <connected=false, <grid;

    *new {|key|
        ^super.new.prInit(key);
    }

    run {
        func.inEnvir(envir).();
    }

    put {|key, val|
        envir.put(key, val);
        ^this
    }

    *ls {
        var fullpath = App.librarydir ++ "monome";
        var pn = PathName(fullpath);
        pn.entries.do({|obj|
            if ( obj.isFolder ) {
                "%/".format(obj.folderName).postln
            }{
                obj.fileName.postln;
            }
        })
    }

    *open {|path|
        var fullpath = App.librarydir ++ "monome/" ++ path;
        if (fullpath.asString.contains(".scd").not) {
            fullpath = fullpath ++ ".scd"
        };
        Document.open(fullpath)
    }

    *connect {

        "connect".debug("monome");
        MonoM.connect;
        {
            grid = MonoM.new("/monome", 0);
            grid.useDevice(0);
            topEnvironment['monome'] = grid;
            connected = true;
        }.defer(2)
    }

    prInit {|key|

        if (connected.not) {
            Monome.connect;
        };

        envir = (
            monome: grid
        );

        if (key.isNil) {

        }{
            var path = App.librarydir ++ "monome/" ++ key.asString ++ ".scd";
            var pathname = PathName(path.standardizePath);
            var fullpath = pathname.fullPath;

            if (File.exists(fullpath)) {
                var obj = File.open(fullpath, "r").readAllString.interpret;
                func = obj['func'];
            } {
                Error("node not found").throw;
            }
        };

        ^this
    }
}