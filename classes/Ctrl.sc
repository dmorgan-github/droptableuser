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

	var <key, <src, <>enabled;

	*new {arg key, src=\iac;
		var res = all[key];
		if (res.isNil) {
			res = super.new.init(key, src);
			all.put(key, res);
		};
		^res;
	}

	init {arg inKey, inSrcKey;

		\superinit.postln;
		key = inKey;
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
	}

	*trace {arg enable=true;
		// TODO need to ensure midi is initialized and connected
		MIDIClient.init;
		MIDIIn.connectAll;
		MIDIFunc.trace(enable);
	}

	note {arg on, off, chan;
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

	cc {arg num, func, chan;

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

	bend {arg func, chan;
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
	touch {arg func, chan;
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

	classvar <instance;

	var <>ccChan, <>noteChan;

	var <>midiout;

	var <>midimap;

	*new {
		if (instance.isNil) {
			instance = super.new(id, "Midi Fighter Twister");
		};
		^instance;
	}

	*doesNotUnderstand {|selector ...args|
		var res = this.new();
		^res.perform(selector, *args);
	}

	init {|inKey, inSrcKey|
		\hereinit.postln;
		super.init(inKey, inSrcKey);
		this.midiout = MIDIOut.newByName("Midi Fighter Twister", "Midi Fighter Twister");
		this.midimap = Order.new;
		this.ccChan = 0;
		this.noteChan = 1;
		^this;
	}

	ccMap {|ccNum, spec|

		var nodeKey = "%_%_cc%".format(this.key, ccChan, ccNum).asSymbol.debug(\ccmap);
		var myspec = spec.asSpec;
		var node = Ndef(nodeKey.asSymbol, { \val.kr(spec:myspec) });
		var default = myspec.default.linlin(myspec.minval, myspec.maxval, 0, 127);
		// initialize
		midimap[ccNum] = (
			num: ccNum,
			spec:myspec,
			node:node
		);
		midiout.control(ccChan, ccNum, default);
		super.cc(ccNum, {|val|
			node.set(\val, myspec.map(val/127));
		}, ccChan);
		^node;
	}

	ccFunc {|ccNum, func, default=0|
		var nodeKey = "%_%_cc%".format(this.key, ccChan, ccNum).asSymbol.debug(\ccfunc);
		// initialize
		default = default.linlin(0, 1, 0, 127);
		midiout.control(ccChan, ccNum, default);
		super.cc(ccNum, func, ccChan);
	}

	note {|on, off|
		super.note(on, off, noteChan);
	}

	noteFunc {|num, on, off|
		var onfunc = {|note, vel|
			if (note == num) {
				on.(note, vel);
			}
		};
		var offfunc = {|note|
			if (note == num) {
				off.(note);
			}
		};
		super.note(onfunc, offfunc, noteChan);
	}

	asMap {|ccNum|
		var nodeKey = "%_%_cc%".format(this.key, ccChan, ccNum).asSymbol.debug(\ccmap);
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

	var <>ccChan, <>noteChan;

	*new {|chan=2|
		^super.new(id, "Arturia MicroLab");
	}

	*initClass {
		id = ('microlab_' ++ UniqueID.next).asSymbol;
	}
}

Roli : MidiCtrl {

	classvar id;

	// bend semitones
	classvar <>bendst;

	classvar instance;

	var <>ccChan, <>noteChan;

	var <bendMap;


	*new {
		if (instance.isNil) {
			instance = super.new(id, "Lightpad BLOCK");
		}
		^instance;
	}

	*doesNotUnderstand {|selector ...args|
		var res = this.new();
		^res.perform(selector, *args);
	}

	init {|inKey, inSrcKey|
		super.init(inKey, inSrcKey);
		bendMap = Ndef((inKey ++ '_bend').asSymbol, {\val.kr(0).lag(0.5) });
		this.ccChan = 2;
		this.noteChan = 2;
		this.bend({|val|
			var bend = val.linlin(0, 16383, bendst.neg, bendst);
			bendMap.set(\val, bend);
		}, this.ccChan);
	}

	note {|on, off|
		var bendoff = {|note, chan|
			off.(note, chan);
			bendMap.set(\val, 0);
		};
		super.note(on, bendoff, noteChan);
	}


	*initClass {
		id = ('roli_' ++ UniqueID.next).asSymbol;
		bendst = 12;
	}
}


