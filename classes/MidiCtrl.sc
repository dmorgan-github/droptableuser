
// TODO: this probably just needs to be a Module
MidiCtrl {
    
    var <>src, <>dest, <>out;

    *new {
        ^super.new.prInit();
    }

    freeAll {
        MIDIdef.freeAll;
    }

    *ls {
        fork({
            MIDIClient.list;
            0.5.wait;
            MIDIClient.sources.debug("sources");
            MIDIClient.destinations.debug("destinations");
        })
    }

    *trace {arg enable=true;
        MIDIFunc.trace(enable);
    }

    *connectAll {
        MIDIClient.init(verbose:true);
        MIDIIn.connectAll(verbose:true);
    }

    *connect {|device, name, cb|

        fork({

            var obj;
            var dest, src, out;
            var sources, destinations;

            // MIDIClient.list is async
            MIDIClient.list;
            0.5.wait;

            sources = MIDIClient.sources;
            destinations = MIDIClient.destinations;

            src = sources.select({|e|
                e.device.toLower.contains(device.asString.toLower)
            });

            if (src.size == 0) {
                "midi source not found".throw;
            } {
                if (src.size > 1) {
                    if (name.notNil) {
                        var result = src.select({|e| e.name.asString.toLower.contains(name.asString.toLower) });
                        if (result.size > 0) {
                            src = result[0]
                        }{
                            "unable to find src % with %".format(device, name).throw
                        }
                    } {
                        "multiple ports for src device".throw
                    }
                } {
                    src = src[0]
                };
            };

            dest = destinations.select({|e| 
                e.device.asString.toLower.contains(device.asString.toLower) 
            });

            if (dest.size == 0) {
                "midi destination not found".throw;
            }{
                if (dest.size > 1) {
                    if (name.notNil) {
                        var result = dest.select({|e| e.name.asString.toLower.contains(name.asString.toLower) });
                        if (result.size > 0) {
                            dest = result[0]
                        }{
                            "unable to find dest % with %".format(device, name).throw
                        }
                    }{
                        "multiple ports for dest device".throw
                    }
                } {
                    dest = dest[0]
                };
            };

            out = MIDIOut.newByName(dest.device, dest.name).connect;
            MIDIIn.connect(device: src);


            obj = MidiCtrl();

            obj.src = src.debug("src");
            obj.dest = dest.debug("dest");
            obj.out = out.debug("out");

            cb.(obj);
        });
    }

    prInit {|device, name, cb|
        ^this;
    }

    *initClass {
        MIDIClient.init(verbose:true);
    }
}


