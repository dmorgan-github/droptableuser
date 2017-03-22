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
	.value_(5);

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
					("echo \"" + path.fullPath + "\" | pbcopy").unixCmd;
				}
			});

			StaticText.new(view, textWidth@fontSize )
			.string_(path.fileName)
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize))
			.mouseDownAction_({

				if ("aiff,wav".contains(path.extension)) {
					~scdBrowser[\playBuf].(path.fullPath);
				} {
					~scdBrowser[\openOrFocusDocument].(path.fullPath);
				};
			});
			view.decorator.nextLine;

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
							SynthDescLib.at(name.asSymbol).makeGui
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
	var path = "/Users/david/projects/droptableuser";
	~scdBrowser[\show].(path);
};

)

~scd.();

g = Group.new(s);
a = (instrument: \instr1_mono, type:\on, latency:0.08).play;
a.nodeID

NodeWatcher.register(g);
g.isPlaying

g = Synth(\instr1_mono)


NodeWatcher.unregister(c);


NodeWatcher.register(a);
NodeWatcher.all[Server.default].nodes[1005]

Server.default

TextField
NumberBox
NumberEditor


a[\isPlaying]
a.isRunning
(id: 1007, type:\set, args:[\freq, \amp, \trig], freq:300, \amp: 0.1, \trig: 1).play;

(
var server = Server.default.asSymbol;
var node = NodeWatcher.all[server].nodes[nil];
node.postln;
)



(
var lastVal;
var win = Window("NumberBox Example", Rect(100, 500, 400, 120));
var nb = NumberBox(win, Rect(150, 10, 100, 20));
var nb2 = NumberBox(win, Rect(150, 50, 100, 20));

nb.canFocus_(false)
        .mouseDownAction_({|view| view.focus })
        .mouseLeaveAction_({ w.view.focus })
        .keyDownAction_({|view, char, mod, uni| if(uni == 13, { w.view.focus }) })
        .action_({|view| view.value.postln });

nb.value = rrand(1,15);
nb.action = {arg numb; numb.value.postln; };
win.front;
)


(
var win = Window.new;

var cv = CompositeView(win, Rect(50, 0, 300, 300));
var st = StaticText.new(cv, Rect(50, 0, 100, 10)).string_("hello");
var nb = NumberBox(cv, Rect(150, 10, 100, 20));
var nb2 = NumberBox(cv, Rect(150, 50, 100, 20));
nb.value = rrand(1,15);
nb.action = {arg numb; numb.value.postln; };
win.front;
)
