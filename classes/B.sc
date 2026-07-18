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

    *toFloatArray {|buf|
        buf.loadToFloatArray(action: {|array|
            var result = array.as(Array);
            "done".debug("B.extract -> <buf>.floatArray");
            buf.addUniqueMethod(\floatArray, { result })
        })
    }

    *pv {|key, path|
        var file, channels, buf, func;
        var fftsize = 8192, hop = 0.25, win = 0;
        path = B.prEnsurePath(path);
        file = SoundFile.openRead(path.debug("path")).close;
        channels = if (file.numChannels.debug('numchannels') < 2) { [0,0] }{ [0, 1] };

        B.prRead(path, channels, action:{|buf|
            func = { Buffer.alloc(Server.default(), buf.duration.calcPVRecSize(fftsize, hop)) } ! 2;
            "buf % recording fft...".format(key).inform;
            { 
                var sig, chain, localbuf; 
                sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf), doneAction: 2); 
                localbuf = { LocalBuf.new(fftsize) } ! 2; 
                chain = FFT(localbuf, sig, hop, win); 
                chain = PV_RecordBuf(chain, func, run: 1, hop: hop, wintype: win); 
                0; 
            }.play.onFree({ 
                "buf % ready".format(key).inform;
                buf.free;
                all.put(key, func);
            })
        });
    }

    *inspect {|path|
        var sf;
        sf = SoundFile.openRead(path);
        sf.inspect;
        sf.close;
    }

    *mono {|key, path, action|

        B.loadFiles(key, path.asArray, 1)    
        /*
        if (path.isString) {
            var buf, funclist;
            funclist = FunctionList();
            funclist.addFunc(action);
            funclist.addFunc({|buf| 
                all.put(key, buf);    
            });
            B.prRead(path, [0], action:funclist);
        }{
            B.loadFiles(key, path, 1)    
        }
        */
    }

    *stereo {|key, path, action|

        B.loadFiles(key, path.asArray, 2)
        /*
        if (path.isString) {
            // load single file
            var buf, funclist;
            var file, channels;
            path = B.prEnsurePath(path);
            file = SoundFile.openRead(path).close;
            channels = if (file.numChannels.debug('numchannels') < 2) { [0,0] }{ [0, 1] };

            funclist = FunctionList();
            funclist.addFunc(action);
            funclist.addFunc({|buf| 
                all.put(key, buf);    
            });
            B.prRead(path, channels, action:funclist)
        } {
            B.loadFiles(key, path, 2)
        }
        */
    }

    // load a directory or array of paths
    *loadFiles {|key, paths, numchannels=1|

        var result, temp;
        var channels = numchannels.collect({|v| v});
        key = key.asSymbol;

        if (paths.isKindOf(String)) {
            paths = PathName(paths)
            .entries
            .collect({|pn| pn.fullPath });
        };
        
        paths = paths
        .select({|path|
            filetypes.includes(PathName(path).extension.toLower.asSymbol)
        });

        result = Array.newFrom( {nil}.dup(paths.size) );
        all[key] = result;

        fork({

            var cond = CondVar();
            paths.do({|path, i|
                B.prRead(path, channels, action:{|buf|
                    result.put(i, buf);
                    cond.signalOne();
                });  
                cond.wait(); 
            });

            temp = result.collect({|b| b.bufnum });
            result.addSpec(\index, [temp.minItem, temp.maxItem, \lin, 1, temp.minItem].asSpec);
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

    *onsets {|buf, threshold=(0.5), metric=9|
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

    /*
    (
    var pathname = PathName("/Users/david/Documents/supercollider/resources/AKWF");
    var folders = pathname.folders;
    folders.do({|pn|
        var filename = "%.%".format(pn.folderName, "wav");
        var dest = "%/%".format("/Users/david/Documents/supercollider/media/wavetables_2048/AKWF", filename);
        var src = pn.pathOnly;
        B.combineWtDir(src, dest)
    });
    "".postln;
    )
    */
    *combineWtDir {|path, dest, samplesize=2048|

        var paths, file, data, outFile;
        var signal = Signal.newClear(0);
        paths = "%/*.wav".format(path).pathMatch;//.debug("path");
    
        fork({
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
            //.sampleFormat_("int16")
            //.sampleFormat_("int32")
            .sampleFormat_("float")
            .numChannels_(1)
            //.sampleRate_(48000)
            .sampleRate_(44100)
            ;
    
            outFile.debug("B.combineWtDir");
            if(outFile.openWrite.notNil) {
                outFile.writeData(signal);
                outFile.close;
                0.1.wait;
            } {
                "Couldn't write output file".warn;
            };

            \done.debug(dest);
    
        });
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

    *prEnsurePath {|path|
        if (File.exists(path).not) {
            var pn = PathName(path.resolveRelative);
            path = pn.pathOnly ++ path;
        };
        ^path;//.debug("prEnsurePath");
    }

    *prRead {|path, channels, normalize=true, action|

        // FluidBufCompose
        path = B.prEnsurePath(path);
        if (channels.notNil) {
            channels = channels.asArray;
        };
        Buffer.readChannel(Server.default, path, channels:channels, action:{|buf|
            if (normalize) {
                buf = buf.normalize;
            };
            "num: %; dur: %; channels: %; path: %".format(buf.bufnum, buf.duration, buf.numChannels, path).inform;
            action.value(buf)
        });
    }

    *initClass {
        all = IdentityDictionary();
        filetypes = [\wav, \aif, \aiff];
    }
}
