(
var rootpath = PathName(Document.current.path).parentPath;//"/Users/david/projects/droptableuser/apps/surface/";
var viewsPath = rootpath ++ "_views/";
var recorders = List.new;

// init
var init = {
	"init".postln;
	Font.setDefault(Font("Courier New", 10));
	~bufs = ~bufs ? ();
	nil;
}.value;

var browse = {arg path;

	var folder = PathName.new(path);
	if (folder.isFolder, {

		var folders = folder.folders;
		var files = folder.files;
		[folders, files];
	}, {
		[];
	});
};

var alwaysOnTop = {arg view;

	Button().states_([ ["--"], ["__"] ]).action_({arg ctrl;
		if (ctrl.value == 1) {
			view.alwaysOnTop = true;
		}{
			view.alwaysOnTop = false;
		}
	}).maxSize_(15);
};

var recordStems = {

	var key = Date.getDate.asSortableString;
	currentEnvironment.keysValuesDo({arg k,v;
		if (v.class == NodeProxy) {
			if (v.rate == \audio) {
				var rec;
				var folder = Platform.recordingsDir ++ "/stems/" ++ key ++ "/";
				if (File.exists(folder).not) {
					File.mkdir(folder)
				};
				rec = v.record(folder ++ k ++ ".aiff");
				recorders.add(rec);
			}
		}
	});

	{
		recorders.do({arg rec;
			rec.unpause;
		});
	}.defer(1);

};

var stopRecordStems = {

	recorders.do({arg rec;
		rec.pause;
		rec.close;
		rec.free;
		rec = nil;
	});

	recorders = List.new;
};

var findView = {arg path;

	var result = "";
	var pathname = PathName(path);
	var name = pathname.fileNameWithoutExtension;
	var search = viewsPath ++ name ++ ".scd";

	if (File.exists(search)) {
		result = search;
	} {

		var findFolder = {arg path, count = 3;

			var folderName = PathName(path).folderName;
			var search = viewsPath ++ folderName ++ ".scd";

			if (File.exists(search)) {
				search;
			} {
				var myPath = PathName(path).pathOnly.trim("/");
				if (count > 0) {
					findFolder.(myPath, count - 1);
				}
			}
		};

		result = findFolder.(path);
	};

	result;
};

var loadView = {arg file;

	var view, count = 1, viewPath;
	var envir = currentEnvironment;
	var objName = PathName(file).fileNameWithoutExtension;
	var util = File.open(rootpath ++ "_funcs.scd", "r").readAllString.interpret;
	var win;
	var status = StaticText().string_("").font_(Font().size_(9));

	envir.keysValuesDo({arg k,v;
		if (v.class == NodeProxy and: k.asString.beginsWith(objName) )  {
			count = count + 1;
		}
	});

	objName = (objName ++ count.asString).asSymbol;
	viewPath = findView.(file);

	if (viewPath.isNil) {
		var viewObj = File.open(file, "r").readAllString.interpret;
		view = viewObj[\view].(objName, envir, util);
	} {
		var viewObj = File.open(viewPath, "r").readAllString.interpret;
		// the data object
		var obj = File.open(file, "r").readAllString.interpret;
		view = viewObj[\view].(objName, envir, obj, util);
	};

	win = View().layout_(VLayout().spacing_(1).margins_(1)).palette_(QPalette.dark).name_(objName);

	NotificationCenter.register(view, \status, win, {arg msg;
		status.string_(msg);
	});

	win.layout.add(
		HLayout(alwaysOnTop.(win),
			nil,
			if (envir[objName] != nil) {
				DragSource()
				.background_(Color.clear)
				.object_((node:envir[objName],name:objName))
				.string_("-->")
				.maxWidth_(30)
				.minWidth_(30)
				.align_(\right)
			}
		)
	);

	win.layout.add(view);
	win.layout.add(status);
	win.front;
};

var show = {arg path;

	var paddingX = 5;
	var paddingY = 5;
	var height = 250;
	var width = 300;
	var fontSize = 10;
	var top = Window.screenBounds.height - height;
	var left = Window.screenBounds.width - width;

	var win = Window("Browser", Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
	var view = win.view.palette_(QPalette.dark);
	var letterWidth = fontSize * 0.6;
	var cv, draw;

	view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
	win.front;

	Button(view, 30@30)
	.states_([ ["--"], ["__"] ]).action_({arg ctrl;
		if (ctrl.value == 1) {
			view.alwaysOnTop = true;
		}{
			view.alwaysOnTop = false;
		}
	}).maxSize_(15);

	Button(view, 30@20)
	.states_([ ["rec"], ["stop", Color.red] ] )
	.action_({arg ctrl; if (ctrl.value == 1) {s.record} {s.stopRecording} });

	Button(view, 50@20)
	.states_([ ["stems"], ["stop", Color.red] ] )
	.action_({arg ctrl;
		if (ctrl.value == 1) {
			recordStems.();
		} {
			stopRecordStems.();
		}
	});

	PopUpMenu(view).items_(ServerOptions.inDevices)
	//.value_(s.options.inDevice ? "Built-in Microph")
	.action_({arg ctrl;
		var device = ctrl.item;
		s.options.inDevice = device;
		s.reboot;
	});
	//.value_(ServerOptions.inDevices.indexOf("Built-in Microph"));

	PopUpMenu(view)
	.items_(ServerOptions.outDevices)
	//.value_(s.options.outDevice ? "Built-in Output")
	.action_({arg ctrl;
		var device = ctrl.item;
		s.options.outDevice = device;
		s.reboot
	});
	//.value_(ServerOptions.outDevices.indexOf(s.options.outDevice ? "Built-in Output"));

	cv = ScrollView(win, width@height)
	.autohidesScrollers_( true )
	.hasVerticalScroller_( true )
	.hasHorizontalScroller_( true );

	cv.decorator_(FlowLayout(cv.bounds));

	draw = {arg path, view;

		var pathName = PathName.new(path);
		var info = browse.(path);
		var folders = info[0];
		var files = info[1];
		var len = path.size * letterWidth;
		var textWidth = width * 0.9;

		view.removeAll;
		view.decorator.reset;

		if (pathName.fullPath != rootpath) {

			StaticText.new(view, letterWidth@fontSize )
			.string_("^")
			.stringColor_(Color.white)
			.mouseDownAction_({
				draw.(pathName.parentPath, view);
			});
			view.decorator.nextLine;
		};

		folders.select({arg p; p.folderName.beginsWith("_").not}).do({arg path;

			StaticText.new(view, textWidth@fontSize )
			.string_("> " ++ path.folderName)
			.stringColor_(Color.white)
			.mouseDownAction_({
				draw.(path.fullPath, view);
			});
			view.decorator.nextLine;
		});

		files.select({arg p; p.fileName.beginsWith("_").not;}).do({arg path;

			StaticText.new(view, letterWidth@fontSize )
			.string_("+ ")
			.stringColor_(Color.white)
			.mouseDownAction_({
				loadView.(path.fullPath);
			});

			StaticText.new(view, textWidth@fontSize )
			.string_(path.fileName)
			.stringColor_(Color.white)
			.mouseDownAction_({
				loadView.(path.fullPath);
			});

			view.decorator.nextLine;
		});
	};

	draw.(path, cv);
};

~main = {
	show.(rootpath);
};

~main.();

)




