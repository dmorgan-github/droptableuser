App {

	classvar <>workspacedir, <>mediadir, <>librarydir;

	*initClass {
		workspacedir = "~/Documents/supercollider/workspaces/".standardizePath;
		mediadir = "~/Documents/supercollider/media/".standardizePath;
		librarydir = "~/projects/droptableuser/library/".standardizePath;
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
		var str = {"aaabcdeeefghiiijklmnooopqrstuuuvwxyz".choose}.dup(rrand(3,5)).join;
		"echo % | pbcopy".format(str).systemCmd;
		^str
	}

	*recdir {arg dir;
		var path = workspacedir ++ dir;
		path.debug(\recordingsDir);
		thisProcess.platform.recordingsDir_(path);
	}

	*rec {arg dir;
		thisProcess.platform.recordingsDir_(workspacedir ++ dir);
		Server.default.record;
	}

	*recAtCommit {arg dir="", commit="";

		var filepath = "%/%/".format(Platform.recordingsDir, dir);
		if (File.exists(filepath).not) {
			File.mkdir(filepath);
		};

		filepath = filepath ++ "%_%.aiff".format(commit, Date.getDate.asSortableString);
		Server.default.record(filepath);
	}

	*saveWorkspace {arg name = "", folder = "~/Documents/supercollider/workspaces".standardizePath, rec = true, envir;

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
			var path = current_path ++ "/_wip_" ++ file_name.fileName;
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
}
