var vstlist;
Require("~/projects/droptableuser/library/ui/common.scd");
(
func: {arg matrix;

    var vsts = {

        var vstlist = Halo.at(\matrix_vstlist);

        if (vstlist.isNil) {
            // get the unique list of plugins
            // prefering vst3 if vst2 version also exists
            var plugins = ();
            var list = V
            .ls
            .reject({arg val;
                var plugin = VSTPlugin.plugins[val.asSymbol];
                plugin.isNil
                or: {
                    VSTPlugin.plugins[val.asSymbol].category.contains("Instrument")
                }
                or: {
                    VSTPlugin.plugins[val.asSymbol].category.contains("Synth")
                }
            });

            list.do({|name|
                var noext;
                name = name.asString;
                noext = name.split($.)[0].asSymbol;
                if (plugins[noext].isNil) {
                    plugins.put(noext, 0);
                };
                if (name.endsWith("vst3")) {
                    plugins[noext] = 1
                };
            });

            vstlist = plugins.keys
            .collect({|item| if (plugins[item] == 1) { "%.vst3".format(item).asSymbol }{item} })
            .asArray
            .sort;

            Halo.put(\matrix_vstlist, vstlist);
        };
        vstlist
    };

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

    var view, viewListener, baseViewFunc, ctrlView, playView;
    var matrixPlayView, baseview, outergrid, height, width, colors, path;
    var grid, gridview, func, listener, paths, st;

	view = View().layout_(VLayout().margins_(2).spacing_(2));
	viewListener = {arg obj, key, val;
		view.changed(key, val);
	};
	baseViewFunc = Fdef(\baseview);
	ctrlView = Fdef(\ctrlview);
	playView = Fdef(\playview);
	matrixPlayView;

	outergrid = View().layout_(VLayout().margins_(0).spacing_(0));
	width = 50;
	height = 20;
	colors = 30.collect({ Color.rand });
	path = App.librarydir ++ "fx/";

	paths = browse.(path);

	st = {
		StaticText().string_("...")
		.setContextMenuActions(
			*(
				paths.collect({arg path;
					var name = path.folderName ++ '/' ++ path.fileNameWithoutExtension;
					MenuAction( name, {arg action, what, value;
						var id = action.string;
						var nodeid = path.fileNameWithoutExtension;
                        var node = Send()
                        .key_((nodeid ++ '_' ++ UniqueID.next).asSymbol)
                        .fx(id.asSymbol);
						matrix.addSrc(node);
					});
				})
				++ vsts.().collect({arg vst;
					MenuAction(vst, {arg action;
						var id = action.string;
						var unique = (id ++ '_' ++ UniqueID.next).asSymbol;
                        var node = Send().key_(unique).fx("vst:%".format(id.asSymbol).asSymbol);
						matrix.addSrc(node);
					})
				})
			)
		);
	};

	grid = {

        var header, rows, val;
		var data = matrix.map;

        header = [st.()] ++ data.indices
		.reject({|j|
			data[j].isKindOf(NodeProxy).not
		})
		.collect({arg i;
			var name = data[i].key.asString;
			var len = min(name.size, 5);
			StaticText().string_(name[0..len]).toolTip_(name).minWidth_(50);
		});

		rows = data.indices.collect({arg i;

            var del, srcName, cols;
			var srcNode = data[i];

			del = HLayout(

                /*
                StaticText().string_(srcNode.key).toolTip_(srcNode.key)
				.mouseUpAction_({|ctrl, x, y, mod, num, click|
                    srcNode.gui;
                }),
                */

                nil
			);

			srcName = HLayout(

                Button()
                .action_({|ctrl|
                    matrix.removeSrc(srcNode.key);
                })
                .states_( [ [nil, nil, Color.clear] ] )
                .fixedSize_(20)
                .focusColor_(Color.clear)
                .icon_(Image.new(App.librarydir ++ "images/noun_Delete_1982479.png")),

                Button()
                .action_({|ctrl|
                    srcNode.gui;
                })
                .states_( [ [nil, nil, Color.clear] ] )
                .focusColor_(Color.clear)
                .fixedSize_(20)
                .toolTip_(srcNode.key)
                .icon_(Image.new(App.librarydir ++ "images/noun-gear-4855976.png"))
                ,

				if (srcNode.isKindOf(NodeProxy)) {
                    playView.(srcNode)
				} {
					if (srcNode.respondsTo(\node)) {
						playView.(srcNode.node);//.background_(Color.red)
					}
				};
			);

			cols = [srcName] ++ data.indices
			.reject({|j|
				data[j].isKindOf(NodeProxy).not
			})
			.collect({arg j;

				var ctrlview;
				var destNode = data[j];
				var val = 0;
				var hassrc = false;

				if (destNode[i].notNil) {
					hassrc = true;
					val = destNode.get(srcNode.key);
				};

				ctrlview = ctrlView.("", [0, 1, \lin, 0, 0].asSpec, colors[j], val, {arg key, val;
					if (destNode[i].isNil/*hassrc.not*/)  {
						destNode.mix(i, srcNode, val);
					};
					destNode.set(srcNode.key, val);
				});

				VLayout(nil, ctrlview.asView.maxHeight_(20))
			});

            [[del, columns:2], cols];
            //[cols];
		});

        val = [header] ++ rows.flatten;

		View().layout_(
            GridLayout.rows(*val).margins_(1).spacing_(2)
		);
	};

	gridview = grid.();

	func = {
		outergrid.children.do({arg child;
			child.remove();
		});
		outergrid.layout.add(grid.());
		outergrid.layout.add(nil);
	};

	listener = {arg node, event;
		if ((event == \add)) {
			func.();
		};
		if ((event == \remove)) {
			func.();
		}
	};

	matrix.addDependant(listener);
	outergrid.layout.add(gridview);
	view.layout.add(outergrid);

	view.onClose_({
		\onclose.debug(\matrix);
		matrix.removeDependant(listener);
	});

    baseview = baseViewFunc.(view, 'matrix');
	baseview.front;
}
)