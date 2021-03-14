Reaper {

    classvar <server, <isrecording;

    *record {
        if (isrecording.not) {
            server.sendMsg("t/record");
            isrecording = true;
            "reaper recording...".inform;
        } {
            "reaper already recording".warn;
        }
    }

    *stopRecording {
        if (isrecording) {
            server.sendMsg("t/record");
            isrecording = false;
            "reaper recording stopped...".inform;
            Reaper.stop;
        } {
            "reaper not recording".warn;
        }
    }

    *play {
        "reaper playing".inform;
        server.sendMsg("t/play");
    }

    *stop {
        "reaper stopped".inform;
        server.sendMsg("t/stop");
    }

    *tempo {arg bps=1;
        server.sendMsg("f/tempo/raw", 60 * bps);
    }

    *time {arg time=0;
        server.sendMsg("f/time", time);
    }

    *trackname {arg num, name;
        var path = "s/track/%/name".format(num);
        server.sendMsg(path, name);
    }

    *initClass {
        server = NetAddr("127.0.0.1", 8000); // loopback
        isrecording = false;
    }
}