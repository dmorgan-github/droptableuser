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

    *read {arg key, path, channels=nil, cb;
        if (channels.isNil) {
            ^Buffer.read(Server.default, path, action:{|buf|
                buf.normalize;
                all.put(key, buf);
                "key: %; dur: %; channels: %".format(key, buf.duration, buf.numChannels).inform;
                cb.(buf);

            });
        }{
            channels = channels.asArray;
            ^Buffer.readChannel(Server.default, path, channels:channels, action:{arg buf;
                buf.normalize;
                all.put(key, buf);
                "key: %; dur: %; channels: %".format(key, buf.duration, buf.numChannels).inform;
                cb.(buf)
            });
        };
    }

    *toMono {|key, path, cb|

        /*
        (
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/SinedPink.aiff");
c = Buffer(s);
FluidBufCompose.processBlocking(s,b,numChans:1,destination:c,gain:-6.dbamp);
FluidBufCompose.processBlocking(s,b,startChan:1,numChans:1,destination:c,gain:-6.dbamp,destGain:1);
)

b.numChannels; // 2
c.numChannels; // 1

b.play;
c.play;

b.plot
c.plot
        */

        var file = SoundFile.openRead(path);
        if (file.numChannels == 2) {
            file.close;
            Buffer.read(Server.default, path, action:{|buf|
                buf.loadToFloatArray(action:{|array|
                    /*
                    https://scsynth.org/t/load-stereo-file-to-mono-buffer/5043/2
                    Replace the 0.5 constant with -3.dbamp (≈ 1/sqrt(2) ≈ 0.707) for uncorrelated signals.
                    */
                    Buffer.loadCollection(Server.default, array.unlace(2).sum * 0.5, action:{|mono|
                        mono.normalize;
                        all.put(key, mono);
                        "key: %; dur: %; channels: %".format(key, mono.duration, mono.numChannels).inform;
                        buf.free;
                        cb.(mono);
                    })
                })
            });
        } {
            B.read(key, path, cb:cb);
        };
    }

    *mono {|key, path, cb|
        B.read(key, path, 0, cb:cb);
    }

    *stereo {|key, path, cb|
        var file = SoundFile.openRead(path);
        var channels = if (file.numChannels.debug('numchannels') < 2) { [0,0] }{ [0, 1] };
        file.close;
        B.read(key, path, channels, cb:cb);
    }

    *alloc {|key, numFrames, numChannels=1|
        var buf = Buffer.alloc(Server.default, numFrames, numChannels);
        all.put(key, buf);
        "allocated buffer with key: %".format(key).inform;
        ^buf;
    }

    *allocSec {|key, seconds=8, numChannels=1|
        ^B.alloc(key, seconds * Server.default.sampleRate, numChannels);
    }

    // load random n seconds from sound file
    *randN {|key, path, n=5, cb|

        var file = SoundFile.openRead(path);
        var numframes = file.numFrames;
        var sr = file.sampleRate;

        var secs = n * sr;
        var twoseconds = 2 * sr;
        var start = 0, end = -1;

        if (numframes > secs) {
            var max = numframes - secs;
            var min = twoseconds;
            start = (min..max).choose;
            end = secs
        };

        file.close;

        ^Buffer.readChannel(Server.default, path, start, end, channels:[0], action: {|buf|
            buf.normalize;
            all.put(key, buf);
            "key: %; dur: %; channels: %".format(key, buf.duration, buf.numChannels).inform;
            cb.(buf)
        })
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

    *loadFiles {|key, paths, seed, normalize=true|

        var condition = Condition(false);

        var read = {|path, num|
            var buffer;
            //var file = SoundFile.openRead(path);
            var channels = [0];//if(file.numChannels < 2, { [0,0] },{ [0,1] });

            // this is not very efficient but will allow
            // adding to an existing collection of bufs
            // without reloading what has already been loaded
            all[key.asSymbol].do({|buf|
                if (buf.path.asString == path.asString) {
                    buffer = buf;
                }

            });

            if (buffer.isNil) {
                buffer = Buffer.readChannel(Server.default, path, channels: channels, action:{|buf|
                    path.debug("loaded");
                    condition.unhang;
                }, bufnum:num);
            } {
                { condition.unhang }.defer
            };

            buffer;
        };

        key = key.asSymbol;
        {
            if (all[key].isNil) {
                all[key] = Order();
            };
            paths.do({|path|
                var buf = read.(path, seed);
                condition.hang;
                if (normalize) {
                    all[key].put(buf.bufnum, buf.normalize);
                }{
                    all[key].put(buf.bufnum, buf);
                };
                // TODO: need validation on deterministic numbering
                // may get into trouble with s.nextBufferNumber(1)
                if (seed.notNil) {
                    seed = seed + 1;
                };
            });
            all[key].addSpec(\bufnums, [all[key].indices.minItem, all[key].indices.maxItem, \lin, 1, all[key].indices.minItem].asSpec);
            "buffers loaded".postln
        }.fork
    }

    /*
    Loads a directory and subdirectores of sound files into mono bufs
    */
    *loadLib {|key, path, normalize=true|

        var read;
        var condition = Condition(false);

        path.debug("loading");

        read = {|path|
            var buffer;
            var channels = [0];//if(file.numChannels < 2, { [0,0] },{ [0,1] });

            // can't figure out a better way to handle this error
            // File '/Users/david/Documents/supercollider/patches/patches/recordings/Audio 1-119.wav' could not be opened: Format not recognised.
            var sf = SoundFile.openRead(path).close;
            if (sf.isNil) {
                //sf.close;
                path.debug("unable to read file");
                { condition.unhang }.defer
            }{
                //sf.close;
                buffer = Buffer.readChannel(Server.default, path, channels: channels, action:{|buf|
                    path.debug("loaded");
                    condition.unhang;
                });
            };

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
                            if (buf.notNil) {
                                if (normalize) {
                                    all[mykey].put(buf.bufnum, buf.normalize);
                                }{
                                    all[mykey].put(buf.bufnum, buf);
                                };
                            }
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
