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

    *prEnsurePath {|path|
        if (File.exists(path).not) {
            path = Document.current.dir +/+ path;
        };
        ^path;
    }

    *read {|path, channels=nil, cb, normalize=true|

        var buffer;
        path = B.prEnsurePath(path);

        if (channels.isNil) {
            buffer = Buffer.read(Server.default, path, action:{|buf|
                if (normalize) {
                    buf = buf.normalize;
                };
                cb.(buf);

            });
        }{
            channels = channels.asArray;
            buffer = Buffer.readChannel(Server.default, path, channels:channels, action:{arg buf;
                if (normalize) {
                    buf = buf.normalize;
                };
                cb.(buf)
            });
        };
        ^buffer;
    }

    *toMono {|path, cb|

        /*
        b = Buffer.read(s, Platform.resourceDir +/+ "sounds/SinedPink.aiff");
        c = Buffer(s);
        FluidBufCompose.processBlocking(s,b,numChans:1,destination:c,gain:-6.dbamp);
        FluidBufCompose.processBlocking(s,b,startChan:1,numChans:1,destination:c,gain:-6.dbamp,destGain:1);

        b.numChannels; // 2
        c.numChannels; // 1
        */

        // somehow this doesn't work as expected - it seems to alter the pitch
        var file;
        path = B.prEnsurePath(path);
        file = SoundFile.openRead(path).close;
        if (file.numChannels == 2) {
            Buffer.read(Server.default, path, action:{|buf|
                buf.loadToFloatArray(action:{|array|
                    /*
                    https://scsynth.org/t/load-stereo-file-to-mono-buffer/5043/2
                    Replace the 0.5 constant with -3.dbamp (≈ 1/sqrt(2) ≈ 0.707) for uncorrelated signals.
                    */
                    Buffer.loadCollection(Server.default, array.unlace(2).sum * 0.5, action:{|mono|
                        mono.normalize;
                        buf.free;
                        cb.(mono);
                    })
                })
            });
        } {
            B.read(path, cb:cb);
        };
    }

    *mono {|key, path|
        ^B.read(path, [0], cb: {|buf|
            all.put(key, buf);
            "key: %; dur: %; channels: %".format(key, buf.duration, buf.numChannels).inform;
        });
    }

    // https://fredrikolofsson.com/f0blog/buffer-xfader/
    *seamless {|inBuffer, duration= 2, curve= -2, cb|
        var frames= duration * inBuffer.sampleRate;
        if(frames > inBuffer.numFrames, {
            "xfader: crossfade duration longer than half buffer - clipped.".warn;
        });
        frames= frames.min(inBuffer.numFrames.div(2)).asInteger;
        Buffer.alloc(inBuffer.server, inBuffer.numFrames-frames, inBuffer.numChannels, {|outBuffer|
            inBuffer.loadToFloatArray(action:{|arr|
                var interleavedFrames = frames*inBuffer.numChannels;
                var startArr = arr.copyRange(0, interleavedFrames-1);
                var endArr = arr.copyRange(arr.size-interleavedFrames, arr.size-1);
                var result = arr.copyRange(0, arr.size-1-interleavedFrames);
                interleavedFrames.do{|i|
                    var fadeIn = i.lincurve(0, interleavedFrames-1, 0, 1, curve);
                    var fadeOut = i.lincurve(0, interleavedFrames-1, 1, 0, 0-curve);
                    result[i] = (startArr[i]*fadeIn)+(endArr[i]*fadeOut);
                };
                outBuffer.loadCollection(result, 0, cb);
            });
        });
    }

    *stereo {|key, path|
        var file, channels;
        path = B.prEnsurePath(path);
        file = SoundFile.openRead(path).close;
        channels = if (file.numChannels.debug('numchannels') < 2) { [0,0] }{ [0, 1] };
        ^B.read(path, channels, cb:{|buf|
            all.put(key, buf);
            "key: %; dur: %; channels: %".format(key, buf.duration, buf.numChannels).inform;
        });
    }

    *choose {|array|
        ^array[array.size.rand.debug("index...")]
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

    // load an array of paths into mono buffers
    *loadFiles {|key, paths|

        var condition = Condition(false);

        var read = {|path|

            var channels = [0];
            var buffer;

            // check if it has already been loaded
            buffer = all[key.asSymbol]
            .select({|buf| buf.path.asString == path.asString})
            .first;

            if (buffer.isNil) {
                buffer = B.read(path, [0], {|buf|
                    path.debug("loaded");
                    condition.unhang;
                });
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
            paths
            .select({|path|
                [\wav, \aif, \aiff].includes(PathName(path).extension.toLower.asSymbol)
            })
            .do({|path|
                var buf;
                buf = read.(path);
                condition.hang;
                all[key].put(buf.bufnum, buf);
            });
            all[key].addSpec(\bufnums, [all[key].indices.minItem, all[key].indices.maxItem, \lin, 1, all[key].indices.minItem].asSpec);
            "buffers: %; key: %".format(all[key].size, key).postln;
        }.fork
    }

    /*
    Loads a directory and subdirectores of sound files into mono bufs
    */
    *loadLib {|key, path|

        var read;
        var condition = Condition(false);

        read = {|path|
            var buffer;
            var channels = [0];//if(file.numChannels < 2, { [0,0] },{ [0,1] });

            // can't figure out a better way to handle this error
            // File '/Users/david/Documents/supercollider/patches/patches/recordings/Audio 1-119.wav' could not be opened: Format not recognised.
            var sf = SoundFile.openRead(path).close;

            buffer = B.read(path, channels, {|buf|
                path.debug("loaded");
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
                            if (buf.notNil) {
                                all[mykey].put(buf.bufnum, buf);
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

    *onsets {|buf, cb|
        var server = Server.default;
        var indices = Buffer(server);
        var feature = Buffer(server);
        FluidBufOnsetSlice.processBlocking(server, buf, indices:indices, metric:9, threshold:0.2);
        FluidBufOnsetFeature.processBlocking(server, buf, features:feature, metric:9);
        //FluidWaveform(B.yea,~indices,~feature,bounds:Rect(0,0,1600,400), lineWidth:2);
        indices.loadToFloatArray(action: {|array|
            cb.value(array, indices, feature);
        });
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

    // split a buffer containing multiple wavetables
    // into consequtive buffers
    *splitwt {|key, path, wtsize=2048|
        B.read(path, [0], cb: {|buf|
            buf.loadToFloatArray(action:{|array|
                var size = (array.size/wtsize).asInteger;
                var bufs = Buffer.allocConsecutive(size, Server.default, wtsize * 2, 1);
                size.do({|i|
                    var start = (i * wtsize).asInteger;
                    var end = (start+wtsize-1).asInteger;
                    var wt = array[start..end];
                    var buf = bufs[i];
                    wt = wt.as(Signal).asWavetable;
                    buf.loadCollection(wt);
                });
                all.put(key, bufs)
            });
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
