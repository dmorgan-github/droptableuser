Twister {

	classvar <server, num, page;

	*new {|tabs|

		var update = {|selected|
			if (selected < tabs.size) {
				num.do({|i|
					Rotary(i);
				});
				tabs[selected].value.();
			}
		};

		num.do({|i|
			var index = i+1;
			var path = "/%/nodes/%/1".format(page, index).asSymbol;
			var func = {|val|
				var selected = num-index;
				val = val[0];
				if (val.asInteger == 1) {
					update.(selected)
				}
			};
			OscCtrl.path(path, func)
		});

		tabs.do({|val, num|
			var name = val.key;
			var path = "/%/nodelabel%".format(page, num).asSymbol;
			server.sendMsg(path, name);
		});
	}

	*initClass {
		page = 4;
		num = 16;
		StartUp.add({
			server = NetAddr("10.0.1.81", 9000);
		});
	}
}

Rotary {

	classvar <server;

	*new {|num, label, setfunc, getfunc, spec|

		var page = 4;
		var valpath = "/%/val%".format(page, num).asSymbol;
		var labelpath = "/%/label%".format(page, num).asSymbol;
		var path = "/%/rotary%".format(page, num).asSymbol;

		if (label.isNil) {
			server.sendMsg(valpath, "");
			server.sendMsg(labelpath, "");
			server.sendMsg(path, 0);
		}{
			var val;
			spec = if (spec.isNil) {
				spec = ControlSpec.specs[label.asSymbol];
				if (spec.isNil) {
					spec = ControlSpec(0, 1, \lin, 0, 0);
				};
				spec;
			};

			OscCtrl.path(path, {arg msg;
				var val = msg[0];
				val = spec.map(val);
				setfunc.(val);
				val = val.trunc(0.001);
				server.sendMsg(valpath, val);
			});
			server.sendMsg(labelpath, label);

			val = getfunc.() ?? spec.default;
			val = val.trunc(0.001);
			server.sendMsg(valpath, val);

			val = spec.unmap(val);
			server.sendMsg(path, val);
		}
	}

	*initClass {

		StartUp.add({
			server = NetAddr("10.0.1.81", 9000);
		});
	}
}


/*
(
OscCtrl.paths('/rotary8/r', (1..12), {arg val, num;
	var note = 48 + (num-1);
	if (val == 1) {
		S(\synth1).on(note, 1);
	}{
		S(\synth1).off(note);
	}
});
)
OscCtrl.paths('/rotary8/r', (1..12), nil);
*/
OscCtrl {

	/*
	Note: use symbol notation for path
	*/
	*path {arg path, func;
		var key = path.asSymbol;
		if (func.isNil) {
			"free %".format(key).postln;
			OSCdef(key).free;
		}{
			"register %".format(key).postln;
			OSCdef.newMatching(key, {arg msg, time, addr, recvPort;
				var val = msg[1..];
				func.(val);
				nil;
			}, key).permanent_(true);
		};
	}

	/*
	Note: use symbol notation for prefix
	*/
	*paths {arg prefix, nums, func;
		if (func.isNil) {
			nums.do({arg i;
				var path =  "%%".format(prefix, i).asSymbol;
				"free %".format(path).debug(\many);
				OSCdef(path).free;
			});
		}{
			nums.do({arg i;
				var path =  "%%".format(prefix, i).asSymbol;
				"register %".format(path).debug(\many);
				OSCdef.newMatching(path, {arg msg, time, addr, recvPort;
					var val = msg[1];
					func.(val, i);
					nil;
				}, path).permanent_(true);
			});
		}
	}

	*trace {arg enable=true;
		OSCdef.trace(enable);
	}
}

/*
(
MidiCtrl(\qaryrf)
.note(
	{arg note, vel;
		var myvel = vel/127;
		S(\usmo).on(note, myvel)
	},
	{arg note;
		S(\usmo).off(note)
	}
)
.cc(0, {arg val, num, chan;
	var myval = val/127;
	S(\usmo).set(\start, myval);
});
)
MidiCtrl(\qaryrf).note(nil, nil).cc(0, nil);
*/
MidiCtrl {

	classvar <all;

	var <key, <src, <chan, <>enabled;

	*new {arg key, src=\iac, chan;
		var res = all[key];
		if (res.isNil) {
			res = super.new.init(key, src, chan);
			all.put(key, res);
		};
		^res;
	}

	init {arg inKey, inSrcKey, inChan;
		key = inKey;
		chan = inChan;
		enabled = true;
		MIDIClient.init;
		if (inSrcKey.isNil.not) {
			src = switch(inSrcKey,
				\roli_usb, {
					MIDIClient.sources
					.select({arg src; src.device.beginsWith("Lightpad BLOCK")})
					.first
				},
				\roli_bt, {
					MIDIClient.sources
					.select({arg src; src.device.beginsWith("Lightpad Block 1UOC")})
					.first
				},
				\iac, {
					MIDIClient.sources
					.select({arg src; src.device.beginsWith("IAC Driver")})
					.first;
				},
				\trellis, {
					MIDIClient.sources
					.select({arg src; src.device.beginsWith("Adafruit Trellis M4")})
					.first;
				},
				\microlab, {
					MIDIClient.sources
					.select({arg src; src.device.beginsWith("Arturia MicroLab")})
					.first;
				}
			);
			MIDIIn.connect(device:src);
		};
		^this;
	}

	*trace {arg enable=true;
		// TODO need to ensure midi is initialized and connected
		MIDIClient.init;
		MIDIIn.connectAll;
		MIDIFunc.trace(enable);
	}

	note {arg on, off;


		var mychan = if (chan.isNil) {"all"}{chan};
		var srcid = if (this.src.isNil.not){src.uid}{nil};
		var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
		var onkey = ("%_%_%_on").format(this.key, mychan, srcdevice).asSymbol;
		var offkey = ("%_%_%_off").format(this.key, mychan, srcdevice).asSymbol;

		if (on.isNil) {
			"free %".format(onkey).debug(this.key);
			MIDIdef(onkey).permanent_(false).free;
		}{
			"register %".format(onkey).debug(this.key);
			MIDIdef.noteOn(onkey, func:{arg vel, note, chan, src;
				if (enabled) {
					on.(note, vel, chan);
				}
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		};

		if (off.isNil){
			"free %".format(offkey).debug(this.key);
			MIDIdef(offkey).permanent_(false).free;
		}{
			"register %".format(offkey).debug(this.key);
			MIDIdef.noteOff(offkey, func:{arg vel, note, chan, src;
				if (enabled) {
					off.(note, chan);
				}
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		};

		^this;
	}

	cc {arg num, func;
		var mychan = if (chan.isNil) {"all"}{chan};
		var srcid = if (this.src.isNil.not){src.uid}{nil};
		var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
		var key = "%_%_%_cc%".format(this.key, mychan, srcdevice, num).asSymbol;
		if (func.isNil) {
			"free %".format(key).debug(this.key);
			MIDIdef(key).permanent_(false).free;
		}{
			"register %".format(key).debug(this.key);
			MIDIdef.cc(key, {arg val, num, chan, src;
				if (enabled) {
					func.(val, num, chan);
				}
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		}
	}

	bend {arg func;
		var mychan = if (chan.isNil) {"all"}{chan};
		var srcid = if (this.src.isNil.not){src.uid}{nil};
		var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
		var key = "%_%_%_bend".format(this.key, mychan, srcdevice).asSymbol;
		if (func.isNil) {
			"free %".format(key).debug(this.key);
			MIDIdef(key).permanent_(false).free;
		}{
			"register %".format(key).debug(this.key);
			MIDIdef.bend(key, {arg val, chan, src;
				// var bend = val.linlin(0, 16383, 0.9, 1.1);
				if (enabled) {
					func.(val, chan);
				}
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		}
	}

	// pressure
	touch {arg func;
		var mychan = if (chan.isNil) {"all"}{chan};
		var srcid = if (this.src.isNil.not){src.uid}{nil};
		var srcdevice = if (this.src.isNil.not){this.prNormalize(src.device)}{"any"};
		var key = "%_%_%_touch".format(this.key, mychan, srcdevice).asSymbol;
		if (func.isNil) {
			"free %".format(key).debug(this.key);
			MIDIdef(key).permanent_(false).free;
		}{
			"register %".format(key).debug(this.key);
			MIDIdef.touch(key, {arg val, chan, src;
				if (enabled) {
					func.(val, chan);
				}
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		}
	}

	clear {
		this.note(nil, nil);
		this.bend(nil);
		// clear all with brute force
		127.do({arg i;
			this.cc(i, nil);
		});
		all.removeAt(key)
	}

	prNormalize {arg str;
		^str.toLower().stripWhiteSpace().replace(" ", "")
	}

	*clearAll {
		all.do({arg m; m.clear()});
		all.clear;
	}

	*initClass { all = () }
}

Microlab : MidiCtrl {

	classvar id;

	*new {|chan=2|
		^super.new(id, \microlab, chan);
	}

	*initClass {
		id = ('microlab_' ++ UniqueID.next).asSymbol;
	}
}

Roli : MidiCtrl {

	classvar id;

	*new {|chan=1|
		^super.new(id, \roli_usb, chan);
	}

	*initClass {
		id = ('roli_' ++ UniqueID.next).asSymbol;
	}
}

/*
/////////////////////////////////////////
// name
(

var page = "4";

~controller = ~controller ?? NetAddr("10.0.1.81", 9000);

~displayname = {|num, name|
	var path = "/%/nodelabel%".format(page, num).asSymbol;
	~controller.sendMsg(path, name);
};
~setval = {|path, val|
	~controller.sendMsg(path, val);
};
~displaylabel = {|num, label|
	var path = "/%/label%".format(page, num).asSymbol;
	~controller.sendMsg(path, label);
};
~displayval = {|num, val|
	var path = "/%/val%".format(page, num).asSymbol;
	var msg = val.trunc(0.001);
	~controller.sendMsg(path, msg);
};

~touchosc_16r = {|nodes|

	var update;
	var num = 16;

	num.do({|i|
		var index = i+1;
		var path = "/%/nodes/%/1".format(page, index).asSymbol;
		var func = {|val|
			var selected = num-index;
			update.(selected);
		};
		OscCtrl.path(path, func)
	});

	nodes.do({|assoc, k|
		var node = assoc.key;
		~displayname.(k, node.key);
	});

	update = {|selected|

		if (selected < nodes.size) {

			var assoc = nodes[selected];
			var node = assoc.key;
			var props = assoc.value;

			// clear
			16.do({|i|
				var path = "/%/rotary%".format(page, i).asSymbol;
				var val = 0;
				~setval.(path, val);
				~displaylabel.(i, "");
				~displayval.(i, "");
				OscCtrl.path(path, nil);
			});

			props.do({|prop, i|

				var func, val, myval;
				var path = "/%/rotary%".format(page, i).asSymbol;
				var spec = node.checkSpec[prop];
				if (spec.isNil) {
					spec = [0, 1, \lin, 0, 0].asSpec;
				};

				val = node.get(prop);
				myval = spec.unmap(val);
				~setval.(path, myval);
				~displaylabel.(i, prop.postln);
				~displayval.(i, val);

				func = {|val|
					var myval = val[0];
					var msg;
					myval = spec.map(myval);
					node.set(prop, myval);
					~displayval.(i, myval);
				};
				OscCtrl.path(path, func);
			});
		}
	}
};
)

(
~touchosc_16r.([
	Pdef(\t2_c) -> [\t2_cutoff, \t2_fvel, \t2_res, \t2_rel, \t2_pulse ],
	Pdef(\t3_a) -> [\t3_velmin]
]);
)
*/


