App {

    classvar <>workspacedir, <>mediadir, <>librarydir;
    classvar <>touchoscserver, <>touchoscport;

    *initClass {
        workspacedir = "~/Documents/supercollider/workspaces/".standardizePath;
        mediadir = "~/Documents/supercollider/media/".standardizePath;
        librarydir = "~/projects/droptableuser/library/".standardizePath;
        touchoscserver = "10.0.1.81";
        touchoscport = 9000;
    }

    *idgen {
        var str = {"aaabcdeeefghiiijklmnooopqrstuuuvwxyz".choose}.dup(rrand(3,5)).join;
        "echo % | pbcopy".format(str).systemCmd;
        ^str
    }

    *recAtCommit {|commit|
        var filepath = Platform.recordingsDir;
        filepath = filepath ++ "%.wav".format(commit);
        Server.default.record(filepath, bus:D.defaultout, numChannels:2 );
    }

    *rec {|numchans=2|
        //if ( \Document.asClass.notNil and: { Document.hasEditedDocuments } ) {
        //    "save open documents".error
        //}{
            thisProcess.platform.recordingsDir = thisProcess.nowExecutingPath.dirname;//Document.current.dir;
            Server.default.record(numChannels:numchans);
        //};
    }

    *saveWorkspace {arg name = "", folder = "~/Documents/supercollider/workspaces".standardizePath, rec = true, envir;

        var workspace = "%/%-%-%/%%".format(name,
            Date.getDate.year, Date.getDate.month, Date.getDate.day, Date.getDate.hour, Date.getDate.minute);
        var current_doc = Document.current;
        var current_path = folder.standardizePath ++ "/" ++ workspace;
        var dirname;

        if (File.exists(current_path).not) {
            File.mkdir(current_path);
        };

        Document.openDocuments.do({arg doc;
            var file_name = PathName(doc.title);
            var path = current_path ++ "/_wip_" ++ file_name.fileName;
            var content = doc.string;
            var file = File(path, "w");
            path.debug("writing...");
            file.write(content);
            file.close();
        });

        if (rec) {
            var tempo = TempoClock.default.tempo;
            Server.default.record(current_path ++ "/SC_" ++ Date.getDate.stamp ++ ".aiff");
        }
    }
}
