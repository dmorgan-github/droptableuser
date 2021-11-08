/*
UI
*/
U {
    *new {arg key ...args;

        var path = App.librarydir ++ "ui/" ++ key.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;
        if (File.exists(fullpath)) {
            var name = pathname.fileNameWithoutExtension;
            File.open(fullpath, "r").readAllString.interpret;
            ^Fdef(key).value(*args);
        } {
            Error("node not found").throw;
        };
    }

    *ls {arg dir;
        var path = App.librarydir ++ "ui/" ++ dir;
        PathName.new(path)
        .entries.do({arg e; e.fullPath.postln;});
    }
}