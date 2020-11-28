TwisterOsc {

	classvar <server, num, <>page;

	*new {|tabs|

		var update = {|selected|
			if (selected < tabs.size) {
				num.do({|i|
					RotaryOsc(i);
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
		page = 'twister';
		num = 16;
		StartUp.add({
			server = NetAddr("10.0.1.81", 9000);
		});
	}
}

RotaryOsc {

	classvar <server;

	*new {|num, label, setfunc, getfunc, spec|

		var page = 'twister';
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

		if (inSrcKey.isNil) {
			inSrcKey = "IAC Driver";
		};

		src = MIDIClient.sources
		.select({arg src; src.device.beginsWith(inSrcKey)})
		.first;

		//MIDIIn.connect(device:src);
		MIDIIn.connectAll;

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
			MIDIdef.cc(key, {arg val, ccNum, chan, src;
				if (enabled) {
					func.(val, ccNum, chan);
				}
			}, ccNum: num, chan:chan, srcID:srcid)
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

Twister : MidiCtrl {

	classvar id;

	classvar instance;

	var <>midiout;

	var <>midimap;

	*new {|chan=0|
		if (instance.isNil) {
			instance = super.new(id, "twister", chan);
		};
		^instance;
	}

	*doesNotUnderstand {|selector ...args|
		var res = this.new();
		^res.perform(selector, *args);
	}

	init {|inKey, inSrcKey, inChan|
		super.init(inKey, inSrcKey, inChan);
		this.midiout = MIDIOut.newByName("twister", "USB MIDI Device");
		this.midimap = Order.new;
	}

	ccMap {|ccNum, spec|
		var nodeKey = "twister_%_%_cc%".format(this.key, this.chan, ccNum).asSymbol.debug(\ccmap);
		var myspec = spec.asSpec;
		var node = Ndef(nodeKey.asSymbol, { \val.kr(spec:myspec) });
		var default = myspec.default.linlin(myspec.minval, myspec.maxval, 0, 127);
		// initialize
		midimap[ccNum] = (
			num: ccNum,
			spec:myspec,
			node:node
		);
		midiout.control(this.chan, ccNum, default);
		this.cc(ccNum, {|val|
			node.set(\val, myspec.map(val/127));
		});
		^node;
	}

	ccFunc {|ccNum, func|
		var nodeKey = "twister_%_%_cc%".format(this.key, this.chan, ccNum).asSymbol.debug(\ccfunc);
		var default = 0;
		// initialize
		midiout.control(this.chan, ccNum, default);
		this.cc(ccNum, func);
	}

	asMap {|ccNum|
		var nodeKey = "twister_%_%_cc%".format(this.key, this.chan, ccNum).asSymbol.debug(\ccmap);
		^Ndef(nodeKey.asSymbol);
	}

	clear {
		midimap.do({|item|
			item.clear;
		});
		super.clear();
	}

	*initClass {
		id = ('twister_' ++ UniqueID.next).asSymbol;
	}
}

Microlab : MidiCtrl {

	classvar id;

	*new {|chan=2|
		^super.new(id, "Arturia MicroLab", chan);
	}

	*initClass {
		id = ('microlab_' ++ UniqueID.next).asSymbol;
	}
}

Roli : MidiCtrl {

	classvar id;

	// bend semitones
	classvar <>bendst;

	var <bendMap;

	classvar instance;

	*new {|chan=1|
		if (instance.isNil) {
			instance = super.new(id, "Lightpad BLOCK", chan);
		}
		^instance;
	}

	*doesNotUnderstand {|selector ...args|
		var res = this.new();
		^res.perform(selector, *args);
	}

	init {|inKey, inSrcKey, inChan|
		super.init(inKey, inSrcKey, inChan);
		bendMap = Ndef((inKey ++ '_bend').asSymbol, {\val.kr(0).lag(0.5) });
		this.bend({|val|
			var bend = val.linlin(0, 16383, bendst.neg, bendst);
			bendMap.set(\val, bend);
		});
	}

	note {|on, off|
		var bendoff = {|note, chan|
			off.(note, chan);
			bendMap.set(\val, 0);
		};
		super.note(on, bendoff);
	}


	*initClass {
		id = ('roli_' ++ UniqueID.next).asSymbol;
		bendst = 12;
	}
}


