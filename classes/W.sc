/*
Workspace
*/
W : Environment {

	classvar <all, <>clock;

	var <key, <>daw;

	var <matrix;

	var <node;

	var <group, <bus;

	var cmdperiod;

	*new {|key|
		var res = all[key];
		if (res.isNil) {
			res = super.new(8, nil, nil, true).prWInit(key);
			all[key] = res;
		};
		^res;
	}

	*doesNotUnderstand {|key|
		var res = all[key];
		if (res.isNil){
			res = W(key);
		};
		^res;
	}

	*recdir {
		var path = Document.current.dir;
		thisProcess.platform.recordingsDir_(path.debug(\recdir));
	}

	*mixer {
		var m = NdefMixer(Server.default);
		ProxyMeter.addMixer(m);
		m.switchSize(0);
		^m;
	}

	prSetTree {
		var me = this;
		{
			\prSetTree.debug(me.key);
			me.keysValuesDo({|k, v|
				if (v.respondsTo(\parentGroup)) {
					v.parentGroup = me.node.group;
					v.monitor.out = me.node.bus.index;
				}{
					v.node.parentGroup = me.node.group;
					v.node.monitor.out = me.node.bus.index;
				}
			})
		}.defer(2);
		//TODO: Trying to gracefully handle a cmdperiod
		// two seconds is a long time to wait but need to provide
		// time for VSTs to be reloaded before setting
		// their tree structure. I'm not sure what events
		// to wait for to make this a bit more robust
	}

	put {|key, value|
		super.put(key, value);
		this.prSetTree;
		this.changed(\add, key -> value);
		this.matrix.addSrc(value);
	}

	removeAt {|key|
		super.removeAt(key);
		this.changed(\remove, key);
		this.matrix.removeSrc(key);
	}

	init {|cb|
		var me = this;
		this.use(cb);
		this.prSetTree;
		this.keysValuesDo({|k, v|
			me.matrix.addSrc(v);
		})
	}

	view {
		^U(\workspace, this);
	}

	sends {
		^U(\matrix, matrix);
	}

	mixer {
		var m = ProxyMixer(this.as(ProxySpace));
		ProxyMeter.addMixer(m);
		m.switchSize(0);
		^m;
	}

	prWInit {|argKey|

		var path = "%%/".format(App.workspacedir, key);
		if (File.exists(path).not) {
			"init workspace %".format(path).inform;
			File.makeDir(path);
		};
		key = argKey;
		daw = \bitwig;
		matrix = M((argKey ++ '_matrix').asSymbol);
		node = Ndef((argKey ++ '_group').asSymbol);
		node.play;
		//group = Group.new;
		//group.isPlaying = true;
		//bus = Bus.audio(Server.default, 2);

		//TODO: need to handle clear and clean up
		cmdperiod = {
			\cmdperiod.debug(argKey);
			node.play;
			this.prSetTree;
		};
		ServerTree.add(cmdperiod);

		this.recdir;
		^this;
	}

	record {
		if (daw == \bitwig) {
			Bitwig.record;
		};
		if (daw == \reaper) {
			Reaper.record
		}
	}

	stopRecording {
		if (daw == \bitwig) {
			Bitwig.stop;
		};
		if (daw == \reaper) {
			Reaper.stopRecording;
		}
	}

	tempo {|bps=1|
		if (daw == \bitwig) {
			Bitwig.tempo(bps)
		};
		if (daw == \reaper) {
			Reaper.tempo(bps)
		}
	}

	time {|val=0|
		if (daw == \bitwig) {
			Bitwig.time(val)
		};
		if (daw == \reaper) {
			Reaper.time(val);
		}
	}

	save {|rec=true|

		var folder = App.workspacedir;
		var workspace = "%/%-%-%/%%".format(key,
			Date.getDate.year, Date.getDate.month, Date.getDate.day, Date.getDate.hour, Date.getDate.minute);
		var current_doc = Document.current;
		var current_path = folder.standardizePath ++ workspace;
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
			var ext = Server.default.recHeaderFormat;
			Server.default.record(current_path ++ "/SC_" ++ Date.getDate.stamp ++ "." ++ ext);
		}
	}

	saveResource {|name, content|
		var file, path;
		var dir = "%%/%/".format(App.workspacedir, key.asString, "resources");
		if (File.exists(dir).not) {
			File.mkdir(dir);
		};
		path = "%%.scd".format(dir, name);
		\saving.debug(path);
		if (content.isString.not) {
			content = content.asCompileString;
		};
		file = File(path, "w");
		file.write(content);
		file.close;
	}

	loadResource {|name|
		var path = "%%/%/%.scd".format(App.workspacedir, key.asString, "resources", name);
		var obj = thisProcess.interpreter.executeFile(path);
		^obj
	}

	ls {
		var path = "%%%".format(App.workspacedir, key.asString, "/resources/");
		^PathName(path).entries.collect({|pn| pn.fileNameWithoutExtension})
	}

	*initClass {
		all = IdentityDictionary();
		//clock = LinkClock.new.latency_(Server.default.latency).permanent_(true);
	}
}