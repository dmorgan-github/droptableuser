/*
Buffer
NOTE: this could use a lot of refactoring
*/
B {
    classvar <all;

    classvar <stereoDirs, <wtDirs, <monoDirs;

    *new {arg key;
        ^all[key]
    }

    *doesNotUnderstand {|key|
        var res = all[key];
        if (res.isNil){
            "% does not exist".format(key).warn;
        };
        ^res;
    }

    *read {arg key, path, channels=nil;
        if (channels.isNil) {
            channels = [0,1];
        }{
            channels = channels.asArray;
        };
        Buffer.readChannel(Server.default, path, channels:channels, action:{arg buf;
            all.put(key, buf);
            "added buffer with key: %; %".format(key, path).inform;
        });
    }

    *mono {|key, path|
        B.read(key, path, 0);
    }

    *alloc {|key, numFrames, numChannels=1|
        var buf = Buffer.alloc(Server.default, numFrames, numChannels);
        all.put(key, buf);
        "allocated buffer with key: %".format(key).inform;
        ^buf;
    }

    *dirStereo {|path|

        var bufs;
        var pathkey = path.asSymbol;
        var func = {|path|
            var buffer;
            var file = SoundFile.openRead(path);
            var channels = if(file.numChannels < 2, { [0,0] },{ [0,1] });
            buffer = Buffer.readChannel(Server.default, path, channels: channels );
            buffer
        };

        if (stereoDirs[pathkey].notNil) {
            bufs = stereoDirs[pathkey];
            path.debug(\from_cache);
        } {
            var dir = PathName.new(path);
            bufs = dir.entries.select({|pn| pn.extension == "wav"}).collect({|pn|
                var buf = func.(pn.fullPath);
                buf
            });
            stereoDirs[pathkey] = bufs;
        };

        ^bufs;
    }

    *dirMono {|path|

        var bufs;
        var pathkey = path.asSymbol;

        if (monoDirs[pathkey].notNil) {
            bufs = monoDirs[pathkey];
            path.debug(\from_cache);
        }{
            var paths = "%/*.wav".format(path).pathMatch ++ "%/*.aif".format(path).pathMatch;
            bufs = paths.collect({|path|
                Buffer.readChannel(Server.default, path, channels:[0]);
            });
            monoDirs[pathkey] = bufs;
        };

        ^bufs
    }

    *dirWt {|path|

        var bufs;
        var pathkey = path.asSymbol;

        if (wtDirs[pathkey].notNil) {
            bufs = wtDirs[pathkey];
            path.debug(\from_cache);
        } {
            var wtsize = 4096;
            var wtpaths = "%/**.wtable".format(path).pathMatch;
            bufs = Buffer.allocConsecutive(wtpaths.size, Server.default, wtsize * 2, 1);
            wtpaths.do {|it i|
                bufs[i].read(wtpaths[i])
            };
            wtDirs[pathkey] = bufs;
        };

        ^bufs
    }

    // adapted from here:
    //https://github.com/alikthename/Musical-Design-in-Supercollider/blob/master/5_wavetables.sc
    // run once to convert and resample wavetable files
    *convertWt {|path|
        var paths, file, data, n, newData, outFile;
        paths = "%/*.wav".format(path).pathMatch;

        Routine({
            paths.do { |it i|
                // 'protect' guarantees the file objects will be closed in case of error
                protect {

                    var path;
                    // Read original size of data
                    file = SoundFile.openRead(paths[i]);
                    data = Signal.newClear(file.numFrames);
                    file.readData(data);
                    0.1.wait;
                    // Convert to n = some power of 2 samples.
                    // n = data.size.nextPowerOfTwo;
                    n = 4096;
                    newData = data.resamp1(n);
                    0.1.wait;
                    // Convert the resampled signal into a Wavetable.
                    // resamp1 outputs an Array, so we have to reconvert to Signal
                    newData = newData.as(Signal).asWavetable;
                    0.1.wait;

                    // save to disk.
                    path = paths[i].replace("media/AKWF", "media/AKWF-converted");
                    path.postln;
                    outFile = SoundFile(path ++ "_4096.wtable")
                    .headerFormat_("WAV")
                    .sampleFormat_("float")
                    .numChannels_(1)
                    .sampleRate_(44100);
                    if(outFile.openWrite.notNil) {
                        outFile.writeData(newData);
                        0.1.wait;
                    } {
                        "Couldn't write output file".warn;
                    };
                } {
                    file.close;
                    if(outFile.notNil) { outFile.close };
                };
            }
        }).play
    }

    *initClass {
        all = IdentityDictionary();
        stereoDirs = IdentityDictionary();
        wtDirs = IdentityDictionary();
        monoDirs = IdentityDictionary();
    }
}