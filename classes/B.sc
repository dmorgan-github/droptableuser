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
            all.put(key, buf.normalize);
            "added buffer with key: %; %".format(key, path).inform;
        });
    }

    *mono {|key, path|
        B.read(key, path, 0);
    }

    *stereo {|key, path|
        var file = SoundFile.openRead(path);
        var channels = if (file.numChannels < 2) { [0,0] }{ [0, 1] };
        B.read(key, path, channels);
    }

    *alloc {|key, numFrames, numChannels=1|
        var buf = Buffer.alloc(Server.default, numFrames, numChannels);
        all.put(key, buf);
        "allocated buffer with key: %".format(key).inform;
        ^buf;
    }

    /*
    Loads a directory of sound files into mono bufs
    */
    *load {|key, path, cb|

        var condition = Condition(false);
        var normalize = true;

        var read = {|path|
            var buffer;
            var file = SoundFile.openRead(path);
            var channels = [0];//if(file.numChannels < 2, { [0,0] },{ [0,1] });
            buffer = Buffer.readChannel(Server.default, path, channels: channels, action:{|buf|
                condition.unhang;
            });
            buffer;
        };

        key = key.asSymbol;
        path = path.standardizePath;
        if (all[key].isNil) {
            {
                var recurse;
                var obj = ();
                recurse = {|dirpath, folderName|
                    var pn = PathName.new(dirpath);
                    if (pn.isFolder) {

                        var files;
                        var mykey = folderName.toLower;
                        mykey = mykey[mykey.findAllRegexp("[a-zA-Z0-9_]")].join.asSymbol;

                        files = pn.files.select({|file|
                            file.extension.toLower == "wav" or: {file.extension.toLower.beginsWith("aif")}
                        });

                        if (files.size > 0) {
                            obj[mykey] = Order();
                            files
                            .sort({|a, b| a.fileName < b.fileName })
                            .do({|file, i|
                                var buf = read.(file.fullPath);
                                condition.hang;
                                if (normalize) {
                                    obj[mykey].put(i, buf.normalize);
                                }{
                                    obj[mykey].put(i, buf);
                                }
                            });
                        };

                        pn.folders.do({|dir|
                            var folderName = if (mykey.asString.size > 0) {
                                "%_%". format(mykey, dir.folderName)
                            }{
                                dir.folderName
                            };
                            recurse.(dir.fullPath, folderName);
                        });
                    }
                };
                recurse.(path, "root");
                all[key] = obj;
                cb.(obj);
                "buffers loaded".debug(key);
            }.fork
        } {
            cb.(all[key]);
        }
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
