/*
Buffer
*/
B {
    classvar <all;

    classvar <wtDirs;

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
            Buffer.read(Server.default, path, action:{|buf|
                all.put(key, buf.normalize);
                "key: %; dur: %; channels: %".format(key, buf.duration, buf.numChannels).inform;
            });
        }{
            channels = channels.asArray;
            Buffer.readChannel(Server.default, path, channels:channels, action:{arg buf;
                all.put(key, buf.normalize);
                "key: %; dur: %; channels: %".format(key, buf.duration, buf.numChannels).inform;
            });
        };
    }

    *mono {|key, path|
        B.read(key, path, 0);
    }

    *stereo {|key, path|
        var file = SoundFile.openRead(path);
        var channels = if (file.numChannels.debug('numchannels') < 2) { [0,0] }{ [0, 1] };
        B.read(key, path, channels);
    }

    *alloc {|key, numFrames, numChannels=1|
        var buf = Buffer.alloc(Server.default, numFrames, numChannels);
        all.put(key, buf);
        "allocated buffer with key: %".format(key).inform;
        ^buf;
    }

    *loadWavetables {|key, path|

        var obj = Order();
        var wtsize = 4096;
        var wtpaths = "%/**.wtable".format(path).pathMatch;
        var wtbuffers = Buffer.allocConsecutive(wtpaths.size, Server.default, wtsize * 2, 1);
        wtpaths.do {|it, i|
            var buf = wtbuffers[i].read(wtpaths[i]);
            obj.put(buf.bufnum, buf);
        };

        obj.addSpec(\bufnums, [obj.indices.minItem, obj.indices.maxItem, \lin, 1, obj.indices.minItem].asSpec);
        all[key] = obj;
        "wavetables loaded".debug(key);
    }

    *loadFiles {|key, paths, normalize=true|

        var condition = Condition(false);

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
        {
            all[key] = Order();
            paths.do({|path|
                var buf = read.(path);
                condition.hang;
                if (normalize) {
                    all[key].put(buf.bufnum, buf.normalize);
                }{
                    all[key].put(buf.bufnum, buf);
                };
            });
            all[key].addSpec(\bufnums, [all[key].indices.minItem, all[key].indices.maxItem, \lin, 1, all[key].indices.minItem].asSpec);
            "buffers loaded".postln
        }.fork
    }

    /*
    Loads a directory of sound files into mono bufs
    */
    *loadLib {|key, path, normalize=true|

        var condition = Condition(false);

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
        {
            var recurse;
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
                        all[mykey] = Order();
                        files
                        .sort({|a, b| a.fileName < b.fileName })
                        .do({|file, i|
                            var buf = read.(file.fullPath);
                            condition.hang;
                            if (normalize) {
                                all[mykey].put(buf.bufnum, buf.normalize);
                            }{
                                all[mykey].put(buf.bufnum, buf);
                            };
                        });
                        all[mykey].addSpec(\bufnums,
                          [all[mykey].indices.minItem, all[mykey].indices.maxItem, \lin, 1, all[mykey].indices.minItem].asSpec);
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
            recurse.(path, key.asString);
            "buffers loaded".debug(key);
        }.fork
    }

    // adapted from here:
    //https://github.com/alikthename/Musical-Design-in-Supercollider/blob/master/5_wavetables.sc
    // run once to convert and resample wavetable files
    *convertWavetables {|path|
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
        wtDirs = IdentityDictionary();
    }
}
