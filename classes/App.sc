App {

    classvar <>workspacedir, <>mediadir, <>librarydir;
    classvar <>touchoscserver, <>touchoscport;
    classvar <>isrecording;

    *initClass {
        workspacedir = "~/Documents/supercollider/workspaces/".standardizePath;
        mediadir = "~/Documents/supercollider/media/".standardizePath;
        librarydir = "~/projects/droptableuser/library/".standardizePath;
        touchoscserver = "10.0.1.81";
        touchoscport = 9000;
    }

    *recAtCommit {|commit|
        var filepath = Platform.recordingsDir;
        filepath = filepath ++ "%.wav".format(commit);
        Server.default.record(filepath, bus:D.defaultout, numChannels:2 );
    }

    *rec {|numchans=2, recdir|
        thisProcess.platform.recordingsDir = recdir ?? {thisProcess.nowExecutingPath.dirname};//Document.current.dir;
        if (isrecording == true) {
            isrecording = false;
            Server.default.stopRecording;
        } {
            Server.default.record(numChannels:numchans);
            isrecording = true;
        };
    }
}
