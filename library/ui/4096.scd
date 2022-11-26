/*

~size = 4096
~file = SoundFile.openRead("/Users/david/Documents/supercollider/resources/4096 Volume 1 (NeverEngine Labs)/Signals/Single Cycles/Brightfm_85046.wav");
~sig = Signal.newClear(~file.numFrames);
~file.readData(~sig);
~sig.plot

~imag = Signal.newClear(~size)
~cosTable = Signal.fftCosTable(~size)
~complex = fft(~sig, ~imag, ~cosTable)
~mag = ~complex.magnitude.normalize * ~sig.peak
~phs = ~complex.phase + (pi/2) % 2pi
plot([ ~mag[0..50], ~phs[0..50] ]).plotMode_(\bars)

*/

(
func: {|node|
    var path = "/Users/david/Documents/supercollider/resources/4096 Volume 1 (NeverEngine Labs)/Signals/Necklaces (concatenated renders)/Single Cycles 141n.wav";
    var key = 'wavetables';
    var buf = Halo.at(key);
    var view, sfv;
    var wavetables = Array.new(141);
    var loadView;
    var currentsfv;
    var wtnum = node.get(\wtnum);
    var wtpage = node.get(\wtpage);
    view = View().layout_(VLayout());

    loadView = {|buf|
        var sfv;
        sfv = {|data, index|
            var mysfv;
            mysfv = SoundFileView()
            .gridOn_(false)
            .drawsRMS_(false)
            .drawsBoundingLines_(false)
            .waveColors_( [node.color] )
            .mouseUpAction_({|ctrl|
                {
                    var wt = wavetables[index];
                    Buffer.loadCollection(Server.default, wt, action:{|buf|
                        node.set(\buf, buf.bufnum)
                    });
                    node.set(\wtpage, '4096', \wtnum, index);
                    if (currentsfv.notNil){
                        currentsfv.background = Color.clear;
                    };
                    ctrl.background = Color.white.alpha_(0.3);
                    currentsfv = ctrl;
                }.defer;
            });
            mysfv.setData(data, channels: 1);
            if (index == wtnum and: {wtpage == '4096'}) {
                mysfv.background = Color.white.alpha_(0.3);
                currentsfv = mysfv;
            };
            mysfv
        };

        buf.loadToFloatArray(action:{|a|
            {
                var layout = HLayout();
                141.do({|i|
                    var start, len, wt;
                    start = i * 4096;
                    len = 4096;
                    wt = a[start..(start+len-1)];//.as(Signal);
                    layout.add( sfv.(wt, i) );

                    wt.as(Signal).asWavetable;
                    wavetables.add( wt.as(Signal).asWavetable );
                    if (i > 0 and: { i.mod(7) == 0} ) {
                        view.layout.add(layout);
                        layout = HLayout();
                    }
                });
            }.defer
        });
    };

    // redo with await
    if (buf.isNil) {
        Buffer.read(Server.default, path, action:{|buf|
            loadView.(buf);
        })
    } {
        loadView.(buf);
    };

    view
}
)
