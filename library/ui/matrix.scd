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
				++ vsts.().collect({arg vst;
					MenuAction(vst, {arg action;
						var id = action.string;
						var unique = (id ++ '_' ++ UniqueID.next).asSymbol;
						var node = V(unique).load(id.asSymbol);
						matrix.addSrc(node);
					})
				})
			)
		);
	};

	var grid = {

		var data = matrix.map;

		var header = [st.(), nil] ++ data.indices
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

			var del = VLayout(
				StaticText().string_(srcNode.key).toolTip_(srcNode.key)
				.mouseUpAction_({|ctrl, x, y, mod, num, click|
					if (srcNode.respondsTo(\view)) {
						srcNode.view;
					}
				}),
				HLayout(
					Button()
					.states_([["x"]])
					.action_({|ctrl|
						matrix.removeSrc(srcNode.key);
					})
					.maxWidth_(height+2),
					Button()
					.states_([["sc"]])
					.action_({
						srcNode.nscope
					})
					.maxWidth_(height+2)
				)
			);

			var srcName = VLayout(
				nil,
				if (srcNode.isKindOf(NodeProxy)) {
					playView.(srcNode)
				} {
					if (srcNode.respondsTo(\node)) {
						playView.(srcNode.node);//.background_(Color.red)
					}
				}
			);

			var cols = [del, srcName] ++ data.indices
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
						destNode.mix(i, srcNode);
					};
					destNode.set(srcNode.key, val);
				});

				VLayout(nil, ctrlview.asView.maxHeight_(20))
			});

			cols;
		});

		var val = [header] ++ rows;

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

	view.onClose_({
		\onclose.debug(\matrix);
		matrix.removeDependant(listener);
		//playview.removeDependant(viewListener);
	});

	baseview = baseViewFunc.(view, matrix.key);
	baseview.front;
});
)
