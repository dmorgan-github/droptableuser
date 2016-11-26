App : IdentityDictionary {

	var < bufs;

	classvar <>all;

	*initClass {
		all = IdentityDictionary.new;
	}

	*new {arg key, server = Server.default;

		var res = all.at(key);

		if (res.isNil) {
			res = super.new(know:true).prInit(key, server);
		};

		^res;
	}

	*monoDevice {arg synth, node = nil;

		var obj = IdentityDictionary.new(know: true);

		var id = (synth ++ '_' ++ obj.identityHash.abs).asSymbol;

		var pattern = PbindProxy.new(\trig, 1, \amp, 0.1);

		var myNode = node ? NodeProxy.new(
			server: Server.default,
			rate: \audio,
			numChannels: 2);

		var player = DevicePatternProxy.new(
		    Pproto({
				myNode.rebuild.play(fadeTime:myNode.fadeTime);
				~group = myNode.group;
				~out = myNode.bus;
				[id, ~group, ~out].debug("playing mono device");

			}, Pchain(Pmono(synth), pattern))
		);

		var kill = {arg self, fadeTime;

			var myFadeTime = fadeTime ? myNode.fadeTime;

			id.debug("kill");
			myNode.clear(myFadeTime);

			{
				player.stop;
				id.debug("player stopped");

			}.defer(myFadeTime + 0.01);
		};

		player.addDependant({arg target, key;
			key.debug("player event");
			obj.changed(key, \player, id, target);
		});

		myNode.addDependant({arg target, key;
			key.debug("node event");
			obj.changed(key, \node, id, target);
		});

		pattern.addDependant({arg target, key;
			key.debug("pattern event");
			obj.changed(key, \pattern, id, target);
		});

		obj.put(\snth, synth);
		obj.put(\pattern, pattern);
		obj.put(\node, myNode);
		obj.put(\player, player);
		obj.put(\kill, kill);
		obj.put(\id, id);
		^obj;
	}

	*polyDevice {arg synth, node = nil;

		var pattern = PbindProxy.new(\instrument, synth, \amp, 0.1);//.quant_(quant);

		var myNode = node ? NodeProxy.new(
			server: Server.default,
			rate: \audio,
			numChannels: 2);

		var player = EventPatternProxy.new(
			Pproto({
				synth.debug("playing poly device");
				myNode.rebuild.play(fadeTime:myNode.fadeTime);
				~group = myNode.group;
				~out = myNode.bus;
			}, pattern)
		);

		var obj = IdentityDictionary.new(know: true);

		myNode.addDependant({arg obj, key;
			if (key == \stop) {
				synth.debug("stop");
			};
			if (key == \play) {
				synth.debug("play");
			}
		});

		obj.put(\pattern, pattern);
		obj.put(\node, myNode);
		obj.put(\player, player);
		^obj;
	}

	*envControl {arg key, levels, times, curves, gate, releaseNode = nil, timeScale = 1, levelScale = 1;

		var num = 1e-6;
		var timeScaleKey = (key ++ 'timeScale').asSymbol;
		var levelScaleKey = (key ++ 'levelScale').asSymbol;

		var gateCtrl = {

			var rtn = gate;
			if (rtn.isNil) {
				var name = (key ++ 'gate').asSymbol;
				rtn = NamedControl.kr(name, 1);
			};
			rtn;

		}.value;

		levels = [levels[0]] ++ levels.collect({arg val, i;
			var num = i + 1;
			var name = (key ++ 'level' ++ num).asSymbol;
			NamedControl.kr(name, val);
		});

		times = [num] ++ times.collect({arg val, i;
			var num = i + 1;
			var name = (key ++ 'time' ++ num).asSymbol;
			NamedControl.kr(name, val);
		});

		curves = [curves[0]] ++ curves.collect({arg val, i;
			var num = i + 1;
			var name = (key ++ 'curve' ++ num).asSymbol;
			NamedControl.kr(name, val);
		});

		timeScale = if (timeScale.isNumber) {NamedControl.kr(timeScaleKey, timeScale)} {timeScale};
		levelScale = if (levelScale.isNumber) {NamedControl.kr(levelScaleKey, levelScale)} {levelScale}

		^EnvGen.ar(Env(levels, times, curves, releaseNode),
			gate: gateCtrl,
			levelScale: levelScale,
			timeScale: timeScale
		);
	}

	*envPerc {arg trig = 1, doneAction = 0;

		var env = EnvGen.ar(Env([0,0,1,0],
			[1e-6, \atk.kr(0.01), \rel.kr(0.99)],
			curve: [\curve.kr(-4)]
		), gate: trig, levelScale: \amp.kr(0.1), timeScale: \sustain.kr(1), doneAction: doneAction );

		^env;
	}

	*envAsr {arg trig = 1, doneAction = 0;

		var env = EnvGen.ar(Env([0,0,1,0.7,0],
			[1e-6, \atk.kr(0.01), \sus.kr(1), \rel.kr(1)],
			curve: [\curve1.kr(-4), \curve2.kr(-4)]
		), gate: trig, levelScale: \amp.kr(0.1), timeScale: \sustain.kr(1), doneAction: doneAction );

		^env;
	}

	*defaultOut {arg server;

		server.options.numOutputBusChannels = 2;
		server.options.outDevice_("Built-in Output");
		server.options.inDevice_("Built-in Microph");
		server.reboot;
	}

	*soundflowerOut {arg server, numOutputBusChannels = 16;

		// check volume control in task bar
		// check volume in midi
		// check volume in sound preferences
		server.options.numOutputBusChannels = numOutputBusChannels;
		server.options.inDevice_("Built-in Microph");
		server.options.outDevice_("Soundflower (64ch)");
		server.reboot;
	}

	*nodeTree {

		var interval = 0.3;
		var onClose;
		var window = Window.new("Node Tree", Rect(128, 64, 250, 300), scroll:true).alwaysOnTop_(true).front;
		window.view.hasHorizontalScroller_(false).background_(Color.gray(0.9)).alpha_(0.8);
		onClose = Server.default.plotTreeView(interval, window.view, { defer {window.close}; });
		window.onClose = {
			onClose.value;
		};
	}

	*serverMeter {

		Server.default.meter.window.alwaysOnTop_(true).alpha_(0.8);
		/*
		var numIns = 2, numOuts = 8;
		var window = Window.new(Server.default.name ++ " levels (dBFS)",
			Rect(5, 305, ServerMeterView.getWidth(numIns, numOuts), ServerMeterView.height),
			false);

		var meterView = ServerMeterView(Server.default, window, 0@0, numIns, numOuts);
		meterView.view.keyDownAction_( { arg view, char, modifiers;
			if(modifiers & 16515072 == 0) {
				case
				{char === 27.asAscii } { window.close };
			};
		});

		window.front;

		*/
	}

	*scope {

		var scope;
		var win = Window.new("Scope", Rect(20, 20, 263, 263)).alwaysOnTop_(true).alpha_(0.8);
		win.view.decorator = FlowLayout(win.view.bounds);
		scope = Stethoscope.new(Server.default, view:win.view);
		win.onClose = { scope.free }; // don't forget this
		win.front;
	}

	*freqScope {
		FreqScope.new(400, 250, 0, server: Server.default).window.alwaysOnTop_(true).alpha_(0.8);
	}

	prInit{arg prKey, server;

		bufs = BufEnvir(server);
		all.put(prKey, this);
		^this;
	}
}


// this isn't meant to be used directly
DevicePatternProxy : EventPatternProxy {

	play {arg argClock, protoEvent, quant, doReset=false;

		// if stop is called the player will be destroyed
		var hasPlayer = player.isNil.not;

		super.play(argClock, protoEvent, quant, doReset);

		// if a player already exists assume we have previously
		// added the event listener and won't re-add it
		if (hasPlayer.not) {
			player.addDependant({arg obj, key;
				this.changed(key);
			});
		}
	}
}
