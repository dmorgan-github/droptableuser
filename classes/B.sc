/*
Buffer
*/
B {
    classvar <all;

    classvar filetypes;

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

    // TODO: doesn't really ensure path exists
    *prEnsurePath {|path|

        // "e10.scd".resolveRelative
        if (File.exists(path).not) {
            //var pn = PathName(thisProcess.nowExecutingPath);// +/+ path)
            var pn = PathName(path.resolveRelative);
            path = pn.pathOnly ++ path;
            //path = Document.current.dir +/+ path;
        };
        ^path;//.debug("prEnsurePath");
    }

    *pv {|key, path|

        var file, channels;
        var fftsize = 8192, hop = 0.25, win = 0;
        path = B.prEnsurePath(path);
        file = SoundFile.openRead(path.debug("path")).close;
        channels = if (file.numChannels.debug('numchannels') < 2) { [0,0] }{ [0, 1] };

        fork({
            var buf, result, f;
            result = B.read(path, channels);
            result.wait();
            buf = result.value;
            f = { Buffer.alloc(Server.default(), buf.duration.calcPVRecSize(fftsize, hop)) } ! 2;

            "buf % recording fft...".format(key).inform;
            { 
                var sig, chain, localbuf; 
                sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf), doneAction: 2); 
                localbuf = { LocalBuf.new(fftsize) } ! 2; 
                chain = FFT(localbuf, sig, hop, win); 
                chain = PV_RecordBuf(chain, f, run: 1, hop: hop, wintype: win); 
                0; 
            }.play.onFree({ 
                "buf % ready".format(key).inform;
                buf.free;
                all.put(key, f);
            })
        })
    }

    *inspect {|path|
        var sf;
        sf = SoundFile.openRead(path);
        sf.inspect;
        sf.close;
    }

    *read {|path, channels=nil, normalize=true|

        // FluidBufCompose

        var buffer;
        var result = Deferred();
        path = B.prEnsurePath(path);
        if (channels.notNil) {
            channels = channels.asArray;
        };
        Buffer.readChannel(Server.default, path, channels:channels, action:{|buf|
            if (normalize) {
                buf = buf.normalize;
            };
            "num: %; dur: %; channels: %; path: %".format(buf.bufnum, buf.duration, buf.numChannels, path).inform;
            result.value = buf;
        });
        ^result;
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

        path.postln;

        if (path.isKindOf(Buffer)) {
            var buf = path;
            buf.loadToFloatArray(action:{|array|
                Buffer.loadCollection(Server.default, array.unlace(2).sum * 0.5, action:{|mono|
                    mono.normalize;
                    cb.(mono);
                })
            })
        }{
            path = B.prEnsurePath(path);
            file = SoundFile.openRead(path);
            if (file.notNil) {
                file.close;
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
            } {
                "unable to read file: %".format(path).warn
            }
        }
    }

    *mono {|key, path, chan=([0]), action|

        fork({
            var buf;
            var result = B.read(path, chan);
            result.wait();
            buf = result.value;
            all.put(key, buf);
            action.value(buf);
        })
    }

    *stereo {|key, path, action|

        var file, channels;
        path = B.prEnsurePath(path);
        file = SoundFile.openRead(path.debug("B path")).close;
        channels = if (file.numChannels.debug('numchannels') < 2) { [0,0] }{ [0, 1] };

        fork({
            var buf, result;
            result = B.read(path, channels);
            result.wait();
            buf = result.value;
            all.put(key, buf);
            action.value(buf)
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

    *alloc {|key, numFrames, numChannels=1|
        var buf = Buffer.alloc(Server.default, numFrames, numChannels);
        all.put(key, buf);
        "allocated buffer with key: %".format(key).inform;
        ^buf;
    }

    *allocSec {|key, seconds=8, numChannels=1|
        ^B.alloc(key, seconds * Server.default.sampleRate, numChannels);
    }

    // load a directory or array of paths
    *loadFiles {|key, paths, numchannels=1|

        var read, def = Deferred();
        var channels = numchannels.collect({|v| v});
        key = key.asSymbol;

        read = {|path|

            var result;
            // check if it has already been loaded
            result = all[key]
            .select({|buf|
                buf.path.asString.stripWhiteSpace.toLower.asSymbol == path.asString.stripWhiteSpace.toLower.asSymbol
            })
            .first;

            if (result.isNil) {
                var file = SoundFile.openRead(path);
                if (file.notNil) {
                    if ( file.numChannels < numchannels) {
                        channels = [0,0]
                    };
                    result = B.read(path, channels);
                } {
                    "can't read file %".format(path).warn
                }
            };
            result
        };

        fork({

            // TODO: load consecutive
            var temp;
            var bufs;
            if (paths.isKindOf(String)) {
                paths = PathName(paths).entries.collect({|pn| pn.fullPath });
            };
            
            bufs = paths
            .select({|path|
                filetypes.includes(PathName(path).extension.toLower.asSymbol)
            })
            .collect({|path|
                var buf;
                buf = read.(path);
                if (buf.isKindOf(Deferred)) {
                    buf.wait();
                };
                buf.value;
            });

            // TODO: ugh
            bufs = bufs.select({|b| b.notNil });
            all[key] = bufs;
            temp = bufs.collect({|b| b.bufnum });
            //all[key].addSpec(\index, [0, bufs.size-1, \lin, 1, 0].asSpec);
            all[key].addSpec(\index, [temp.minItem, temp.maxItem, \lin, 1, temp.minItem].asSpec);
            def.value = all[key];
        });

        ^def;
    }

    /*
    Loads a directory and subdirectores of sound files into mono bufs
    */
    *loadLib {|key, path, recursive=false|

        var read;

        read = {|path|

            var sf;
            var result;
            var channels = [0];//if(file.numChannels < 2, { [0,0] },{ [0,1] });
            // can't figure out a better way to handle this error
            // File '/Users/david/Documents/supercollider/patches/patches/recordings/Audio 1-119.wav' could not be opened: Format not recognised.
            sf = SoundFile.openRead(path).close;
            result = B.read(path, channels);
            result;
        };

        key = key.asSymbol;
        path = path.standardizePath;

        fork({
            var recurse;
            recurse = {|dirpath, folderName|
                var pn = PathName.new(dirpath);

                if (pn.isFolder) {

                    var files;
                    var mykey = folderName.toLower;
                    mykey = mykey[mykey.findAllRegexp("[a-zA-Z0-9_]")].join.asSymbol;

                    files = pn.files.select({|pn|
                        filetypes.includes(pn.extension.toLower.asSymbol)
                    });

                    if (files.size > 0) {
                        all[mykey] = Order();

                        files
                        .sort({|a, b| a.fileName < b.fileName })
                        .do({|file, i|
                            var buf = read.(file.fullPath);
                            buf.wait();
                            buf = buf.value;
                            if (buf.notNil) {
                                all[mykey].put(buf.bufnum, buf);
                            }
                        });
                        all[mykey].addSpec(\bufnums,
                          [all[mykey].indices.minItem, all[mykey].indices.maxItem, \lin, 1, all[mykey].indices.minItem].asSpec);
                    };

                    if (recursive) {
                        pn.folders.do({|dir|
                            var folderName = if (mykey.asString.size > 0) {
                                "%_%". format(mykey, dir.folderName)
                            }{
                                dir.folderName
                            };
                            recurse.(dir.fullPath, folderName);
                        });
                    }
                }
            };
            recurse.(path, key.asString);
            "buffers loaded".debug(key);
        });
    }

    *onsets {|buf, threshold=(0.1), metric=9|

        //var result = Deferred();
        var server = Server.default;
        var indices = Buffer(server);
        FluidBufOnsetSlice.processBlocking(server, buf, indices:indices, metric:metric, threshold:threshold, action:{
            indices.loadToFloatArray(action: {|array|
                buf.addUniqueMethod(\onsets, { array.as(Array) / buf.numFrames });
                {
                    FluidWaveform(buf, indices);
                    //buf.addUniqueMethod(\onsetview, { view });
                    //indices.free;
                }.defer;
                "done".debug("B.onsets");
            });
        });        
        ^nil
    }

    *transients {|buf|

        var server = Server.default;
        var indices = Buffer(server);
        FluidBufTransientSlice.processBlocking(server, buf, indices:indices, action:{
            indices.loadToFloatArray(action: {|array|
                buf.addUniqueMethod('transients', { array.as(Array) / buf.numFrames });
                {
                    FluidWaveform(buf, indices);
                }.defer;
                "done".debug("B.transients");
            });
        });
        ^nil
    }

    // split a buffer containing multiple wavetables
    // into consequtive buffers
    *splitwt {|key, path, wtsize=2048|

        var buf, result = Deferred();

        fork({
            var def = B.read(path, [0]);
            def.wait();
            buf = def.value;

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
                if (size == 1) {
                    bufs = bufs.first;
                };
                all.put(key, bufs);
                result.value = all[key]
            });
        })

        ^result;
    }

    *combineWtDir {|path, dest, samplesize=2048|

        var paths, file, data, outFile;
        var signal = Signal.newClear(0);
        paths = "%/*.wav".format(path).pathMatch;//.debug("path");
    
        Routine({
            paths.do {|path, i|
                path.debug("combineDir");
                file = SoundFile.openRead(path);
                data = Signal.newClear(file.numFrames);
                file.readData(data);
                0.1.wait;
                signal = signal.addAll(data.resamp1(samplesize).as(Signal));
            };
    
            outFile = SoundFile(dest)
            .headerFormat_("WAV")
            .sampleFormat_("float")
            .numChannels_(1)
            .sampleRate_(48000);
    
            if(outFile.openWrite.notNil) {
                outFile.writeData(signal);
                0.1.wait;
            } {
                "Couldn't write output file".warn;
            };

            \done.debug(dest);
    
        }).play
    }

    
    // prefer combining separate wt into one buf and use the oversampled oscillators wt ugen
    *loadwt {|key, path|

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
    *convertwt {|path|
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

    *conv {|key, path, fftsize=2048|
        
        var spectrums = List.new;
        Buffer.read(Server.default, path, action:{arg buf;
            var numChannels = buf.numChannels;
            numChannels.do({arg i;
                Buffer.readChannel(Server.default, path, channels:i.asArray, action:{arg irbuffer;
                    var size = PartConv.calcBufSize(fftsize, irbuffer);
                    var spectrum = Buffer.alloc(Server.default, size, 1);
                    spectrum.preparePartConv(irbuffer, fftsize);
                    spectrums.add(spectrum);
                });
            });
        });

        all[key] = spectrums;
    }

    *initClass {
        all = IdentityDictionary();
        filetypes = [\wav, \aif, \aiff];
    }
}
