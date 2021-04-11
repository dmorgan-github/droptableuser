(
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\matrix, {arg matrix;

	var view = View().layout_(VLayout().margins_(2).spacing_(2));
	var viewListener = {arg obj, key, val;
		view.changed(key, val);
	};
	var baseViewFunc = Fdef(\baseview);
	var ctrlView = Fdef(\ctrlview);
	var playView = Fdef(\playview);
	var matrixPlayView;

	var baseview;
	var outergrid = View().layout_(VLayout().margins_(0).spacing_(0));
	var width = 50;
	var height = 20;
	var colors = 30.collect({ Color.rand });
	var path = App.librarydir ++ "fx/";

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
	var st = {
		StaticText().string_("...")
		.setContextMenuActions(
			*(
				paths.collect({arg path;
					var name = path.folderName ++ '/' ++ path.fileNameWithoutExtension;
					MenuAction( name, {arg action, what, value;
						//[action.string, what, value].postln;
						var id = action.string;
						var nodeid = path.fileNameWithoutExtension;
						var node = N((nodeid ++ '_' ++ UniqueID.next).asSymbol).fx_(id.asSymbol);
						node.postln;
						matrix.addSrc(node);
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
	};

	var grid = {

		var data = matrix.map;

		var header = [st.()] ++ data.indices
		.reject({|j|
			data[j].isKindOf(NodeProxy).not
		})
		.collect({arg i;
			var name = data[i].key.asString;
			var len = min(name.size, 5);
			StaticText().string_(name[0..len]).toolTip_(name).minWidth_(50);
		});

		var rows = data.indices.collect({arg i;

			var srcNode = data[i];

			var del = HLayout(

                {
                    var node = srcNode;
                    var view = View().layout_(VLayout().margins_(0).spacing_(0))
                    //.palette_(QPalette.dark)
                    .maxHeight_(10);
                    var scope = Stethoscope.new(s, view:view).style_(1)
                    .index_(node.bus.index)
                    .numChannels_(2).yZoom_(2).xZoom_(2);
                    //win.onClose = { scope.free;  };
                    4.do({
                        view.children[0].children[0].remove
                    });
                    view.children[0].children[0].waveColors_([Color.rand, Color.rand]);
                    view.children[0].children[2].remove;
                    view.children[0].children[1].remove;
                    view.maxHeight = 20;
                    view.children[0].children[0].background = Color.new255(77, 77, 77);
                    view.maxWidth = 80;
                    view.onClose = { \freescope.postln; scope.free };
                    view;
                }.(),

                StaticText().string_(srcNode.key).toolTip_(srcNode.key)
				.mouseUpAction_({|ctrl, x, y, mod, num, click|
					if (srcNode.respondsTo(\view)) {
						srcNode.view;
					}
                }),

                nil
			);

			var srcName = HLayout(

                Button()
                .action_({|ctrl|
                    matrix.removeSrc(srcNode.key);
                })
                .fixedSize_(20)
                .icon_(Image.new(App.librarydir ++ "images/noun_Delete_1982479.png")),

                Button()
                .action_({
                    srcNode.nscope
                })
                .fixedSize_(20)
                .icon_(Image.new(App.librarydir ++ "images/noun_pulse_1464765.png")),

				if (srcNode.isKindOf(NodeProxy)) {
					playView.(srcNode)
				} {
					if (srcNode.respondsTo(\node)) {
						playView.(srcNode.node);//.background_(Color.red)
					}
				};
			);

			var cols = [srcName] ++ data.indices
			.reject({|j|
				data[j].isKindOf(NodeProxy).not
			})
			.collect({arg j;
				var ctrlview;
				var destNode = data[j];
				var val = 0;
				var hassrc = false;
				if (destNode[i].isNil.not) {
					hassrc = true;
					val = destNode.get(srcNode.key);
				};
				ctrlview = ctrlView.("", [0, 1, \lin, 0, 0].asSpec, colors[j], val, {arg key, val;
					if (hassrc.not)  {
						destNode.mix(i, srcNode, val);
					};
					destNode.set(srcNode.key, val);
				});

				VLayout(nil, ctrlview.asView.maxHeight_(20))
			});

            [[del, columns:2], cols];
		});

        var val = [header] ++ rows.flatten;

		View().layout_(
            GridLayout.rows(*val).margins_(1).spacing_(2)
		);
	};

	var gridview = grid.();

	var func = {
		outergrid.children.do({arg child;
			child.remove();
		});
		outergrid.layout.add(grid.());
		outergrid.layout.add(nil);
	};

	var listener = {arg node, event;
		if ((event == \add)) {
			func.();
		};
		if ((event == \remove)) {
			func.();
		}
	};

	matrix.addDependant(listener);
	matrixPlayView = playView.(matrix);//.addDependant(viewListener);

	view.layout.add(matrixPlayView);
	outergrid.layout.add(gridview);
	view.layout.add(outergrid);

    view.setBackgroundImage(Image.new(SCDoc.helpSourceDir +/+ "images/Swamp.png"), 11, 0.3);
	view.onClose_({
		\onclose.debug(\matrix);
		matrix.removeDependant(listener);
		//playview.removeDependant(viewListener);
	});

	baseview = baseViewFunc.(view, matrix.key);
	baseview.front;
});
)