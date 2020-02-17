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

	var <key, <src, <chan;

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
				}
			);
			MIDIIn.connect(device:src);
		};
		^this;
	}

	*trace {arg enable=true;
		// TODO need to ensure midi is initialized and connected
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
				on.(note, vel, chan);
			}, chan:chan, srcID:srcid)
			.permanent_(true);
		};

		if (off.isNil){
			"free %".format(offkey).debug(this.key);
			MIDIdef(offkey).permanent_(false).free;
		}{
			"register %".format(offkey).debug(this.key);
			MIDIdef.noteOff(offkey, func:{arg vel, note, chan, src;
				off.(note, chan);
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
				func.(val, num, chan);
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
				func.(val, chan);
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
				func.(val, chan);
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