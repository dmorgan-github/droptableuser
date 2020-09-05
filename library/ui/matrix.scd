(
Require("~/projects/droptableuser/library/ui/common.scd");
Fdef(\matrix, {arg matrix;

	var view = View().layout_(VLayout().margins_(2).spacing_(2));
	var viewListener = {arg obj, key, val;
		view.changed(key, val);
	};
	var baseViewFunc = Fdef(\baseview);
	var playview = Fdef(\playview);
	var ctrlView = Fdef(\ctrlview);

	var baseview;
	var outergrid = View().layout_(VLayout().margins_(0).spacing_(0));
	var width = 50;
	var colors = 30.collect({ Color.rand });
	var vstlist;

	var path = App.librarydir ++ "fx/";

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

		/*
		if (vstlist.isNil) {
			vstlist = Vst
			.directory
			.reject({arg val;
				val.asString.endsWith(".vst3") or: val.asString.contains("/");
			});
			vstlist = vstlist.sort;
		};
		vstlist
		*/

		[
			'++binaural',
			'++bubbler',
			'++chebyshev',
			'++compand',
			'++decimate',
			'++delay',
			'++flipper',
			'++matrix',
			'++morphfilter',
			'++phasemash',
			'++phasor',
			'++pitchdelay',
			'++pitchsift',
			'++pvocloop',
			'++spectralcompand',
			'++spiralstretch',
			'++spectralgate',
			'TDR Kotelnikov',
			'Raum',
			'Rev PLATE-140',
			'ValhallaDelay',
			'ValhallaSupermassive',
			'Limiter No6',
			'OrilRiver'
		]
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
						var node = N((nodeid ++ '_' ++ UniqueID.next).asSymbol,  id.asSymbol);
						matrix.add(node.key);
					});
				})
				++ vsts.().collect({arg vst;
					MenuAction(vst, {arg action;
						var id = action.string;
						var unique = (id ++ '_' ++ UniqueID.next).asSymbol;
						var node = Vst(unique).vst = id.asSymbol;
						matrix.add(node.key);
					})
				})
			)
		);
	};

	var grid = {

		var data = matrix.map;

		var header = [st.(), nil, nil, nil] ++ data.indices.collect({arg i;
			var name = data[i].asString;
			var len = min(name.size, 5);
			if (Pdef.all[name.asSymbol].isNil) {
				StaticText().string_(name[0..len]).toolTip_(name)
			} {
				nil
			}
		});

		var rows = data.indices.collect({arg i;

			var src = data[i];
			var val = matrix.get(src);

			var row = ctrlView.(src, [0, 1, \lin, 0, 0].asSpec, colors[i], val, {arg key, val;
				matrix.set(src, val);
			}).minWidth_(width);

			var cols = data.indices.collect({arg j;
				var ctrlview;
				var dest = data[j];
				var val = 0;
				var hassrc = false;
				if (Ndef(dest)[i].isNil.not) {
					hassrc = true;
					val = Ndef(dest).get(src);
				};
				// imperfect but we don't want to route
				// to an synth
				if (Pdef.all[dest].isNil) {
					ctrlview = ctrlView.("", [0, 1, \lin, 0, 0].asSpec, colors[j], val, {arg key, val;
						if (hassrc.not)  {
							Ndef(dest).mix(i, Ndef(src));
						};
						Ndef(dest).set(src, val);
					});
					ctrlview.minWidth_(width);
				} {
					nil
				}
			});

			[
				Button()
				.states_([ ["x", nil, colors[i]] ])
				.fixedSize_(Size(15, 25))
				.action_({|ctrl|
					matrix.removeSrc(src);
				})
				.toolTip_("remove"),

				Button()
				.action_({ Ndef(src).nscope; })
				.fixedWidth_(15)
				.fixedHeight_(25)
				.states_([ [nil, nil, colors[i]] ])
				.toolTip_("scope"),

				Button()
				.action_({
					if (Pdef.all[src].isKindOf(S)) {
						Pdef.all[src].sgui;
					}{
						if (Ndef(src).isKindOf(Vst)) {
							Ndef(src).editor;
						}{
							Ndef(src).ngui;
						}
					}
				})
				.fixedWidth_(15)
				.fixedHeight_(25)
				.states_([ [nil, nil, colors[i]] ])
				.toolTip_("gui"),
				row
			] ++ cols;
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
		if ((event == \source)) {
			func.();
		}
	};

	matrix.addDependant(listener);
	playview = playview.(matrix).addDependant(viewListener);

	view.layout.add(playview);
	outergrid.layout.add(gridview);
	view.layout.add(outergrid);

	view.onClose_({
		\onclose.debug(\matrix);
		matrix.removeDependant(listener);
		playview.removeDependant(viewListener);
	});

	baseview = baseViewFunc.(view, matrix.key);
	baseview.front;
});
)

//~rlio.mgui;
