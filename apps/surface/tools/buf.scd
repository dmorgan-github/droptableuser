(
// dependant on ~bufs global variable
view: {arg objName, envir, util;

	var minWidth = 300;

	var win = View().layout_(VLayout().spacing_(2).margins_(2)).minWidth_(minWidth);

	var view = View()
	.layout_(VLayout().spacing_(2).margins_(2));

	var bufferView = {

		var sfv = SoundFileView()
		.background_(Color.gray(0.3));

		sfv.timeCursorOn = true;
		sfv.timeCursorColor = Color.blue(alpha:0.5);
		sfv.setSelectionColor(0, Color.blue(alpha:0.5));
		sfv.gridResolution = 0.0;
		sfv;
	};

	var addRow = {

		var row = View().layout_(VLayout().spacing_(2).margins_(2));

		var bufnum = s.nextBufferNumber(1);

		var key = ('buf' ++ bufnum).asSymbol;

		var sfv = bufferView.();

		var durBox = NumberBox()
		.fixedWidth_(35)
		.stringColor_(Color.white)
		.normalColor_(Color.white)
		.action_({arg ctrl;
			var dur = ctrl.value;
			var buf;
			// allocate a buffer
			buf = Buffer.alloc(s, dur * s.sampleRate, 1, bufnum:bufnum);
			~bufs[key] = buf;
			NotificationCenter.notify(win, \status, "alloc: " ++ key);
		});

		var play = Button().states_([
			[">"],
			["||"]
		])
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				~bufs[key].play;
			};
		})
		.fixedWidth_(25)
		.enabled_(false);

		var updatePlot = {arg buf;

			buf.loadToFloatArray(action: {arg array;
				{
					sfv.setData(array);
					sfv.minWidth_(minWidth);
					sfv.minHeight_(200);

					durBox.value_(buf.duration);
				}.defer
			});
		};

		row.layout.add(

			HLayout(

				StaticText()
				.string_(bufnum)
				.maxWidth_(25),

				TextField()
				.value_(key)
				.minWidth_(50)
				.action_({arg ctrl;

					var newKey = ctrl.value;
					var oldKey = key;

					~bufs[newKey.asSymbol] = ~bufs[oldKey.asSymbol];
					~bufs[oldKey.asSymbol] = nil;

					key = newKey.asSymbol;
				}),

				durBox,

				play,

				Button()
				.states_([ ["..."] ])
				.action_({arg ctrl;
					Dialog.openPanel({ arg path;
						Buffer.read(s, path, action:{arg buf;
							~bufs[key] = buf;
							updatePlot.(buf);
							{
								play.enabled = true;
								durBox.enabled = false;
							}.defer(0.01);
						}, bufnum: bufnum);
					},{
						"cancelled".postln;
					});
				}).maxWidth_(25),

				Button().string_("zero").action_({
					~bufs[key].zero;
					NotificationCenter.notify(win, \status, "zero: " ++ key);
				}).fixedWidth_(25),

				DragSource()
				.background_(Color.clear)
				.object_((node:NodeProxy.control.source_({DC.kr(bufnum)}),name:key, bufnum:bufnum))
				.string_("-->")
				.fixedWidth_(25),

				Button()
				.maxWidth_(15)
				.states_([ ["+"]])
				.action_({arg ctrl;
					addRow.();
				}),

				Button()
				.maxWidth_(15)
				.states_([ ["-"] ])
				.action_({arg ctrl;

					sfv.remove();
					row.remove();
					~bufs[key] = nil;

					{
						var sizeHint = view.sizeHint;
						view.resizeTo(minWidth, sizeHint.height);
						if (view.children.size == 0) {
							addRow.();
						}
					}.defer(0.01);
				})

			).spacing_(2).margins_(2),
		);

		row.layout.add(sfv);
		row.layout.add(nil);
		view.layout.add(row);
	};

	addRow.();

	win.layout.add(view);

	win.onClose_({
		"destroy: ".debug(objName);
	});
}
)

