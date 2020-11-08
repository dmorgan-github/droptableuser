(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\workspace, {|ws|

	var baseview;
	var baseViewFunc = Fdef(\baseview);
	var playview = Fdef(\playview);
	var view = View().layout_(VLayout().spacing_(0).margins_(0));
	var path = App.workspacedir ++ ws.key;
	var outerview = View().layout_(VLayout().spacing_(0).margins_(0));

	var innerview = {

		var view = View().layout_(VLayout().spacing_(0).margins_(0));
		ws.keysValuesDo({|k, v|
			if (v.respondsTo(\view)) {
				var row = HLayout().margins_(0).spacing_(0);

				var key = k.asString[0..9];
				row.add(Button()
					.action_({|ctrl| v.nscope })
				);
				row.add(Button()
					.action_({|ctrl| v.view })
					.states_([ [key], [key] ])
					.toolTip_(k)
				);
				if (v.isKindOf(S)) {
					row.add(playview.(v.node));
				}{
					row.add(playview.(v));
				};
				view.layout.add(row);
			} {
				"skipping key %".format(k).warn
			}
		});
		view;
	};

	var func = {
		outerview.children.do({arg child;
			child.remove();
		});
		outerview.layout.add(innerview.());
		outerview.layout.add(nil);
	};

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

		if (vstlist.isNil) {
			vstlist = V
			.ls
			.reject({arg val;
				val.asString.endsWith(".vst3") or: val.asString.contains("/");
			});
			vstlist = vstlist.sort;
		};
		vstlist
	};

	var paths = browse.(App.librarydir ++ "fx/");
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
						//ws.matrix.addSrc(node);
						ws[node.key] = node;
						func.();
					});
				})
				++ vsts.().collect({arg vst;
					MenuAction(vst, {arg action;
						var id = action.string;
						var unique = (id ++ '_' ++ UniqueID.next).asSymbol;
						var node = V(unique).load(id.asSymbol);
						//ws.matrix.addSrc(node);
						ws[node.key] = node;
						// it takes a moment to load the vst
						// and will error if trying to render it too quickly
						{ func.() }.defer(2);
					})
				})
			)
		);
	};

	thisProcess.platform.recordingsDir_(path.debug(\recdir));

	view.layout.add(HLayout(
		st.(),
		Button()
		.action_({|ctrl|
			Server.default.makeGui
		})
		.states_([ ["server"] ]),

		Button()
		.action_({|ctrl|
			ws.sends;
		})
		.states_([ ["sends"] ]),

		Button()
		.action_({|ctrl|
			if (ctrl.value == 1) {
				App.saveWorkspace(ws.key, rec:true);
			} {
				\stoprecording.postln;
				Server.default.stopRecording;
			}
		})
		.states_([ ["rec", Color.red], ["stop", Color.red] ])
	));
	view.layout.add(
		playview.(ws.node)
	);
	/*
	view.layout.add(HLayout(
		Button(), Button(), Button()
	));
	*/

	/*
	matrixlistener = {|src, what, val|
		if (what == \add) {
			ws[val.key] = val;
			if (val.isKindOf(V)) {
				{
					// TODO: find a better place for this
					[\defering].postln;
					func.();
				}.defer(2);
			}{
				func.();
			}

		};
	};
	ws.matrix.addDependant(matrixlistener);
	*/

	func.();
	view.layout.add(outerview);
	view.onClose = {
		\onclose.debug(\workspace);
		//ws.matrix.removeDependant(matrixlistener);
	};
	baseview = baseViewFunc.(view, ws.key);
	baseview.front;
})
)
