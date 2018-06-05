{
	(
		eqView: {arg name, node, envir, containerView;

			var view = View().layout_(VLayout().spacing_(2).margins_(2));

			node.filter(110, {arg in;

				var sig = in;

				var lo_freq = \lo_freq.kr(100).lag(0.2);
				var lo_db = \lo_db.kr(0).lag(0.2);

				var mid_freq = \mid_freq.kr(1000).lag(0.2);
				var mid_db = \mid_db.kr(0).lag(0.2);

				var hi_freq = \hi_freq.kr(10000).lag(0.2);
				var hi_db = \hi_db.kr(0).lag(0.2);

				sig = BPeakEQ.ar(sig, lo_freq, 1, lo_db);
				sig = BPeakEQ.ar(sig, mid_freq, 1, mid_db);
				sig = BPeakEQ.ar(sig, hi_freq, 1, hi_db);
				sig;
			}).set(\wet110, 0);

			view.layout.add(HLayout(
				Slider2D().fixedSize_(45).action_({arg ctrl;
					node.set(\lo_freq, ctrl.x.linlin(0,1,0.1,1000));
					node.set(\lo_db, ctrl.y.linlin(0,1,-18,18));
				}).x_(100.linlin(0,1000,0,1)).y_(0.linlin(-18,18,0,1)),

				Slider2D().fixedSize_(45).action_({arg ctrl;
					node.set(\mid_freq, ctrl.x.linlin(0,1,1000,10000));
					node.set(\mid_db, ctrl.y.linlin(0,1,-18,18));
				}).x_(1000.linlin(1000,10000,0,1)).y_(0.linlin(-18,18,0,1)),

				Slider2D().fixedSize_(45).action_({arg ctrl;
					node.set(\hi_freq, ctrl.x.linlin(0,1,10000,20000));
					node.set(\hi_db, ctrl.y.linlin(0,1,-18,18));
				}).x_(10000.linlin(10000,20000,0,2)).y_(0.linlin(-18,18,0,1))
			));

			view.layout.add(Slider().action_({arg ctrl;
				node.set(\wet110, ctrl.value);
			}).value_(0).orientation_(\horizontal));

			view;
		},

		specsView: {arg name, specs, node, envir, containerView;

			var mappers = ();
			var view = View()
			.layout_(VLayout().margins_(1).spacing_(1))
			.onClose_({
				specs.keysDo({arg key;
					node.unset(key);
				});
				mappers.do({arg v;
					v.clear;
					v = nil;
				});
			});

			specs.sortedKeysValuesDo({arg k,v;

				var layout = HLayout().margins_(1).spacing_(1);
				var rs = RangeSlider().orientation_(\horizontal).enabled_(false);
				var slider = Slider();
				var stack = StackLayout();
				var height = 20;

				var specKey = k.asSymbol;
				var spec = if (v == \set) {\set} {v.asSpec};

				if (mappers[k].isNil) {
					mappers[k] = NodeProxy();
				};

				if (spec == \set) {

				} {
					mappers[k][0] = { \val.kr.range(\min.kr(spec.minval), \max.kr(spec.maxval)); };
					mappers[k].set(\val, spec.default.linlin(spec.minval, spec.maxval, -1, 1));
					node.set(k, mappers[k]);
				};

				layout.add(

					if (spec == \buf) {

					} {

						var dragSink, button;

						button = Button()
						.fixedSize_(8)
						.states_([ ["x"] ])
						.font_(Font().size_(9))
						.action_({
							dragSink.string = "";
							slider.enabled_(true);
							rs.enabled_(false);
							if (spec == \set) {
								node.set(specKey, nil);
							} {
								mappers[k].set(\val, spec.map(slider.value).linlin(spec.minval, spec.maxval,-1,1));
							};

							button.enabled = false;
						})
						.enabled_(false);

						dragSink = DragSink()
						.string_("<-  " ++ k)
						.background_(Color.clear)
						.canReceiveDragHandler_({
							var obj = View.currentDrag;
							var node = obj[\node];
							(node.rate == \control);
						})
						.receiveDragHandler_({arg v;

							var obj = View.currentDrag.value;
							var lfo = obj[\node];
							var name = obj[\name];

							if (lfo.isNil.not) {
								slider.enabled_(false);
								rs.enabled_(true);
								if (spec == \set) {
									node.set(specKey, lfo);
								} {
									mappers[k].set(\val, lfo);
								};

								v.string = name;
								button.enabled = true;
							} {
								var msg = "node % doesn't exist in environment".format(name);
								NotificationCenter.notify(containerView, \status, msg);
								button.enabled = false;
							}
						})
						.maxHeight_(35)
						.minWidth_(35);

						HLayout(
							dragSink, button
						);
					}
				);

				///////////////////////////////////
				if (spec != \set) {
					layout.add(
						rs.action_({arg ctrl;
							var min = spec.map(ctrl.lo);
							var max = spec.map(ctrl.hi);
							var msg = "min: " ++ min ++ "; max: " ++ max;
							mappers[k].set(\min, min, \max, max);
							NotificationCenter.notify(containerView, \status, msg);
						})
					);

					layout.add(

						StackLayout(
							StaticText()
							.string_(k)
							.font_(Font().bold_(true))
							.minWidth_(100)
							.align_(\center),

							slider
							.orientation_(\horizontal)
							.thumbSize_(10)
							.minWidth_(100)
							.maxHeight_(height)
							.background_(Color.white.alpha_(0.0))
							.action_({arg ctrl;

								var val = spec.map(ctrl.value);
								var msg = k ++ " " ++ val;
								mappers[k].set(\val, val.linlin(spec.minval, spec.maxval, -1, 1));
								NotificationCenter.notify(containerView, \status, msg);
							})
							.value_(v.asSpec.unmap(v.asSpec.default))

						).mode_(\stackAll).index_(1)
					);
				};

				view.layout.add(layout);

			});

			view;
		},

		playView: {arg name, node, containerView;

			var height = 20;
			var wetKey = ("wet" ++ 100).asSymbol;
			var view = View().layout_(HLayout().margins_(2).spacing_(2));
			var outBus = 0;

			view.layout.add(StaticText().string_(name));

			view.layout.add(
				Slider()
				.orientation_(\horizontal)
				.thumbSize_(10)
				.fixedSize_(50@height)
				.value_(1.linlin(0,4,0,1))
				.action_({arg ctrl;

					var val = ctrl.value.linlin(0,1,0,4);
					NotificationCenter.notify(containerView, \status, "vol: " ++ val.asString);
					node.vol = val;
				})
			);

			view.layout.add(
				Slider()
				.orientation_(\horizontal)
				.thumbSize_(10)
				.fixedSize_(50@height)
				.value_(1.linlin(0.1, 8, 0, 1))
				.action_({arg ctrl;
					var val = ctrl.value.linlin(0, 1, 0.1, 8);
					node.fadeTime = val;
					NotificationCenter.notify(containerView, \status, "fadetime: " ++ val.asString);
				})
			);

			view.layout.add(

				Slider()
				.orientation_(\horizontal)
				.thumbSize_(10)
				.fixedSize_(50@height)
				.value_(1)
				.action_({arg ctrl;
					node.set(wetKey, ctrl.value);
					NotificationCenter.notify(containerView, \status, "wet: " ++ ctrl.value.asString);
				})
			);

			/*
			view.layout.add(
				NumberBox().action_({arg ctrl;
					outBus = ctrl.value.asInt;
					if (node.isPlaying) {
						node.play(out:outBus);
					}
				})
				.decimals_(0)
				.value_(0)
				.minWidth_(25)
				.normalColor_(Color.white)
			);
			*/

			view.layout.add(
				Button()
				.fixedSize_(30@height)
				.states_([ ["play"], ["stop"] ])
				.string_("play")
				.action_({arg ctrl;
					if (ctrl.value == 1) {
						node.play(fadeTime:node.fadeTime);
					} {
						node.stop(fadeTime:node.fadeTime);
					}
				})
			);

			//view.layout.add(
			//	Button()
			//	.fixedSize_(30@height)
			//	.string_("doc")
			//	.mouseDownAction_({arg ctrl; node.document; })
			//);

			view;
		},

		multiInputsView: {arg node, mainView;

			var view = View().layout_(VLayout().spacing_(1).margins_(1));

			//~bobo.objects.indices.lastIndexForWhich({arg i; i < 100;})

			var addRow = {

				var row = View().layout_(HLayout().spacing_(1).margins_(1));

				var dragSink;

				var num = -1;

				var name;

				dragSink = DragSink()
				.string_("<-  ")
				.background_(Color.clear)
				.canReceiveDragHandler_({
					var obj = View.currentDrag;
					var node = obj[\node];
					(node.rate == \audio);
				})
				.receiveDragHandler_({arg v;

					var obj = View.currentDrag.value;
					var input = obj[\node];
					var msg;

					name = obj[\name];
					msg = "inuput: " ++ name;
					v.string = name;

					if (num < 0) {
						num = node.objects.indices.select({arg val; val < 100}).last ? num;
						num = num + 1;
					};

					node[num] = \mix -> { input.ar; };
					//node[num].set(('mix' ++ num).asSymbol, 1);
					NotificationCenter.notify(mainView, \status, msg);
				})
				.fixedHeight_(20)
				.minWidth_(100); // width gets jacked up

				row.layout.add(dragSink);

				row.layout.add(Slider()
					.fixedHeight_(20)
					.minWidth_(35)
					.orientation_(\horizontal)
					.action_({arg ctrl;
						var val = ctrl.value;
						var msg = "";
						if (num >= 0) {
							var key = ('mix' ++ num).asSymbol;
							node.set(key, val);

							msg = "mix % %".format(name, val);
							NotificationCenter.notify(mainView, \status, msg);
						}
					}).valueAction_(1)
				);

				row.layout.add(Button().string_("+").action_({
					addRow.();
				}).fixedSize_(20));

				row.layout.add(Button().string_("-").action_({

					row.remove();
					if (num >= 0) {

						var msg = "remove %".format(name);
						node[num] = nil;
						NotificationCenter.notify(mainView, \status, msg);
					};

					if (view.children.size == 0) {
						addRow.();
					};

					{
						var sizeHint = view.sizeHint;
						view.resizeTo(sizeHint.width, sizeHint.height)
					}.defer(0.001)

				}).fixedSize_(20));
				view.layout.add(row);
			};
			addRow.();
			view;
		}

	);//[\playView].( \bobo, (), View()).front;

}.();



