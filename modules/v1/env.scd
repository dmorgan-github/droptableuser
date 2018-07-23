(
//////////////////////////////////
// retrigerable line
~tline = {arg trig = [0], start = [1], end = [1], dur = [1], ts = [1], curve = [0], func = {arg env;env};
	{
		var trig_in = \trig.kr(trig);
		var ts_in = \ts.kr(ts);
		var start_in = \start.kr(start);
		var end_in = \end.kr(end);
		var dur_in = \dur.kr(dur);
		var curve_in = \curve.kr(curve);
		var ls_in = \ls.kr(1);
		var env = Env([start_in,start_in,end_in],[0,dur_in],curve_in).kr(gate:trig_in, timeScale:ts_in, mul:ls_in);
		func.(env);
	};
};
Library.put(\modules, \env, \tline, ~tline);

//////////////////////////////////
// retrigerable linen env
~tlinen = {arg trig = [0], atk = 0.01, sus = 1, rel = 1, curve = (-4), ts = 1, func = {arg env;env};

	{
		var trig_in = \trig.kr(trig);
		var ts_in = \ts.kr(ts);
		var atk_in = \atk.kr(atk);
		var sus_in = \sus.kr(sus);
		var rel_in = \rel.kr(rel);
		var curve_in = \curve.kr(curve);
		var ls_in = \ls.kr(1);
		var env = Env.linen(atk_in,sus_in,rel_in,curve:curve_in).kr(gate:trig_in, timeScale:ts_in, mul:ls_in);
		func.(env);
	};
};
Library.put(\modules, \env, \tlinen, ~tlinen);

//////////////////////////////////
// retrigerable perc env
~tperc = {arg trig = [0], atk = 0.01, rel = 1, curve = (-4), ts = 1, func = {arg env;env};

	{
		var trig_in = \trig.kr(trig);
		var ts_in = \ts.kr(ts);
		var atk_in = \atk.kr(atk);
		var rel_in = \rel.kr(rel);
		var curve_in = \curve.kr(curve);
		var ls_in = \ls.kr(1);
		var env = Env.perc(atk_in,rel_in,curve:curve_in).kr(gate:trig_in, timeScale:ts_in, mul:ls_in);
		func.(env);
	};
};
Library.put(\modules, \env, \tperc, ~tperc);

~tatkrel = {arg trig = [0], start = 0, peak = 1, end = 0, atk = 0.01, rel = 1, curve = 0, ts = 1, func = {arg env;env;};

	{
		var trig_in = \trig.kr(trig);
		var curve_in = \curve.kr(curve);
		var start_in = \start.kr(start);
		var end_in = \end.kr(end);
		var peak_in = \peak.kr(peak);
		var atk_in = \atk.kr(atk);
		var rel_in = \rel.kr(rel);
		var ts_in = \ts.kr(ts);
		var ls_in = \ls.kr(1);
		var env = Env([start_in, peak_in, end_in],[atk_in,rel_in],curve_in).kr(gate:trig_in, timeScale:ts_in, mul:ls_in);
		func.(env);
	}
};
Library.put(\modules, \env, \tatkrel, ~tatkrel);

~env_editor = {

	var obj = (
		node: NodeProxy.control,
		show: {arg self;
			var node = self.node;
			var me = self;
			self.show_ui({arg env;

				me.env = env;
				node[0] = {
					EnvGen.kr(env, gate:\trig.tr(0), levelScale:\ls.kr(1), timeScale:\ts.kr(1));
				};
			});
		},

		show_ui: {arg self, func = {arg env; env};

			var font = Font("Courrier New", 10);

			var height = 20;

			var view = View().layout_(VLayout().margins_(2).spacing_(2));

			view.layout.add(

				HLayout(

					EnvelopeView()
					.fixedSize_(200@100)
					.keyDownAction_({arg view, char, modifiers, unicode, keycode, key;

						if (key == 16777219) {

							var xVals = view.value[0];
							var yVals = view.value[1];
							var remove = view.selection;

							remove.reverseDo({arg index;
								xVals.removeAt(index);
								yVals.removeAt(index);
							});

							view.valueAction_([xVals, yVals]);
						};
					})
					.mouseDownAction_({arg view, x, y, modifiers, buttonNumber, clickCount;

						var width = view.bounds.width;
						var height = view.bounds.height;

						if (clickCount == 2) {

							var vals;
							var xVals, yVals;
							var nearest, index;
							var newX, newY;

							x = x.linlin(0, width, 0, 1);
							y = y.linlin(0, height, 0, 1);
							vals = view.value;

							xVals = vals[0];
							yVals = vals[1];

							nearest = x.nearestInList(xVals);
							index = xVals.indexOf(nearest);
							if (x > nearest) {
								index = index + 1;
							};
							newX = xVals.insert(index, x);
							newY = yVals.insert(index, 1-y);

							view.valueAction_([newX, newY]);
						}
					})
					.drawLines_(true)
					.selectionColor_(Color.red)
					.drawRects_(true)
					.resize_(5)
					.step_(0.05)
					.thumbSize_(10)
					.keepHorizontalOrder_(true)
					.value_([[0.0, 0.1, 1.0],[0.0,1.0,0.0]])
					.action_({arg ctrl;
						func.(ctrl.asEnv);
					})
				);
			);

			view.front;
		};
	);
	obj;
};
Library.put(\modules, \env, \env_editor, ~env_editor);

)






