App {

	*initClass {
	}

	*record {
		Server.default.record(Document.current.path ++ "-" ++ Date.getDate.asSortableString ++ ".aiff");
	}

	*recordPatch {arg folder = "~/projects/droptableuser/workspaces";

		var date = Date.getDate.asSortableString;
		var current_doc = Document.current;
		var current_path = folder.standardizePath ++ "/" ++ current_doc.title;
		var dirname;

		if (File.exists(current_path).not) {
			File.mkdir(current_path);
		};

		dirname = current_path ++ "/" ++ date;
		if (File.exists(dirname).not) {
			File.mkdir(dirname);
		};

		{
			var file_name = PathName(current_doc.title);
			var path = dirname ++ "/" ++ file_name.fileName;
			var content = current_doc.string;
			var file = File(path, "w");
			path.debug("writing...");
			file.write(content);
			file.close();

			Server.default.record(dirname ++ "/" ++ current_doc.title ++ "-" ++ date ++ ".aiff");
		}.();
	}

	*recordWorkspace {arg name = "unknown", folder = "~/projects/droptableuser/workspaces";

		var date = Date.getDate.asSortableString;
		var current_doc = Document.current;
		var current_path = folder.standardizePath ++ "/" ++ name;
		var dirname;

		if (File.exists(current_path).not) {
			File.mkdir(current_path);
		};

		dirname = current_path ++ "/" ++ date;
		if (File.exists(dirname).not) {
			File.mkdir(dirname);
		};

		Document.openDocuments.do({arg doc;
			var file_name = PathName(doc.title);
			var path = dirname ++ "/" ++ file_name.fileName;
			var content = doc.string;
			var file = File(path, "w");
			path.debug("writing...");
			file.write(content);
			file.close();
		});

		Server.default.record(dirname ++ "/" ++ current_doc.title ++ "-" ++ date ++ ".aiff");
	}

	*recordVersion {
		var date = Date.getDate.asSortableString;
		var current_doc = Document.current;
		var current_path = current_doc.path;
		var dirname = current_path ++ "-" ++ date;

		if (File.exists(dirname).not) {
			File.mkdir(dirname);
		};

		Document.openDocuments.do({arg doc;
			var file_name = PathName(doc.title);
			var path = dirname ++ "/" ++ file_name.fileNameWithoutExtension ++ "-" ++ date ++ "." ++ file_name.extension;
			var content = doc.string;
			var file = File(path, "w");
			path.debug("writing...");
			file.write(content);
			file.close();
		});

		Server.default.record(dirname ++ "/" ++ current_doc.title ++ "-" ++ date ++ ".aiff");
	}

	*defaultOut {arg server, numOutputBusChannels = 8;

		server.options.numOutputBusChannels = numOutputBusChannels;
		server.options.outDevice_("Built-in Output");
		server.options.inDevice_("Built-in Microph");
		server.reboot;
	}

	*soundflowerOut {arg server, numOutputBusChannels = 16;

		// check volume control in task bar
		// check volume in midi
		// check volume in sound preferences
		// check that both Soundflower (64ch) and Soundflower (2ch) are not muted
		server.options.numOutputBusChannels = numOutputBusChannels;
		server.options.inDevice_("Built-in Microph");
		server.options.outDevice_("Soundflower (64ch)");
		server.reboot;
	}
}

