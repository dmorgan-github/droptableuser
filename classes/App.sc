App {

	*initClass {
	}

	*midiInit {
		MIDIClient.init;
		MIDIClient.initialized.debug("midi initialized");
	}

	*scynapse {
		var envir = Ndef.dictFor(Server.default).envir;
		File.open("/Users/david/projects/scynapse/_main.scd", "r").readAllString.interpret;
		Fdef(\scynapse).(envir, "/Users/david/projects/scynapse/");
	}

	*idgen {
		var str = {"aaabcdeeefghiiijklmnooopqrstuuuvwxyz".choose}.dup(rrand(4,8)).join;
		"echo % | pbcopy".format(str).systemCmd;
		^str
	}

	*saveWorkspace {arg name = "", folder = "~/projects/droptableuser/workspaces", rec = false, envir;

		var workspace = "%/%-%-%/%%".format(name,
			Date.getDate.year, Date.getDate.month, Date.getDate.day, Date.getDate.hour, Date.getDate.minute);
		var current_doc = Document.current;
		var current_path = folder.standardizePath ++ "/" ++ workspace;
		var dirname;

		if (File.exists(current_path).not) {
			File.mkdir(current_path);
		};

		Document.openDocuments.do({arg doc;
			var file_name = PathName(doc.title);
			var path = current_path ++ "/" ++ file_name.fileName;
			var content = doc.string;
			var file = File(path, "w");
			path.debug("writing...");
			file.write(content);
			file.close();
		});

		if (rec) {
			var tempo = TempoClock.default.tempo;
			Server.default.record(current_path ++ "/SC_" ++ Date.getDate.stamp ++ ".aiff");
		}
	}

	*guiHelper {arg proxy, name;

		var width = 390;
		var rowHeight = 22;
		var numItems = proxy.controlNames.size;
		var view;
		var win = Window();
		win.addFlowLayout(2@2,2@2);
		NdefGui(proxy, numItems:numItems, parent:win);

		view = View().name_(name)
		.layout_(VLayout().margins_(0).spacing_(0))
		.minHeight_(numItems*rowHeight)
		.minWidth_(width); // ?

		view.layout.add(HLayout(
			Button().states_([ ["_"],["-"] ]).action_({arg ctrl;
				if (ctrl.value == 1) {
					view.alwaysOnTop_(true)
				}{
					view.alwaysOnTop_(false)
				};
			}),
			Button().states_([["><"],["<>"]]).action_({arg ctrl;
				if (ctrl.value == 1) {
					view.maxHeight = rowHeight;
					view.minHeight = rowHeight;
					view.resizeTo(width, rowHeight);
				}{
					view.minHeight = numItems*rowHeight;
					view.maxHeight = numItems*rowHeight * 2;
				}
			})
		));
		view.layout.add(win.asView);
		^view;
	}
}
