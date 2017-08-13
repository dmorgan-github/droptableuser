(
var path = "/Users/david/projects/droptableuser/apps/surface/";
var viewsPath = path ++ "views/";

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
	var util = File.open(path ++ "funcs.scd", "r").readAllString.interpret;

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
		var obj = File.open(file, "r").readAllString.interpret;
		view = viewObj[\view].(objName, envir, obj, util);
	};

	view.front;
};

var show = {arg path;

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

	Button(view, 30@20)
	.font_(Font(fontFamily, fontSize))
	.background_(Color.black.alpha_(0.8))
	.states_([ ["rec", Color.white, Color.black.alpha_(0.8)], ["stop", Color.red, Color.black.alpha_(0.8)] ] )
	.action_({arg ctrl; if (ctrl.value == 1) {s.record} {s.stopRecording} });

	cv = ScrollView(win, width@height)
	.background_(Color.black)
	.alpha_(0.8)
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
		//var folder = pathName.folderName;

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
				loadView.(path.fullPath);
			});

			StaticText.new(view, textWidth@fontSize )
			.string_(path.fileName)
			.stringColor_(Color.white)
			.font_(Font(fontFamily, fontSize))
			.mouseDownAction_({
				loadView.(path.fullPath);
			});

			view.decorator.nextLine;
		});
	};

	draw.(path, cv);
};

~main = {
	show.(path);
};

~main.();

)


