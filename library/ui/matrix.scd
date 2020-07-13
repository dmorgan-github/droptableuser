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
	var width = 75;
	var colors = 30.collect({ Color.rand });

	var grid = {

		var data = matrix.map;
		var header = [nil] ++ data.indices.collect({arg i; StaticText().string_(data[i])});
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

			[row] ++ cols;
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
		if (event == \source) {
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
