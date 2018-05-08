{
	var getProxyList = {arg envir, node, specKey;

		var result = List.new;
		var list = envir.sortedKeysValuesDo({arg k,v;

			if (v.class == NodeProxy) {

				var rate = node.controlNames
				.select({arg cn; cn.name == specKey})
				.collect({arg cn; cn.rate})[0];

				if (v.rate == rate || rate.isNil){
					result.add(k);
					if (v.numChannels > 1) {
						v.numChannels.do({arg i;
							result.add(k ++ ":" ++ i);
						});
					};
				}
			}
		});
		result;
	};

	(
		getProxyList: getProxyList,
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
				var spec = if (v == \buf) {\buf} {v.asSpec};

				if (mappers[k].isNil) {
					mappers[k] = NodeProxy();
				};

				if (spec == \buf) {
					mappers[k][0] = { \val.kr; };
					mappers[k].set(\val, 0);
					node.set(k, mappers[k]);
				} {
					mappers[k][0] = { \val.kr.range(\min.kr(spec.minval), \max.kr(spec.maxval)); };
					mappers[k].set(\val, spec.default.linlin(spec.minval, spec.maxval, -1, 1));
					node.set(k, mappers[k]);
				};

				layout.add(

					if (spec == \buf) {

					} {
						PopUpMenu()
						.maxHeight_(height * 0.8)
						.allowsReselection_(true)
						.mouseDownAction_({arg ctrl;

							var result = getProxyList.(envir, node, specKey);
							/*
							envir.sortedKeysValuesDo({arg k,v;

							if (v.class == NodeProxy) {

							var rate = node.controlNames
							.select({arg cn; cn.name == specKey})
							.collect({arg cn; cn.rate})[0];

							if (v.rate == rate || rate.isNil){
							result.add(k);
							if (v.numChannels > 1) {
							v.numChannels.do({arg i;
							result.add(k ++ ":" ++ i);
							});
							};
							}
							}
							});
							*/
							ctrl.items_([""] ++ result);
						})
						.font_(Font().size_(8))
						.action_({arg ctrl;

							var val = ctrl.item.asString;
							var split = val.split($:);
							var name = split[0];

							if (name.isNil or: (name == "") ) {
								slider.enabled_(true);
								rs.enabled_(false);
								mappers[k].set(val, spec.map(slider.value).linlin(spec.minval, spec.maxval,-1,1));
							} {
								var lfo, name;
								val = val.asSymbol;
								lfo = envir[val];
								if (lfo.isNil.not) {
									slider.enabled_(false);
									rs.enabled_(true);
									mappers[k].set(\val, lfo);
								} {
									var msg = "node % doesn't exist in environment".format(val);
									NotificationCenter.notify(containerView, \status, msg);
								}
							};
						});
					}
				);

				///////////////////////////////////
				layout.add(
					rs.action_({arg ctrl;
						var min = spec.map(ctrl.lo);
						var max = spec.map(ctrl.hi);
						mappers[k].set(\min, min, \max, max);
					})
				);

				/*
				layout.add(

				stack.add(
				TextField()
				//.fixedSize_(60@height)
				.minWidth_(60)
				.maxHeight_(height)
				.font_(font)
				.action_({arg ctrl;

				var val = ctrl.value;
				if (val.size > 0) {

				var lfo, name;
				val = val.asSymbol;
				lfo = envir[val];
				if (lfo.isNil.not) {
				slider.enabled_(false);
				nb.enabled_(false);
				node.set(k,lfo);
				} {
				status.string_("node % doesn't exist in environment".format(val));
				}
				} {
				slider.enabled_(true);
				nb.enabled_(true);
				node.unmap(k)
				}
				})
				.mouseUpAction_({arg view,x,y,mod;

				// alt 524288
				if (mod == 524288) {
				stack.index = 1;
				} {
				status.string_("alt + click to set range");
				}
				});
				);

				stack.add(
				RangeSlider()
				//.fixedSize_(60@height)
				.minWidth_(60)
				.maxHeight_(height)
				.background_(Color.white.alpha_(0))
				.orientation_(\horizontal)
				.mouseUpAction_({arg view,x,y,mod;

				// alt 524288
				if (mod == 524288) {
				stack.index = 0;
				} {
				status.string_(view.lo.trunc(0.001).asString ++ " : " + view.hi.trunc(0.001).asString);
				}
				})
				.action_({arg ctrl;
				var spec = v.asSpec;
				var lo = spec.map(ctrl.lo);
				var hi = spec.map(ctrl.hi);
				var key_lo = (k ++ '_min').asSymbol;
				var key_hi = (k ++ '_max').asSymbol;
				node.set(key_lo, lo, key_hi, hi);
				status.string_(lo.asString ++ " : " + hi.asString);
				})
				.lo_(v.asSpec.unmap(v.asSpec.minval))
				.hi_(v.asSpec.unmap(v.asSpec.maxval))
				);
				);
				*/

				//NotificationCenter.register(containerView, k, slider, {arg val;
				//	slider.valueAction_(val.linlin(-1,1,0,1));
				//});

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

				/*
				layout.add(
				nb.fixedSize_(40@height).font_(font).action_({arg ctrl;
				slider.valueAction_(v.asSpec.unmap(ctrl.value))
				})
				.value_(v.asSpec.default)
				);
				*/

				view.layout.add(layout);

			});

			view;
		},

		presetsView: {arg node, config, mainView;

			var view = View().layout_(HLayout().margins_(2).spacing_(2));
			var presets = Array.fill(20, {nil});
			var buttons = List.new;
			var lastActive = -1;

			20.do({arg i;

				var button = Button().fixedSize_(10@10)
				.states_( [ ["", nil, Color.white ], ["", nil, Color.blue] ] )
				.action_({arg ctrl;

					var val = ctrl.value;
					if (presets[i].isNil) {
						// setting preset for first time
						presets[i] = node.getKeysValues;
						buttons[i].states = [ ["", nil, Color.blue] ];
					} {
						if (lastActive == i) {
							// updating preset
							presets[i] = node.getKeysValues;
						} {
							// changing to new preset
							var myPresets = presets[i];
							myPresets.do({arg kv;
								node.set(kv[0], kv[1]);
								NotificationCenter.notify(mainView, kv[0].asSymbol, kv[1]);
							});
						}
					};

					//presets.postln;
					lastActive = i;
				});

				if (config[\presets].isNil.not) {
					presets[i] = config[\presets][i];
					button.states_( [["", nil, Color.blue]] );
				};

				buttons.add(button);
				view.layout.add(button);
			});

			view;
		},

		playView: {arg name, node, containerView;

			var height = 20;
			var wetKey = ("wet" ++ 100).asSymbol;
			var view = View().layout_(HLayout().margins_(2).spacing_(2));

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

			view.layout.add(
				Button()
				.fixedSize_(30@height)
				.string_("doc")
				.mouseDownAction_({arg ctrl; node.document; })
			);

			view;
		}

	);//[\playView].( \bobo, (), View()).front;

}.();


