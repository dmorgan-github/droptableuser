CC {
	var <num, <min, <max, <cb;

	*new {arg num, min=0, max=1, cb;
		^super.new.ccInit(num, min, max, cb);
	}

	ccInit {arg inNum, inMin=0, inMax=1, inCb;
		num = inNum;
		min = inMin;
		max = inMax;
		cb = inCb;
		^this;
	}
}


B {
	var <min, <max, <stL, <stH, <cb;

	*new {arg min=6290, max=10099, stL=(-24), stH=24, cb;
		^super.new.bInit(min, max, stL, stH, cb);
	}

	bInit {arg inMin, inMax, inStL, inStH, inCb;
		min = inMin;
		max = inMax;
		stL = inStL;
		stH = inStH;
		cb = inCb;
		^this;
	}
}

Device {

	var <key, order, <midichan=0, <oscpath, <oscport;

	*new { arg key;
		^super.new.deviceInit(key);
	}

	deviceInit {arg inKey;
		key = inKey.asSymbol;
		oscpath = ('/' ++ key).asSymbol;
		oscport = 57120;
		order = Order.new;
		^this;
	}

	fx_ {arg index=1, val, wet=1 ...args;

		var func, settings, reset = false;
		if (val.isNil) {
			this.removeAt_(index);
		}{
			if (val.class == Function) {
				func = val;
			} {
				func = Library.at(\fx, val).performKeyValuePairs(\value, args);
			};

			// since reloading the filter interrupts
			// the ongoing sound we want to try to prevent that
			// by checking to see if the user is updating the filter def
			settings = order.at(index);
			if (settings.isNil) {
				order.put(index, (\func:func.asCompileString));
				reset = true;
			} {
				if (settings[\func] != func.asCompileString) {
					reset = true;
				};
				if (args.includes(\reset)) {
					reset = true;
				}
			};
			if (reset) {
				"reset fx %".format(index).debug(this.key);
				Ndef(this.key).filter(index, func);
			};
			args = this.prGetArgs(args);
			Ndef(this.key).set(('wet' ++ index).asSymbol, wet)
			.set(*args.asPairs);
		}
		^this;
	}

	midichan_ {arg chan=0;
		midichan = chan;
		^this;
	}

	midion_ {arg chan=0, trig=false, ampscale=1, cb;

		var onkey = (this.key ++ '_on').asSymbol;
		var offkey = (this.key ++ '_off').asSymbol;
		var trigkey = (this.key ++ '_trig').asSymbol;
		this.midichan = chan;
		if (trig) {
			"register note on with trigger".debug(this.key);
			MIDIdef(onkey).free;
			MIDIdef(offkey).free;
			MIDIdef.noteOn((this.key ++ '_trig').asSymbol, func:{arg vel, note, chan, src;
				var myvel = vel = (vel/127) * ampscale;
				var mynote = note.midicps;
				if (cb.isNil.not) {
					#myvel, mynote = cb.(vel, note);
				};
				Ndef(this.key).set(\freq, mynote, \amp, myvel, \trig, 1, \glide, 1);
			}, chan:this.midichan);

		}{
			"registering note on/off".debug(this.key);
			MIDIdef(trigkey).free;
			MIDIdef.noteOn((this.key ++ '_on').asSymbol, func:{arg vel, note, chan, src;
				var myvel = vel = (vel/127) * ampscale;
				var mynote = note.midicps;
				if (cb.isNil.not) {
					#myvel, mynote = cb.(vel, note);
				};
				Ndef(this.key).set(\freq, mynote, \amp, myvel, \trig, 1, \glide, 1);
			}, chan:this.midichan);

			MIDIdef.noteOff((this.key ++ '_off').asSymbol, func:{arg vel, note, chan, src;
				Ndef(this.key).set(\trig, 0, \glide, 0);
			}, chan:this.midichan);
		}
		^this;
	}

	midicc_ {arg ccNum=0, prop, min=0, max=1, cb;
		var key = (this.key ++ '_' ++ prop).asSymbol;
		"map midi cc: %".format(prop).debug(this.key);
		MIDIdef.cc(key, {arg val, num, chan, src;
			val = val.linlin(0, 127, min, max);
			if (cb.isNil.not){
				val = cb.(val);
			};
			Ndef(this.key).set(prop, val);
		}, ccNum:ccNum, chan:this.midichan);
		^this;
	}

	midibend_ {arg prop, min=6290, max=10099, stL=(-24), stH=24, cb;
		var key = (this.key ++ '_' ++ prop).asSymbol;
		"map midi bend: %".format(prop).debug(this.key);
		MIDIdef.bend(key, {arg val, num;
			val = val.linlin(min, max, stL, stH);
			if (cb.isNil.not){
				val = cb.(val);
			};
			//[prop, val, \bend].postln;
			Ndef(this.key).set(prop, val);
		}, chan:this.midichan);
		^this;
	}

	midifree_ {arg prop, val;
		if (prop.isNil.not) {
			var key = (this.key ++ '_' ++ prop).asSymbol;
			"free midi prop: %".format(prop).debug(this.key);
			MIDIdef(key).free;
			if (val.isNil.not) {
				Ndef(this.key).set(key, val);
			}
		}{
			"free midi".debug(this.key);
			MIDIdef(this.key).free;
		};
		^this;
	}

	oscpath_ {arg path='/', port=57120;
		oscpath = path;
		oscport = port;
		^this;
	}

	osc_ {arg prop, cb={arg msg; 0;};
		var key = (this.key ++ '_' ++ prop).asSymbol;
		var path = {
			if (prop.asString.beginsWith("/")){
				prop.asSymbol;
			}{
				(this.oscpath ++ '/' ++ prop).asSymbol;
			}
		}.();
		"osc map %".format(path).debug(this.key);
		OSCdef.newMatching(key, {arg msg, time, addr, recvPort;
			var val = cb.(msg);
			Ndef(this.key).set(prop, val);
		}, path)
		.permanent_(true);
		^this;
	}

	oscfree_ {arg prop;
		var key = (this.key ++ '_' ++ prop).asSymbol;
		"free osc map %".format(key).debug(this.key);
		OSCdef(key).free;
		^this;
	}

	removeAt_ {arg index=1;
		order.removeAt(index);
		Ndef(this.key).removeAt(index);
		^this;
	}

	set_ {arg ...args;
		args = this.prGetArgs(args);
		"args %".format(args).debug(this.key);
		Ndef(this.key).set(*args.asPairs);
		^this;
	}

	prGetArgs {arg args;
		args = args.collect({arg val, i;
			switch(val.class,
				Function, {
					var lfokey = (this.key ++ '_' ++ args[i-1]).asSymbol;
					"creating lfo node %".format(lfokey).debug(this.key);
					Ndef(lfokey, val)
				},
				CC, {
					var prop = args[i-1];
					this.midicc_(val.num, prop, val.min, val.max, val.cb);
					"creating cc mapping %".format(prop).debug(this.key);
					val;
				},
				B, {
					var prop = args[i-1];
					this.midibend_(prop, val.min, val.max, val.stL, val.stH, val.cb);
					"creating bend mapping %".format(prop).debug(this.key);
					val;
				},
				{val;}
			);
		}).reject({arg val, i; ((args[i+1].class == CC) || (val.class == CC))});
		^args;
	}

	play {arg ft=0, out=0, vol=1;
		Ndef(this.key).play(vol:vol, fadeTime:ft, out:out)
	}

	stop {arg ft=0;
		Ndef(this.key).stop(fadeTime:ft);
	}

	asNode {
		^Ndef(this.key);
	}

	clear {
		order.clear;
		Ndef(this.key).clear;
	}
}

V : Device {

	classvar <all;

	*new { arg key, voice ...args;
		^super.new(key).init(key, voice, args);
	}

	init {arg inKey, inVoice, args;
		var obj = all.at(inKey);
		if (obj.isNil) {
			obj = this;
			all.put(inKey, obj);
		};
		if (inVoice.isNil.not) {
			Ndef(inKey)[0] = Library.at(\voices, inVoice).performKeyValuePairs(\value, args);
		};
		^obj;
	}

	*clearAll {
		all.clear
	}

	*initClass {
		all = IdentityDictionary.new;
	}
}

M : Device {

	classvar <all;

	*new { arg key;
		^super.new(key).init(key);
	}

	init {arg inKey;
		var obj = all.at(inKey);
		if (obj.isNil) {
			key = inKey.asSymbol;
			obj = this;
			all.put(key, obj);
		};
		^obj;
	}

	v_ {arg index=0, voice, mix=1;
		if (index.isInteger.not) {
			"First arg should be an index for the voice. M:%".format(this.key).error;
		} {
			if (voice.isNil) {
				this.removeAt_(index);
			}{
				var node = Ndef(this.key);
				node[index] = \mix -> {voice.asNode.ar};
				node.set(('mix' ++ index).asSymbol, mix);
			}
		};
		^this;
	}

	*clearAll {
		all.clear
	}

	*initClass {
		all = IdentityDictionary.new;
	}
}

P {
	var <key;

	*new {arg key, func ...args;
		// by convention the key should match the key
		// of an instance of M so that all the nodes
		// are activated and monitoring for audio
		^super.new.init(key, func, args);
	}

	init {arg inKey, inFunc, inArgs;
		key = inKey.asSymbol;
		if (inFunc.isNil.not) {
			this.prBuild(inFunc, inArgs);
		};
		^Pdef(key);
	}

	prBuild {arg inFunc, inArgs;
		var patterns = inFunc.();
		var pbinds = patterns.collect({arg val, i;
			if (val.isKindOf(Pattern)) {
				val;
			}{
				var key = val.key; // could be an array
				var pairs = val.value; // pattern params

				// get the superset of unique args
				// for the specified ndef(s) where the ndef(s)
				// have matching controlnames
				var evtargs = {
					var setargs = [];
					var keys = pairs.reject({arg val, i; i.odd});
					key.asArray.do({arg val, i;
						var ctrls = Ndef(val).controlNames.collect({arg val; val.name}).asSet.sect(keys.asSet);
						setargs = setargs ++ ctrls;
					});
					// freq argument is implied by other properties
					setargs.asSet.asArray ++ if (keys.includes(\degree) || keys.includes(\note) || keys.includes(\midinote)) {\freq};
				}.();
				var props = [\type, \set,
					\id, Pfunc({ key.asArray.collect({arg val; Ndef(val.asSymbol).nodeID }) }),
					\args, evtargs] ++ pairs.asPairs;
				"pattern props %".format(props).debug(this.key);
				Pbind(*props)
			};
		});
		Pdef(this.key, {arg monitor=true, fadeTime=0;

			(this.key.asArray ++ inArgs).do({arg val, i;
				var node = Ndef(val);
				if ((node.rate == \audio) && node.isMonitoring.not && monitor){
					node.play(fadeTime:fadeTime)
				};
			});

			Ppar(pbinds);
		});
	}
}

/*
A wrapper around Pdef to work with an Ndef
and provide some convenience set up operations
(
Nbind(\isycxuo,
    \n, \rwzjmgoh,
    \trig, 1,
    \dur, 0.5,
    \degree, 0,
    \atk, 0.01,
    \sus, 0.25,
    \cutoff, 100,
    \res, 0.3,
    \fatk, 0.01,
    \fvel, 8,
    \fdec, 0.35,
);
)

// bit of a hack
// but allows for updating properties on the fly
Pdef(\isycxuo_p1, Pbindef(\isycxuo_set, \foo, 1) <> Nbind(\isycxuo));
Pdef(\isycxuo_p1, Nbind(\isycxuo));

(
Pbindef(\isycxuo_set,
    \dur, Pseq([3,2,3,4], inf) * 0.25,
    \scale, Scale.dorian,
    \degree, Pdefn(\xy),
    \octave, Pbjorklund(3,8).collect({arg val; if (val == 1){5}{4}}),
    \res, 0.3,
    \cutoff, 200,
    \fatk, 0.1,
    \fdec, Pkey(\sus),
    \fvel, 8,
    \sus, Pkey(\dur) * 1.4,
    \atk, 0.01
)
)
*/
Nbind {
    var <key;

	*new { arg key ...pairs;
		^super.new.init(key, pairs);
	}

    init {arg argKey, argPairs;
		key = argKey.asSymbol;
		if (argPairs.size > 0) {
            "building %".format(key).debug("nbind");
			this.prBuild(argKey, argPairs);
		};
		^Pdef(key);
	}

    prBuild {arg argKey, argPairs;

        var key = argPairs.asDict[\n] ?? argKey;
        var pairs = argPairs;

        var evtargs = {
            var setargs = [];
			var keys = pairs.reject({arg val, i; i.odd});
			key.asArray.do({arg val, i;
                var ctrls = Ndef(val).controlNames.collect({arg val; val.name}).asSet.sect(keys.asSet);
				setargs = setargs ++ ctrls;
			});
			// freq argument is implied by other properties
			setargs.asSet.asArray ++ if (keys.includes(\degree) || keys.includes(\note) || keys.includes(\midinote)) {\freq};
		}.();
		var props = [
            \type, \set,
            \id, Pfunc({ key.asArray.collect({arg val; Ndef(val.asSymbol).nodeID }) }),
            \args, evtargs
        ] ++ pairs.asPairs;

        "pattern props %".format(props).debug(argKey);
        Pdef(argKey, {arg monitor=true, fadeTime=0;
            key.asArray.do({arg val, i;
				var node = Ndef(val);
                if (node.rate == \audio) {
                    if (monitor.not){
                        // allow stoping the node
                        node.stop(fadeTime:fadeTime);
                    };
                    if (node.isMonitoring.not && monitor) {
                        node.play(fadeTime:fadeTime)
                    }
                };
			});
            Pbind(*props);
        });
	}
}

Q : EventPatternProxy {

    var <key;

	classvar <>all;

	storeArgs { ^[key] }

	*new {arg key ...pairs;
		var res = all.at(key);
		if(res.isNil) {
            var pbind = this.prBuild(key, pairs);
			res = super.new(pbind).prAdd(key);
		} {
			if(pairs.size > 0) {
                var pbind = this.prBuild(key, pairs);
                res.source = pbind
            }
		}
		^res
	}

    trig {
        ^Ndef((key ++ '_trig').asSymbol);
    }

    freq {
        ^Ndef((key ++ '_freq').asSymbol);
    }

    dur {
        ^Ndef((key ++ '_dur').asSymbol);
    }

    *prBuild {arg argKey, argPairs;
        var seqkey = (argKey ++ '_seq').asSymbol;

        "here".postln;
        Ndef(seqkey, {
            var trig = \trig.tr;
            var freq = \freq.kr;
            var dur = \dur.kr;
            [trig, freq, dur];
        });
        Ndef( (argKey ++ '_trig').asSymbol, { Ndef(seqkey).kr[0]});
        Ndef( (argKey ++ '_freq').asSymbol, { Ndef(seqkey).kr[1]});
        Ndef( (argKey ++ '_dur').asSymbol, { Ndef(seqkey).kr[2]});
        argPairs = argPairs ++ [\type, \set, \id, Pfunc({Ndef(seqkey).nodeID}), \trig, 1, \args, #[\trig, \freq, \dur]];
        ^Pdef(argKey, Pbind(*argPairs));
    }

    prAdd { arg argKey;
		key = argKey;
		all.put(argKey, this);
	}

    *initClass {
		all = IdentityDictionary.new;
    }
}