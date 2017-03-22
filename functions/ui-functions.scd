(

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