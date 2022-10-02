/*
~buf = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
~pv = ConvRev.new("/Users/david/projects/droptableuser/CathedralRoom.wav");
(
Ndef(\pc, {
var sig = PlayBuf.ar(1, ~buf, loop:1);
sig = ~pv.ar(sig);
sig;
})
)

Ndef(\pc).play;
Ndef(\pc).stop;
*/
ConvRev {

    //http://www.echothief.com/

    var fftsize = 2048;
    var spectrums;

    *new {arg irpath;
        ^super.new.prInit(irpath);
    }

    prInit {arg inIrPath;

        spectrums = List.new;

        // TODO: clean up buffers
        Buffer.read(Server.default, inIrPath, action:{arg buf;
            var numChannels = buf.numChannels;
            numChannels.do({arg i;
                Buffer.readChannel(Server.default, inIrPath, channels:i.asArray, action:{arg irbuffer;
                    var size = PartConv.calcBufSize(fftsize, irbuffer);
                    var spectrum = Buffer.alloc(Server.default, size, 1);
                    spectrum.preparePartConv(irbuffer, fftsize);
                    spectrums.add(spectrum);
                });
            });
        });
        ^this;
    }

    ar {arg in;
        var sig = in.asArray;
        var size = sig.size;
        var val = spectrums.collect({arg buf, i;
            PartConv.ar(sig[i%size], fftsize, buf.bufnum)
        });
        ^val;
    }
}