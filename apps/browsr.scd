(
~scdBrowser = ();
~scdBrowser.browse = {arg path;

	var folder = PathName.new(path);
	if (folder.isFolder, {

		var folders = folder.folders;
		var files = folder.files;
		[folders, files];
	}, {
		[];
	});
};

~scdBrowser.playBuf = {arg path;

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

~scdBrowser.synthDefNames = {arg str, results = List.new;

	var token = "SynthDef(\\";
	var found = str.find(token);

	if (found.isNil.not) {

		var start = found + token.size;
		var end = str.find(",", offset:start) -1;
		var name = str[start..end];
		results.add(name);
		str = str[end..str.size];
		~scdBrowser.[\synthDefNames].(str, results);
	};

	results;
};

~scdBrowser.openOrFocusDocument = {arg path;

	var matches = Document.openDocuments
	.select({arg doc; doc.path == path });

	if (matches.size > 0) {
		var doc = matches[0];
		doc.front;
	} {
		Document.open(path);
	}
};

~scdBrowser.launchKeyboard = {arg synth;

	var paddingX = 5;
	var paddingY = 5;
	var height = 100;
	var width = 150;
	var top = Window.screenBounds.height - height;
	var left = Window.screenBounds.width - width;
	var fontFamily = "Courier New";
	var fontSize = 10;

	var win = Window("keyboard", Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
	var view = win.view;
	var st, ampCtrl, scaleCtrl, octaveCtrl;
	var amp = 0.1, scale = Scale.major, octave = 3;
	var nodeId = nil;

	var playNote = {arg args, label, amp, scale, octave;

		var char = args[1].asSymbol;
		var degrees = scale.degrees;
		var degree;

		var keymap = ('z': 0, 'x': 1, 'c': 2, 'v': 3, 'b': 4, 'n': 5, 'm': 6,
			'a': 7, 's': 8, 'd': 9,'f': 10,'g': 11, 'h': 12, 'j': 13, 'k': 14, 'l': 15,
			'q': 16,'w': 17,'e': 18,'r': 19, 't': 20, 'y': 21, 'u': 22, 'i': 23, 'o': 24, 'p': 25);

		var name, freq, root;
		var index = keymap[char];
		var server = Server.default.asSymbol;

		root = octave * 12;
		name = (root + index.degreeToKey(scale)).midiname;

		label.string_(char ++ " " ++ name ++ " " ++ name.namecps);

		if (index.isNil.not) {

			if (synth.asString.endsWith("mono")){

				var node = NodeWatcher.all[server].nodes[nodeId];
				if (node.isNil) {
					node = (instrument: synth, type:\on, latency:0.08).play;
					nodeId = node.nodeID;
					NodeWatcher.register(node);
				};

				(type: \set, id: nodeId, args: [\freq, \amp, \trig],
					degree: index, octave: octave, scale: scale, amp: amp, trig:1, latency: 0.08).play;
			} {
				(\instrument: synth, degree: index, octave: octave, scale: scale, amp: amp, latency: 0.08).play;
			};
		};
	};

	view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
	win.background_(Color.black);
	win.alpha = 0.8;
	win.front;
	win.alwaysOnTop_(true);

	StaticText.new(view, 150@15 )
	.stringColor_(Color.white)
	.font_(Font(fontFamily, fontSize))
	.string_(synth);

	st = StaticText.new(view, 150@15 )
	.canFocus_(true)
	.stringColor_(Color.white)
	.font_(Font(fontFamily, fontSize));

	//.keyDownAction_({true;});

	scaleCtrl = PopUpMenu(view, 150@(fontSize*1.5))
	.items_(["..."] ++ Scale.names)
	.font_(Font(fontFamily, fontSize))
	.background_(Color.grey)
	.action_({arg ctrl;
		var val = ctrl.item.asSymbol;
		scale = Scale.at(val);
	});

	octaveCtrl = PopUpMenu(view, 150@(fontSize*1.5))
	.items_(["...", 0, 1, 2, 3, 4, 5, 6, 7])
	.font_(Font(fontFamily, fontSize))
	.background_(Color.grey)
	.action_({arg ctrl;
		octave = ctrl.item;
	})
	.value_(4);

	ampCtrl = NumberBox.new(view, 50@15)
	//.canFocus_(false)
	//.mouseDownAction_({|view| view.focus })
	//.mouseLeaveAction_({ w.view.focus })
	//.keyDownAction_({|view, char, mod, uni| if(uni == 13, { w.view.focus }) })
	.value_(amp)
	.action_({arg ctrl;
		amp = ctrl.value;
	});

	view.keyDownAction = { arg ...args;
		playNote.(args, st, amp, scale, octave);
		true;
	};
};

~scdBrowser.granulize = {arg path;

	var win, soundFile, soundFileView, subwin, centerPosSlider, centerPosInSeconds, triggerSlider;
	var transpSlider, transpToRate, durSlider, panSlider, ampSlider, reverseSlider, buffer, synth, startButton, openButton, selectionSpec;


	// FUNCTIONS

	// Convert transpSlider values (in semitones)
	// to rate values for TGrains (1 = no transp):
	transpToRate = {arg transp; transp.linexp(-24, 24, 0.25, 4)};

	// Convert from centerPosSlider values (0-1)
	// to actual sound file position in seconds:
	centerPosInSeconds = {
		[
			centerPosSlider.lo.linlin(0, 1, 0, soundFile.duration),
			centerPosSlider.hi.linlin(0, 1, 0, soundFile.duration)
		] // returns an array [lo, hi]
	};

	//Window.closeAll;
	//Buffer.freeAll;

	// Main window
	win = Window.new("Granular Sampling", Rect(50, 50, 600, 580), false).front;
	win.background = Color.grey(0.1, 0.9);
	//win.onClose = {s.freeAll};

	// Sound File View
	soundFileView = SoundFileView.new(win, Rect(30, 20, 540, 200))
	// .soundfile_(soundFile)
	// .read(0, soundFile.numFrames)
	.gridColor_(Color.gray(0.3));

	// What to do when user selects portion of sound file directly
	// (i.e., on waveform, not using slider)
	soundFileView.mouseUpAction = {arg view;
		var loFrames, hiFrames, loSlider, hiSlider;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		loSlider = selectionSpec.unmap(loFrames);
		hiSlider = selectionSpec.unmap(hiFrames);
		2.do{centerPosSlider.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
	};

	{
		soundFile = SoundFile.new;
		soundFile.openRead(path);

		buffer = Buffer.readChannel(s, path, channels: [0]);
		// Display sound on View
		soundFileView.soundfile_(soundFile);
		soundFileView.read(0, soundFile.numFrames);
		// ControlSpec (slider 0-1 <=> numFrames)
		selectionSpec = ControlSpec(0, soundFile.numFrames);
		// selectionSpec.postln;
		// Set initial selection on View
		soundFileView.setSelection(0, selectionSpec.map([0.1, 0.2]));
		// Update slider
		soundFileView.mouseUpAction.value(soundFileView);
	}.defer(1);

	// Open Button
	openButton = Button.new(win, Rect(460, 20, 110, 30))
	.states_([["open new file", Color.black, Color.gray]])
	.action_({

		"HELLO".postln;
		// Stop whatever is playing
		//s.freeAll;

		startButton.value = 0;

		Dialog.openPanel(
			okFunc: { |path|
				soundFile = SoundFile.new;
				soundFile.openRead(path);
				// Load sound into buffer
				buffer = Buffer.readChannel(s, path, channels: [0]);
				// Display sound on View
				soundFileView.soundfile_(soundFile);
				soundFileView.read(0, soundFile.numFrames);
				// ControlSpec (slider 0-1 <=> numFrames)
				selectionSpec = ControlSpec(0, soundFile.numFrames);
				// selectionSpec.postln;
				// Set initial selection on View
				soundFileView.setSelection(0, selectionSpec.map([0.1, 0.2]));
				// Update slider
				soundFileView.mouseUpAction.value(soundFileView);
			},
			cancelFunc: {"cancelled"}
		);
	});

	// Sub view to group all sliders
	subwin = CompositeView.new(win, Rect(20, 225, 560, 360))
	// .background_(Color.red(0.4))
	;
	subwin.decorator = FlowLayout(subwin.bounds, margin: 0@0, gap: 5@10);

	centerPosSlider = RangeSlider(subwin, 560@50)
	.lo_(0.1)
	.hi_(0.3)
	.action_({ |v|
		var lo, hi, size;
		lo = selectionSpec.map(v.lo);
		hi = selectionSpec.map(v.hi);
		size = hi - lo;
		soundFileView.setSelection(0, [lo, size]);
		if(startButton.value==1, {synth.set(
			\centerPosLo, centerPosInSeconds.value[0],
			\centerPosHi, centerPosInSeconds.value[1])});
		// ["uau", v.lo, v.hi, lo, hi].postln;
	});

	triggerSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Trigger  ",
		controlSpec: ControlSpec(
			minval:	0.5,
			maxval: 50,
			warp: 'exp',
			step: 0.1,
			units: " t/s"),
		action: {|v|
			if(startButton.value==1, {synth.set(\triggerLo, v.lo, \triggerHi, v.hi)})},
		initVal: [1, 2],
		labelWidth: 60,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	transpSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Transp  ",
		controlSpec: ControlSpec(
			minval:	-24, // two octaves below
			maxval: 24, // two octaves above
			warp: 'lin',
			step: 1, // step by semitones
			units: " ST"),
		action: {|v|
			if(startButton.value==1, {
				synth.set(
					\rateLo, transpToRate.value(v.lo),
					\rateHi, transpToRate.value(v.hi))})},
		initVal: [0, 0],
		labelWidth: 60,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	durSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "grainDur  ",
		controlSpec: ControlSpec(
			minval:	0.1,
			maxval: 2,
			warp: 'lin',
			step: 0.1,
			units: "sec"),
		action: {|v|
			if(startButton.value==1, {synth.set(\durLo, v.lo, \durHi, v.hi)})},
		initVal: [0, 0],
		labelWidth: 70,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	panSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Pan     ",
		controlSpec: ControlSpec(
			minval:	-1,
			maxval: 1,
			warp: 'lin',
			step: 0.1,
			units: "L/R"),
		action: {|v|
			if(startButton.value==1, {synth.set(\panLo, v.lo, \panHi, v.hi)})},
		initVal: [0, 0],
		labelWidth: 60,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	ampSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "grainAmp ",
		controlSpec: ControlSpec(
			minval:	0.0,
			maxval: 1,
			warp: 'lin',
			step: 0.01,
			units: "amp"),
		action: {|v|
			if(startButton.value==1, {synth.set(\ampLo, v.lo, \ampHi, v.hi)})},
		initVal: [0.2, 0.4],
		labelWidth: 73,
		unitWidth: 35)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	reverseSlider = EZSlider(
		parent: subwin,
		bounds: 560@30,
		label: "Reverse  ",
		controlSpec: ControlSpec(
			minval:	0,
			maxval: 100,
			warp: 'lin',
			step: 1,
			units: "%"),
		action: {|v|
			if(startButton.value==1, {synth.set(\reverseProb, v.value/100)});
		},
		initVal: 0.0,
		labelWidth: 63,
		unitWidth: 35)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	startButton = Button.new(subwin, 560@40)
	.states_([["START"], ["STOP", Color.black, Color.gray]])
	.action_({arg button;
		if(button.value==1,
			{
				synth = Synth("granular-sampling", [
					\triggerLo, triggerSlider.lo,
					\triggerHi, triggerSlider.hi,
					\rateLo, transpToRate.value(transpSlider.lo),
					\rateHi, transpToRate.value(transpSlider.hi),
					\centerPosLo, centerPosInSeconds.value[0],
					\centerPosHi, centerPosInSeconds.value[1],
					\durLo, durSlider.lo,
					\durHi, durSlider.hi,
					\panLo, panSlider.lo,
					\panHi, panSlider.hi,
					\ampLo, ampSlider.lo,
					\ampHi, ampSlider.hi,
					\reverseProb, reverseSlider.value,
					\bufnum, buffer.bufnum]);
			},
			{synth.free});
	});
};

~scdBrowser.loop = {arg path;

	var buf;
	var bus;
	var button;
	var numberBox;
	var slider;
	var coord, height;
	var navView, sfv;
	var synth, player;

	var win = Window("Play",
		bounds: Rect(0, Window.screenBounds.height-180, Window.screenBounds.width-800, Window.screenBounds.height-600)
	).front;

	win.view.decorator = FlowLayout( win.view.bounds, 5@5, 5@5);

	bus = Bus.control(s, 1);

	/*
	button = Button(win, Rect(20, 20, 50, 30))
	.states_([
		["Load", Color.white, Color.black]
	])
	.action_({
		s.waitForBoot{
			if(player!=nil, {player.free; player=nil});
			buf = Buffer.loadDialog(s,
				action:{
					buf.loadToFloatArray(
						action: {arg a;
							{ navView.waveColors_(Color.green(1, 0.3)!buf.numChannels);
								sfv.waveColors_(Color.green(1, 0.5)!buf.numChannels);
								navView.setData(a, channels: buf.numChannels);
								sfv.setData(a, channels: buf.numChannels);
								navView.setSelection(0, [0,buf.numFrames]);
								navView.zoomAllOut;
								sfv.setSelection(0, [0,0])
					}.defer })
				}
			);
			"is loading a sound file";}
	}
	);
	*/

	numberBox = NumberBox(win, Rect(80, 20, 50, 30));
	numberBox.value = 1;
	numberBox.scroll_step = 0.01;
	numberBox.action = {arg numb; player.set(\freq,numb.value); };

	slider = Slider.new(win, Rect(40, 10, 300, 30));
	slider.value = 1;
	slider.action = {arg numb;
		player.set(\vol, numb.value);
	};

	coord = [10, 10, 30, 30];
	height = 100;

	navView = SoundFileView(win, Rect(coord[0], coord[1], win.bounds.width-coord[2], height));
	navView.timeCursorOn_(true);
	navView.resize_(2);

	navView.setSelectionColor(0, Color.gray(0.8, 0.2));
	navView.gridOn_(true);
	navView.gridResolution_(60);
	navView.mouseUpAction = {arg view, char, modifiers, unicode, keycode, key;
		var posData, posLo, posHi;
		posData = [navView.selections[0][0], (navView.selections[0][0] + navView.selections[0][1])] / navView.numFrames;
		posData;
		sfv.zoomToFrac(posData[1] - posData[0]);
		sfv.scrollTo (posData[0]);
		sfv.scroll (posData[0]);
	};

	sfv = SoundFileView(win, Rect(coord[0], coord[2], win.bounds.width-coord[2], win.bounds.height-(coord[3]*2)-height));
	sfv.timeCursorOn_(true).setSelectionColor(0, Color.gray(0.8, 0.5));
	sfv.gridOn_(true);
	sfv.resize_(5);
	sfv.gridResolution_(10);

	synth = {arg lo = 0, hi = 1, freq=1, vol=1;
		var phasor = Phasor.ar(0, BufRateScale.kr(buf)*freq, lo * BufFrames.kr(buf), hi *BufFrames.kr(buf));
		Out.kr(bus.index,A2K.kr(phasor));
		BufRd.ar(buf.numChannels, buf, phasor)*vol
	};

	sfv.mouseUpAction = {arg view, char, modifiers, unicode, keycode, key;

		var posData, posLo, posHi;
		posData = [sfv.selections[0][0], (sfv.selections[0][0] + sfv.selections[0][1])] / sfv.numFrames;
		posData;
		sfv.selections[0][0];
		sfv.selections[0][1];
		if (player==nil, {
			player = synth.play(outbus: ~buster, args: [\lo, posData[0], \hi, posData[1]])
		}, {
			player.set(\lo, posData[0], \hi, posData[1]);
		});
	};

	win.onClose_({player.free; buf=nil; navView=nil; numberBox=nil; player=nil; sfv=nil; win=nil; AppClock.clear});

	(
		AppClock.sched(0.0, {
			bus.get({arg val;
				{
					sfv.timeCursorPosition = val;
					navView.timeCursorPosition = val
				}.defer;
			});
			0.05;
		});
	);

	buf = Buffer.read(s, path, action: {arg a;

		a.loadToFloatArray(action: {arg ary;

			{
				navView.waveColors_(Color.green(1, 0.3)!buf.numChannels);
				sfv.waveColors_(Color.green(1, 0.5)!buf.numChannels);
				navView.setData(ary, channels: buf.numChannels);
				sfv.setData(ary, channels: buf.numChannels);
				navView.setSelection(0, [0,buf.numFrames]);
				navView.zoomAllOut;
				sfv.setSelection(0, [0,0])
			}.defer;
		});
	});
};

~scdBrowser.show = {arg path;

	var paddingX = 5;
	var paddingY = 5;
	var height = 500;
	var width = 275;
	var fontFamily = "Courier New";
	var fontSize = 10;
	var top = Window.screenBounds.height - height;
	var left = 0;

	var win = Window("Browser", Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
	var view = win.view;
	var letterWidth = fontSize * 0.6;
	var browseView, tabbedView, browseTab, monitorTab, monitorView, searchTab, searchView;
	var drawSearch, drawBrowse, drawMonitor;

	view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
	win.background_(Color.black);
	win.alpha = 0.8;
	win.front;

	tabbedView = TabbedView2.new(win, width@height);

	browseTab = tabbedView.add("browse",scroll:false);
	browseTab.labelColor = Color.grey;
	browseTab.background = Color.black.alpha_(0.8);
	browseTab.stringColor = Color.white;
	browseTab.stringFocusedColor = Color.white;
	browseTab.unfocusedColor = Color.black;

	monitorTab = tabbedView.add("monitor",scroll:false);
	monitorTab.labelColor = Color.grey;
	monitorTab.background = Color.black.alpha_(0.8);
	monitorTab.stringColor = Color.white;
	monitorTab.stringFocusedColor = Color.white;
	monitorTab.unfocusedColor = Color.black;

	searchTab = tabbedView.add("search",scroll:false);
	searchTab.labelColor = Color.grey;
	searchTab.background = Color.black.alpha_(0.8);
	searchTab.stringColor = Color.white;
	searchTab.stringFocusedColor = Color.white;
	searchTab.unfocusedColor = Color.black;

	browseView = ScrollView(browseTab, width@(height-30))
	.background_(Color.black)
	.alpha_(0.8)
	.autohidesScrollers_( true )
	.hasVerticalScroller_( true )
	.hasHorizontalScroller_( true );
	browseView.decorator_(FlowLayout(browseView.bounds));

	monitorView = ScrollView(monitorTab, width@(height-30))
	.autohidesScrollers_( true )
	.hasVerticalScroller_( true )
	.hasHorizontalScroller_( true );
	monitorView.decorator_(FlowLayout(monitorView.bounds));

	searchView = ScrollView(searchTab, width@(height-30))
	.background_(Color.black)
	.alpha_(0.8)
	.autohidesScrollers_( true )
	.hasVerticalScroller_( true )
	.hasHorizontalScroller_( true );
	searchView.decorator_(FlowLayout(searchView.bounds));

	drawSearch = {arg view;

		var resultsView;
		var tf = TextField.new(view, 225@25);

		Button.new(view, 25@25)
		.string_("go")
		.action_({

			var stdOut, paths, results, len, msg;
			var val = tf.value;
			var rootDir = "/Users/david/projects/droptableuser";
			var str = "grep -rilI \"" ++ val ++ "\" " ++ rootDir;

			stdOut = str.unixCmdGetStdOut;
			paths = stdOut.split($
			);

			resultsView.removeAll;
			resultsView.decorator.reset;

			results = paths.select({arg path;
				(path.endsWith(".sc") or: path.endsWith(".scd") or: path.endsWith(".txt"));
			});

			msg = results.size.asString ++ " results";
			len = msg.size * letterWidth;
			StaticText.new(resultsView, len@fontSize)
			.string_(msg)
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize));
			resultsView.decorator.nextLine;

			results.do({arg path;

				var relativePath = path.replace(rootDir,"");
				var len = relativePath.size * letterWidth;
				StaticText.new(resultsView, len@fontSize )
				.string_(relativePath)
				.stringColor_(Color.white)
				.font_(Font(fontFamily, fontSize))
				.mouseDownAction_({

					~scdBrowser[\openOrFocusDocument].(path);
				});

				resultsView.decorator.nextLine;
			});

		});

		resultsView = ScrollView(searchView, searchView.bounds)
		.background_(Color.black)
		.alpha_(0.8)
		.autohidesScrollers_( true )
		.hasVerticalScroller_( true )
		.hasHorizontalScroller_( true );
		resultsView.decorator_(FlowLayout(resultsView.bounds));

	};

	drawMonitor = {arg view;

		var meterView, numIns, numOuts;
		numIns = numIns ?? { s.options.numInputBusChannels };
		numOuts = numOuts ?? { s.options.numOutputBusChannels };
		meterView = ServerMeterView(s, view, 0@0, numIns, numOuts);
	};

	drawBrowse = {arg path, view;

		var pathName = PathName.new(path);
		var info = ~scdBrowser[\browse].(path);
		var folders = info[0];
		var files = info[1];
		var textWidth = width * 0.9;
		var name = "[" ++ pathName.folderName ++ "] " ++ path;
		var len = name.size * letterWidth;

		view.removeAll;
		view.decorator.reset;

		StaticText.new(view, len@fontSize )
		.string_(name)
		.stringColor_(Color.white)
		.font_(Font(fontFamily, fontSize));
		view.decorator.nextLine;

		StaticText.new(view, letterWidth@fontSize )
		.string_("^")
		.stringColor_(Color.white)
		.font_(Font(fontFamily, fontSize))
		.mouseDownAction_({
			drawBrowse.(pathName.parentPath, view);
		});
		view.decorator.nextLine;

		folders.do({arg path;

			StaticText.new(view, textWidth@fontSize )
			.string_("> " ++ path.folderName)
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize))
			.mouseDownAction_({
				drawBrowse.(path.fullPath, view);
			});
			view.decorator.nextLine;
		});

		files.do({arg path;

			StaticText.new(view, letterWidth@fontSize )
			.string_("+ ")
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize))
			.mouseDownAction_({

				if ("aiff,wav".contains(path.extension)) {
					("echo \"" ++ path.fullPath ++ "\" | pbcopy").unixCmd;
				}
			});

			StaticText.new(view, 125@fontSize )
			.string_(path.fileName)
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize))
			.mouseDownAction_({

				if ("aiff,wav".contains(path.extension.toLower)) {
					~scdBrowser[\playBuf].(path.fullPath);
				} {
					~scdBrowser[\openOrFocusDocument].(path.fullPath);
				};
			});

			if ("aiff,wav".contains(path.extension.toLower)) {

				PopUpMenu(view, 125@(fontSize*1.5))
				.items_(["...", "granular", "loop"])
				.font_(Font(fontFamily, fontSize))
				.background_(Color.grey)
				.action_({arg item;

					case
					{item.value == 1} {
						~scdBrowser[\granulize].(path.fullPath);
					}
					{item.value == 2} {
						~scdBrowser[\loop].(path.fullPath);
					};
				});
			};

			view.decorator.nextLine;

			// TODO: put in proper named function
			{arg view;

				var content = File.open(path.fullPath, "r").readAllString;
				var results = ~scdBrowser[\synthDefNames].(content);

				results.do({arg name;

					StaticText.new(view, Rect(left: 300, top:0, width:100, height:fontSize) )
					.string_("  " ++ name)
					.stringColor_(Color.green)
					.font_(Font(fontFamily, fontSize))
					.mouseDownAction_({arg view, x, y, mod, num;
						var synthDesc = SynthDescLib.at(name.asSymbol);
						if (synthDesc.isNil.not) {
							//SynthDescLib.at(name.asSymbol).makeGui
							SynthDescLib.global[name.asSymbol].makeWindow;
						};
					});

					PopUpMenu(view, 125@(fontSize*1.5))
					.items_(["...", "gui", "keyboard"])
					.font_(Font(fontFamily, fontSize))
					.background_(Color.grey)
					.action_({arg item;
						case
						{item.value == 1} {

							var synthDesc = SynthDescLib.at(name.asSymbol);
							if (synthDesc.isNil.not) {
								// TODO: I believe makeGui is from an extension
								SynthDescLib.at(name.asSymbol).makeGui
							};
						}
						{item.value == 2} {
							~scdBrowser[\launchKeyboard].(name.asSymbol);
						}

					});
					view.decorator.nextLine;
				});

			}.(view);

		});
	};

	drawBrowse.(path, browseView);
	drawMonitor.(monitorView);
	drawSearch.(searchView);
};

~scd = {
	var path = "/Users/david/projects/droptableuser/";
	~scdBrowser[\show].(path);
};

SynthDef("granular-sampling", {arg triggerLo, triggerHi, rateLo, rateHi, centerPosLo, centerPosHi,
	durLo, durHi, panLo, panHi, ampLo, ampHi, reverseProb, bufnum;

		var trig, trigFreqMess, rate, centerPos, dur, pan, amp, coin, reverse, snd;
		// var bufdur = BufDur.kr(buffer);

		trigFreqMess = LFNoise2.kr(12).range(0.5, 1);
		trig = Impulse.kr(LFNoise0.kr(trigFreqMess).range(triggerLo, triggerHi));

		rate = Dwhite(rateLo, rateHi);
		centerPos = Dwhite(centerPosLo, centerPosHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);
		coin = CoinGate.kr(reverseProb, trig);
		reverse = Select.kr(coin, [1, -1]);
		// reverse.poll(trig);

		Demand.kr(trig, 0, [rate, centerPos, dur, pan, amp]);

		snd = TGrains.ar(
			numChannels: 2,
			trigger: trig,
			bufnum: bufnum,
			rate: rate * reverse,
			centerPos: centerPos,
			dur: dur,
			pan: pan,
			amp: amp);

		Out.ar(0, snd);

	}).add;

)

~scd.();

///////////////////////////////////////////
convert stero to mono

(
b.loadToFloatArray(action: { arg array;
	a = array;
	{d = Buffer.loadCollection(s, a.unlace(2).sum*0.5);
	d.plot;
	}.defer; "done".postln;});
)

(
SynthDef("mix-buffer", { arg stereoBuf, monoBuf, amp = 1;
        var sig;

        sig = PlayBuf.ar( 2, stereoBuf, loop: 0, doneAction: 2 );
        RecordBuf.ar( sig.sum * amp, monoBuf, loop: 0 );

}).send(s);
)

~stereobuffer = Buffer.read( s, "sounds/SinedPink.aiff" );

~monobuffer = Buffer.alloc(s,  ~stereobuffer.numFrames, 1 );

Synth( "mix-buffer", [\stereoBuf, ~stereobuffer, \monoBuf,
~monobuffer ] );

~monobuffer.plot;


//////////////////////

(
var extractSynthDef = {arg str, results = List.new;

	var token = "SynthDef(\\";
	var found = str.find(token);

	if (found.isNil.not) {

		var start = found + token.size;
		var nameEnd = str.find(",", offset:start) -1;
		var name = str[start..nameEnd];
		var endToken = "}).add";
		var synthEnd = str.find(endToken, offset:found);

		if (synthEnd.isNil.not) {
			var synthDef = str[found..synthEnd + endToken.size];
			results.add(name -> synthDef);
			str = str[synthEnd..str.size];
			extractSynthDef.(str, results);
		}
	};

	results;
};
var func = {arg path;

	var file;
	var csv = "";
	var val = "SynthDef";
	var str = "grep -rilI \"" ++ val ++ "\" " ++ path;

	var stdOut = str.unixCmdGetStdOut;
	var paths = stdOut.split($
	);

	paths.do({arg p;

		var content, results;
		var file;

		if (p.isNil.not and: (p.size > 0) ) {

			file = File.new(p, "r");
			content = file.readAllString;
			file.close;
			results = extractSynthDef.(content);

			results.do({arg assoc;
				csv = csv ++ assoc.key ++ ",\"" ++ assoc.value.replace("\"", "\"\"") ++ "\"," ++ p ++ "\n";
			});
		};
	});

	"here".postln;

	file = File("~/projects/droptableuser/synths2.csv".standardizePath, "w");
	file.write(csv);
	file.close;
};

var path = "/Users/david/projects/sonic-pi";
func.(path);

//var path = "/Users/david/projects/droptableuser/workspaces/workspace9/main.scd";
//var content = File.new(path, "r").readAllString;
//var results = extractSynthDef.(content);
//results.postln;


)


So, here is an example event to work out the closest MIDI key to the specified frequency.
(freq: 230, finish: { ~freq.value.cpsmidi.round(1).postln }).play;

(

var str = "
SynthDef(\\bobo, {
var osc1 = {
var sig = SinOsc.ar;
sig
};

var sig = osc1.();

sig = Splay.ar(sig) * \\amp.kr(0.1);

Out.ar(0, sig);

}).add;

SynthDef(\\bobo2, {}).add;
";

var token = "SynthDef(\\";
var found = str.find(token);
var endtoken = "}).add";
var end = str.find(endtoken, offset:found);

var def = str[found..end + endtoken.size];

def.postln;


str = str[end..str.size];
str.postln
//def.postln;

)

f = File("~/projects/droptableuser/synths.csv".standardizePath,"w");
f.write(csv);
f.close;

"hello \" \"".replace("\"", "\"\"")

a = "dd" -> "abc"

a.value