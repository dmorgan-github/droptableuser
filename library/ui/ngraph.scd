(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\ngraph, {|node|
    //var node = S.atui.node;

    var baseViewFunc = Fdef(\baseview);
    var playview = Fdef(\playview);
    var baseview;
    var path = App.librarydir ++ "fx/";
    var keys, vals;
    var view = View().layout_(VLayout())
    .minWidth_(300)
    .minHeight_(300);

    var ev = EnvelopeView()
    .thumbWidth_(75.0)
    .thumbHeight_(35.0)
    .drawLines_(true)
    .drawRects_(true)
    .selectionColor_(Color.red)
    .gridColor_(Color.clear)
    .gridOn_(true)
    .mouseDownAction_({|ctrl, x, y, modifiers, buttonNumber, clickCount|
        if (clickCount == 2) {
            var index = ctrl.lastIndex;
            index = node.chain.indices[index];
            node.view(index);
        }
    })
    .keyUpAction_({|ctrl, char, modifiers, unicode, keycode, key|
        if (key == 16777219) {

            var remove = ctrl.lastIndex;
            var xVals = ctrl.value[0];
			var yVals = ctrl.value[1];

            xVals.removeAt(remove);
            yVals.removeAt(remove);

            ctrl.valueAction_([xVals, yVals]);
            remove = node.chain.indices[remove];
            node.fx(remove, nil);

            // reset labels
            keys = node.chain.array.do({|obj, i|
                ctrl.setString(i, obj.key.asString);
            });
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
                    node.appendFx(id.asSymbol);
                    values = ev.value;
                    index = values[0].size;
                    values[0] = values[0] ++ [0.5];
                    values[1] = values[1] ++ [0.5];
                    ev.value = values;
                    ev.setString(index, id.asString);
                    ev.setFillColor(index, Color.rand);
                    //ev.connect(index, index);
                });
            })
        )
    );

    view.setBackgroundImage(Image.new(SCDoc.helpSourceDir +/+ "images/Swamp.png"), 11, 0.3);
    keys = node.chain.array.collect({|obj| obj.key});
    vals = keys.size.collect({|i|
        var num = i+1;
        var val = 1 - (num/keys.size);
        var x=0;//(i*75)/(keys.size * 75);
        var y=(i*35)/(keys.size * 35);
        [x,1-y]
    }).flop;

    ev.value = vals;
    keys.do({|key, i|
        ev.setString(i, key.asString);
        ev.setFillColor(i, Color.rand);
    });

    playview = playview.(node);
    view.layout.add(playview);
    view.layout.add(ev);

    baseview = baseViewFunc.(view, "% chain".format(node.key));
    baseview.front;
});
)