(
func: {|node|
    var upsample = 4096;
    var currentbuf;
    var view;
    var folders, wavetables, loadwavs, list;
    var wtView = View().layout_(VLayout());
    var root = "/Users/david/Documents/supercollider/resources/AKWF";
    //root = "/Users/david/Documents/supercollider/resources/AKWF-1024/";

    folders = {|dir|
        var folders = PathName(dir).folders.collect({|pn| pn.folderName});
        folders;
    };

    loadwavs = {|path|

        var files = PathName(path)
        .files
        .select({|pn| pn.extension == "wav" });

        wavetables = Array.new(files.size);

        wtView.children.do({|child|
            child.remove()
        });

        fork {
            files.do({|pn|
                var file = SoundFile.openRead(pn.fullPath);
                var data = Signal.newClear(file.numFrames);
                file.readData(data);
                data = data.resamp1(upsample);
                wavetables.add(data);
            });

            {
                var layout;
                layout = HLayout();
                wavetables.do({|data, index|

                    var sfv;
                    sfv = SoundFileView()
                    .gridOn_(false)
                    .drawsRMS_(false)
                    .drawsBoundingLines_(false)
                    .waveColors_( [node.color] )
                    .mouseDownAction_({|ctrl, x, y, modifiers, buttonNumber, clickCount|

                        if (clickCount == 2) {
                            //
                        }{
                            {
                                var wt = wavetables[index];
                                wt = wt.resamp1(4096);// with linear interpolation
                                wt = wt.as(Signal).asWavetable;
                                Buffer.loadCollection(Server.default, wt, action:{|buf|
                                    node.set(\buf, buf.bufnum);
                                    currentbuf.free({  currentbuf = buf; 1});
                                });
                            }.defer;
                        }
                    });

                    sfv.setData(data, channels: 1);
                    layout.add(sfv);

                    if (files.size < 7) {
                        wtView.layout.add(layout);
                    } {
                        if (index > 0 and: { index.mod(7) == 0} ) {
                            wtView.layout.add(layout);
                            layout = HLayout();
                        }
                    }
                });

            }.defer
        };
    };

    list = folders.(root);
    view = View().layout_(VLayout());
    view.layout.add(
        PopUpMenu()
        .items_([""] ++ list)
        .action_({|ctrl|
            if (ctrl.item != "") {
                var path = "%/%".format(root, ctrl.item);
                loadwavs.(path);
            }
        })
    );
    view.layout.add(wtView);
    view
}
)