(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\matrixgraph, {|matrix|

    var path = App.librarydir ++ "fx/";
    var baseViewFunc = Fdef(\baseview);
    var playview = Fdef(\playview);
    var baseview;
    var keys, vals;
    var view = View().layout_(VLayout()).minWidth_(400).minHeight_(400);
    var ev = EnvelopeView()
    .thumbWidth_(75.0)
    .thumbHeight_(35.0)
    .drawLines_(true)
    .drawRects_(true)
    .selectionColor_(Color.red)
    .gridColor_(Color.clear)
    .gridOn_(true)
    .mouseDownAction_({|ctrl, x, y, modifiers, buttonNumber, clickCount|

        var width = ctrl.bounds.width;
        var height = ctrl.bounds.height;

        if (clickCount == 2) {
            matrix.map[ctrl.index].view;
        }
    })
    .mouseUpAction_({|ctrl|

        if (ctrl.selection.size == 2) {
            var order = ctrl.selection.indexOf(ctrl.lastIndex);
            if (order == 0) {
                var sel = ctrl.selection.reverse;
                var src = sel[0];
                var dest = sel[1];
                ev.connect(src, dest.asArray);
                matrix.map[dest].mix(src, matrix.map[src], 1);
                matrix.map[src].stop;
            } {
                var sel = ctrl.selection;
                var src = sel[0];
                var dest = sel[1];
                ev.connect(src, dest.asArray);
                matrix.map[dest].mix(src, matrix.map[src], 1);
                matrix.map[src].stop;
            }
        }

    })
    .background_(Color.clear)
    .setEditable(0, false);

    var vstlist;
	var browse = {arg path, files=List.new;
		var folder = PathName.new(path);
		if (folder.isFolder) {
			var folders = folder.folders;
			files = files.addAll(folder.files);
			folders.do({arg folder;
				browse.(folder.fullPath, files);
			});
		};
		files;
	};

	var vsts = {
		if (~vstlist.isNil) {
			~vstlist = V
			.ls
			.reject({arg val;
				val.asString.endsWith(".vst3") or: val.asString.contains("/");
			});
			~vstlist = ~vstlist.sort;
		};
		~vstlist
	};

	var paths = browse.(path);

    ev.setContextMenuActions(
        *(
            paths.collect({arg path;
                var name = path.folderName ++ '/' ++ path.fileNameWithoutExtension;
                MenuAction( name, {arg action, what, value;
                    var index, values;
                    var id = action.string;
                    var nodeid = path.fileNameWithoutExtension;
                    var node = N((nodeid ++ '_' ++ UniqueID.next).asSymbol).fx_(id.asSymbol);
                    matrix.addSrc(node);
                    node.play;

                    values = ev.value;
                    index = values[0].size;

                    values[0] = values[0] ++ [0.5];
                    values[1] = values[1] ++ [0.5];
                    ev.value = values;
                    ev.setString(index, node.key.asString);
                    ev.setFillColor(index, Color.rand);
                    ev.connect(index, index);
                });
            })
            /*
            ++ vsts.().collect({arg vst;
                MenuAction(vst, {arg action;
                    var id = action.string;
                    var unique = (id ++ '_' ++ UniqueID.next).asSymbol;
                    var node = V(unique).load(id.asSymbol);
                    matrix.addSrc(node);
                })
            })
            */
        )
    );

    view.setBackgroundImage(Image.new(SCDoc.helpSourceDir +/+ "images/Swamp.png"), 11, 0.3);

    keys = matrix.map.array.collect({|obj| obj.key});
    vals = keys.size.collect({|i|
        var num = i+1;
        var val = 1 - (num/keys.size);
        var x=(i*75)/(keys.size * 75);
        var y=(i*35)/(keys.size * 35);
        [x,1-y]
    }).flop.postln;

    ev.value = vals;

    keys.do({|key, i|
        ev.setString(i, key.asString);
        ev.setFillColor(i, Color.rand);
    });

    ev.connect(0, [0]);
    keys[1..].do({|key, i|
        var index = i+1;
        var obj = D(key);
        var connect = obj.objects.indices
        .reject({|val|
            val > 99
        })
        .reject({|val|
            var vol = obj.get(keys[val]);
            vol.isNil or: {vol == 0}
        });
        ev.connect(index, connect);
    });

    playview = playview.(matrix);

    view.layout.add(playview);
    view.layout.add(ev);

    baseview = baseViewFunc.(view, 'graph');
    baseview.front;

});
)

