(
func: {|node|
    var upsample = 4096;
    var currentbuf, currentsfv;
    var view;
    var folders, wavetables, loadwavs, list;
    var wtView = View().layout_(VLayout());
    var root = "/Users/david/Documents/supercollider/resources/AKWF";
    var wtpage, selected;
    wtpage = node.get(\wtpage);

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
                var wtnum = node.get(\wtnum);
                layout = HLayout();
                wavetables.do({|data, index|

                    var sfv;
                    sfv = SoundFileView()
                    .gridOn_(false)
                    .drawsRMS_(false)
                    .drawsBoundingLines_(false)
                    .waveColors_( [node.color] )
                    //.maxSize_(60)
                    .mouseDownAction_({|ctrl, x, y, modifiers, buttonNumber, clickCount|

                        if (clickCount == 2) {
                            //
                        }{
                            {
                                var wt = wavetables[index];
                                wt = wt.resamp1(4096);// with linear interpolation
                                wt = wt.as(Signal).asWavetable;
                                Buffer.loadCollection(Server.default, wt, action:{|buf|
                                    node.set(\buf, buf.bufnum, \wtnum, index);
                                    currentbuf.free({ currentbuf = buf; 1});
                                });
                                if (currentsfv.notNil) {
                                    currentsfv.background = Color.clear;
                                };
                                sfv.background = Color.white.alpha_(0.3);
                                currentsfv = sfv;
                            }.defer;
                        }
                    });

                    sfv.setData(data, channels: 1);
                    if (index == wtnum) {
                        sfv.background = Color.white.alpha_(0.3);
                        currentsfv = sfv;
                    };

                    if ( index ==  (wavetables.size -1) ) {
                        wtView.layout.add(layout);
                    } {
                        if (index > 0 and: { index.mod(7) == 0} ) {
                            wtView.layout.add(layout);
                            layout = HLayout();
                        }
                    };

                    layout.add(sfv);
                });

            }.defer
        };
    };

    selected = 0;
    list = folders.(root);
    if (wtpage.notNil) {
        selected = list.detectIndex({|v| v == wtpage });
        if (selected.isNil) { selected = 0} { selected = selected + 1}
    };
    list = folders.(root);
    view = View().layout_(VLayout());
    view.layout.add(
        PopUpMenu()
        .items_([""] ++ list)
        .action_({|ctrl|
            if (ctrl.item != "") {
                var path = "%/%".format(root, ctrl.item);
                node.set(\wtpage, ctrl.item);
                loadwavs.(path);
            }
        })
        .valueAction_(selected)
    );
    view.layout.add(wtView);
    view
}
)
