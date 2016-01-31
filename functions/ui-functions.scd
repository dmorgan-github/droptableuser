(

SynthDef.new(\piano, {arg freq = 440, amp = 0.5, out = 0;
	var osc = MdaPiano.ar(freq);
	var env = EnvGen.kr(Env.linen, doneAction:2);
	Out.ar(out, osc * env * amp);
}).add;

~harms = {arg parent, vals, width, height, cb;

	var thumbWidth = width/21.3;
	vals = vals ? (0..19).collect({arg num; (num+1).reciprocal});

	MultiSliderView(parent, width@height)
	.size_(20)
	.value_(vals)
	.drawLines_(false)
	.isFilled_(true)
	.thumbSize_(thumbWidth)
	.action_({arg ctrl;
		cb.value(ctrl.value);
	});
};

~env = {arg parent, width, height, env, min, max, cb;

	var ctrlWidth = 28;
	var envCtrl;
	var cv = CompositeView(parent, (ctrlWidth)@height);
	cv.decorator_(FlowLayout(cv.bounds));

	StaticText(cv, (ctrlWidth-4)@15)
	.stringColor_(Color.white)
	.string_(max);

	cv.decorator.nextLine;
	NumberBox(cv, (ctrlWidth-4)@ctrlWidth)
	.action_({arg ctrl;

		var level = ctrl.value;
		var numPoints = envCtrl.value[0].size;
		var levels = level.linlin(min, max, 0, 1)!numPoints;
		var result = [
			(0..numPoints - 1 ).normalize,
			levels
		];
		envCtrl.valueAction_(result);
	});
	cv.decorator.nextLine;

	StaticText(cv, (ctrlWidth-4)@15)
	.stringColor_(Color.white)
	.string_(min);

	ctrlWidth = width - ctrlWidth;
	envCtrl = EnvelopeView(parent, ctrlWidth@height)
	.drawLines_(true)
	.step_(0.05)
	.setEnv(env)
	.gridOn_(true)
	.action_({arg ctrl;
		var times = ctrl.value[0].differentiate.drop(1);
		var levels = ctrl.value[1].linlin(0, 1, min, max);
		env.times = times;
		env.levels = levels;
		if (cb.notNil, {
			cb.value(env);
		});
	});
};

~keyboard = {arg parent, rootNote, width, height, cb;

	var cv;
	var letterWidth;
	var defaultScaleRatios = [1, 1.1892071150009, 1.3348398541699, 1.4142135623731, 1.4983070768767, 1.781797436280 ];
	var scaleRatios = defaultScaleRatios;
	var fontFamily = "Courier New";
	var fontSize = 12;
	var freqText;

	var cache = Dictionary.new;
	var keyMap = List.new();

	keyMap.add("r" -> 0);
	keyMap.add("e" -> 1);
	keyMap.add("w" -> 2);
	keyMap.add("q" -> 3);
	keyMap.add("a" -> 4);
	keyMap.add("s" -> 5);

	keyMap.add("d" -> 10);
	keyMap.add("f" -> 11);
	keyMap.add("g" -> 12);
	keyMap.add("h" -> 13);
	keyMap.add("j" -> 14);
	keyMap.add("k" -> 15);

	keyMap.add("l" -> 20);
	keyMap.add(";" -> 21);
	keyMap.add("'" -> 22);
	keyMap.add("]" -> 23);
	keyMap.add("[" -> 24);
	keyMap.add("p" -> 25);

	keyMap.add("o" -> 30);

	cv = CompositeView(parent, width@height);
	cv.decorator_(FlowLayout(cv.bounds));

	letterWidth = cv.bounds.width / 23;
	keyMap.do({arg item;
		var st = StaticText.new(cv, letterWidth@30 )
		.string_(item.key)
		.stringColor_(Color.white)
		.font_(Font(fontFamily, fontSize));
		cache.add(item.key -> st );
	});

	parent.view.mouseUpAction = {arg self, obj;
		parent.view.focus;
	};

	parent.view.keyDownAction = {arg self, obj;

		var freq = 0;
		var val = nil;
		var num = 0;
		keyMap.do({arg item, i;
			if (item.key == obj.asString, {
				val = item.value;
				cache.at(item.key).stringColor_(Color.green);
				num = i;
			});
		});

		if (val.isNil.not, {
			var index = val % 10;
			var octave = (val/10).floor;
			var ratio = scaleRatios[index];
			if (ratio.isNil.not, {
				freq = (rootNote * ratio) * (2 ** octave);
			});
		});

		if (freq > 0, {
			cb.value(freq, num);
			freq.postln;
		});
	};

	parent.view.keyUpAction = {arg self, obj;
		var freq = 0;
		var val = nil;
		keyMap.do({arg item;
			if (item.key == obj.asString, {
				val = item.value;
				cache.at(item.key).stringColor_(Color.white);
			});
		});

	};
};

~slider = {arg parent, val, width, height, cb;

	var ctrlWidth = 35;
	var numBoxCtrl;

	var sliderCtrl = Slider.new(parent, (width - ctrlWidth)@height)
	.value_(val)
	.step_(0.01)
	.action_({arg ctrl;
		cb.value(ctrl.value);
		numBoxCtrl.value_(ctrl.value);
	});

	numBoxCtrl = NumberBox(parent, ctrlWidth@height)
	.value_(val)
	.action_({arg ctrl;
		sliderCtrl.valueAction_(ctrl.value);
	});
};

~kb = {arg func;

	//Window.closeAll;
	{
		var paddingX = 5;
		var paddingY = 5;
		var height = 300;
		var width = 500;
		var top = Window.screenBounds.height - height;
		var left = Window.screenBounds.width - width;

		var win = Window("Wave Shaper", Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
		var view = win.view;

		view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
		win.background_(Color.black);
		win.alpha = 0.8;
		win.front;
		win.alwaysOnTop_(true);
		~keyboard.(win, 65.40639132515;, width, 200, func);
	}.value;
};

~hrm = {arg cb, vals;

	//Window.closeAll;
	{
		var paddingX = 5;
		var paddingY = 5;
		var height = 300;
		var width = 500;
		var top = Window.screenBounds.height - height;
		var left = Window.screenBounds.width - width;

		var win = Window("Wave Shaper", Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
		var view = win.view;

		view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
		win.background_(Color.black);
		win.alpha = 0.8;
		win.front;
		win.alwaysOnTop_(true);
		~harms.(win, vals, width, 200, {arg harms;
			cb.value(harms);
		});
	}.value;
};

~tappr = {

	var paddingX = 5;
	var paddingY = 5;
	var height = 300;
	var width = 1000;
	var top = Window.screenBounds.height - height;
	var left = Window.screenBounds.width - width;

	var win = Window("tappr", Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
	var view = win.view;

	view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
	win.background_(Color.black);
	win.alpha = 0.8;
	win.front;
	win.alwaysOnTop_(true);

	{
		var parent = win, width = 1000, height = 800;

		var cv;
		var letterWidth = 10;
		var fontFamily = "Courier New";
		var fontSize = 12;
		var list;
		var map = ();

		cv = CompositeView(parent, width@height);
		cv.decorator_(FlowLayout(cv.bounds));

		~samples.ls();
		list = ~samples.samples_list.asArray;

		"asdfghjkl".do({arg char;

			var letter = char.asString;
			var st = StaticText.new(cv, letterWidth@30 )
			.string_(letter)
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize))
			.mouseUpAction_({arg self;

				var val = map[letter.asSymbol];
				if (val.isNil.not, {
					val.path.postln;
				});
			});

			PopUpMenu.new(cv, 800@30 )
			.items_(list)
			.action_({arg item;
				map[letter.asSymbol] = Buffer.read(Server.default, item.item);
			});

			cv.decorator.nextLine;
		});

		parent.view.mouseUpAction = {arg self, obj;
			parent.view.focus;
		};

		parent.view.keyDownAction = {arg self, obj;

			var freq = 0;
			var val = nil;
			var num = 0;
			val = map[obj.asSymbol];
			if (val.isNil.not, {
				val.play;
			});
		};

		parent.view.keyUpAction = {arg self, obj;
			var freq = 0;
			var val = nil;
		};

	}.value;
};

/**
    Sample browser
*/
~sampleBrowser = ();
~sampleBrowser.browse = {arg path;

	var folder = PathName.new(path);
	if (folder.isFolder, {

		var folders = folder.folders;
		var files = folder.files;
		[folders, files];
	}, {
		[];
	});
};
~sampleBrowser.playBuf = {arg path;

	Buffer.read(server:s, path:path, action:{arg buf;

		var len = (buf.numFrames / 44100) + 1;
		{
			var numChannels = buf.numChannels;
			PlayBuf.ar(numChannels, buf, doneAction:2).dup;
		}.play;

		{
			buf.free;
		}.defer(len);
	});
};
~sampleBrowser.show = {arg path;

	var paddingX = 5;
	var paddingY = 5;
	var height = 250;
	var width = 300;
	var fontFamily = "Courier New";
	var fontSize = 10;
	var top = Window.screenBounds.height - height;
	var left = Window.screenBounds.width - width;

	var win = Window("Browser", Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
	var view = win.view;
	var letterWidth = fontSize * 0.6;
	var cv, draw;

	view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
	win.background_(Color.black);
	win.alpha = 0.8;
	win.front;

	cv = ScrollView(win, width@height)
	.background_(Color.black)
	.alpha_(0.8)
	.autohidesScrollers_( true )
	.hasVerticalScroller_( true )
	.hasHorizontalScroller_( true );

	cv.decorator_(FlowLayout(cv.bounds));

	draw = {arg path, view;

		var pathName = PathName.new(path);
		var info = ~sampleBrowser[\browse].(path);
		var folders = info[0];
		var files = info[1];
		var len = path.size * letterWidth;
		var textWidth = width * 0.9;

		view.removeAll;
		view.decorator.reset;

		StaticText.new(view, len@fontSize )
		.string_(path)
		.stringColor_(Color.white)
		.font_(Font(fontFamily, fontSize));
		view.decorator.nextLine;

		StaticText.new(view, letterWidth@fontSize )
		.string_("^")
		.stringColor_(Color.white)
		.font_(Font(fontFamily, fontSize))
		.mouseDownAction_({
			draw.(pathName.parentPath, view);
		});
		view.decorator.nextLine;

		folders.do({arg path;

			StaticText.new(view, textWidth@fontSize )
			.string_("> " ++ path.folderName)
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize))
			.mouseDownAction_({
				draw.(path.fullPath, view);
			});
			view.decorator.nextLine;
		});

		files.do({arg path;

			StaticText.new(view, letterWidth@fontSize )
			.string_("+ ")
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize))
			.mouseDownAction_({
				path.fullPath.postln;
			});

			StaticText.new(view, textWidth@fontSize )
			.string_(path.fileName)
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize))
			.mouseDownAction_({
				~sampleBrowser[\playBuf].(path.fullPath);
			});
			view.decorator.nextLine;
		});
	};

	draw.(path, cv);
};

~sb = {
	var path = "/Users/david/projects/droptableuser/samples";
	~sampleBrowser[\show].(path);
};

)