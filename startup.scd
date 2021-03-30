(
thisProcess.platform.recordingsDir_(App.workspacedir.standardizePath);

s.options.memSize_(2 ** 18);
s.options.numAudioBusChannels = 1024 * 2;
s.options.numWireBufs = 2 ** 7;

// for superdirt
s.options.numBuffers = 1024 * 16;

"LADSPA_PATH".setenv("/Applications/LMMS.app/Contents/lib/lmms/ladspa");
//LADSPA.listPlugins;  //should post a long list of plugins

Font.setDefault(Font("Courier New", 10));

s.options.numOutputBusChannels = 8;
s.options.inDevice_("supercollider-in");
s.options.outDevice_("supercollider-out");

//s.options.numOutputBusChannels = 8;
//s.options.numInputBusChannels = 8;
//s.options.inDevice_("device1");
//s.options.outDevice_("device1");

s.recHeaderFormat = "WAV";

s.waitForBoot({

	MIDIClient.init;
	MIDIClient.initialized.debug("midi initialized");
	Pdef.defaultQuant_(1);

	t = t ?? { LinkClock.new.latency_(s.latency).permanent_(true) };

	{
		var func = {arg code;
			if (code == "scid") {
				//var id = ("\\" ++ App.idgen).asSymbol;
				var id = (App.idgen).asSymbol;
				code = code.replace("scid", id);
				Document.current.selectedString_(id);
			};
			code;
		};
		this.preProcessor = func;
	}.();

    /*
    "add custom events".debug(\startup);

    Event.addEventType(\note,
        Event.eventTypes[\note].addFunc({
            if (~ndef.isNil.not) {
                var node = Ndef(~ndef);
                var keys = node.controlKeys.select({|key| currentEnvironment.keys.includes(key) });
                if (keys.size > 0) {
                    currentEnvironment.copy.use {
                        ~id = ~group;
                        ~args = keys;
                        Event.eventTypes[\set].value(Server.default);
                    };
                }
            }
        }),
        ()
    );

    Event.addEventType(\monoNote,
        Event.eventTypes[\monoNote].addFunc({
            if (~ndef.isNil.not) {
                var node = Ndef(~ndef);
                var keys = node.controlKeys.select({|key| currentEnvironment.keys.includes(key) });
                if (keys.size > 0) {
                    currentEnvironment.copy.use {
                        ~id = ~group;
                        ~args = keys;
                        Event.eventTypes[\set].value(Server.default);
                    };
                }
            }
        }),
        ()
    );

    Event.addEventType(\monoSet,
        Event.eventTypes[\monoSet].addFunc({
            if (~ndef.isNil.not) {
                var node = Ndef(~ndef);
                var keys = node.controlKeys.select({|key| currentEnvironment.keys.includes(key) });
                if (keys.size > 0) {
                    currentEnvironment.copy.use {
                        ~id = ~group;
                        ~args = keys;
                        Event.eventTypes[\set].value(Server.default);
                    };
                }
            }
        }),
        ()
    );
    */

	Spec.add(\cutoff, ControlSpec(20, 20000, 'exp', 0, 100, units:"filter"));
	Spec.add(\hpf, ControlSpec(20, 20000, 'exp', 0, 20, units:"filter"));
	Spec.add(\lpf, ControlSpec(20, 20000, 'exp', 0, 20000, units:"filter"));
	Spec.add(\res, ControlSpec(0, 1, \lin, 0, 0.5, units:"filter"));
	Spec.add(\fvel, ControlSpec(0.001, 20, \lin, 0, 10, units:"filter"));
	Spec.add(\fatk, ControlSpec(0, 1, \lin, 0, 0.01, units:"filter"));
	Spec.add(\frel, ControlSpec(0, 8, \lin, 0, 0.29, units:"filter"));
	Spec.add(\fsuslevel, ControlSpec(0, 1, \lin, 0, 1, units:"filter"));
	Spec.add(\fcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"filter"));

	Spec.add(\start, ControlSpec(0, 1, \lin, 0, 0, units:"buf"));
	Spec.add(\rate, ControlSpec(0.1, 4.0, \lin, 0, 1, units:"buf"));

	Spec.add(\atk, ControlSpec(0, 1, \lin, 0, 0.01, units:"aeg"));
	Spec.add(\dec, ControlSpec(0, 1, \lin, 0, 0.2, units:"aeg"));
	Spec.add(\rel, ControlSpec(0, 8, \lin, 0, 0.29, units:"aeg"));
	Spec.add(\suslevel, ControlSpec(0, 1, \lin, 0, 1, units:"aeg"));
	Spec.add(\curve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\atkcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\deccurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\relcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\ts, ControlSpec(0.001, 100, \lin, 0, 1, units:"aeg"));

	Spec.add(\detunehz, ControlSpec(0, 10, \lin, 0, 0, units:"freq"));
	Spec.add(\bend, ControlSpec(-12, 12, \lin, 0, 0, units:"freq"));
	Spec.add(\vrate, ControlSpec(0, 440, \lin, 0, 6, units:"freq"));
	Spec.add(\vdepth, ControlSpec(0, 0.5, \lin, 0, 0, units:"freq"));
	Spec.add(\spread, ControlSpec(0, 1, \lin, 0, 1, units:"stereo"));
	Spec.add(\center, ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"));
	Spec.add(\pan, ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"));
	Spec.add(\vel, ControlSpec(0, 1, \lin, 0, 1, units:"vol"));
	Spec.add(\drive, ControlSpec(1, 100, \lin, 0, 1, units:"vol"));
	Spec.add(\amp, ControlSpec(0, 1, \lin, 0, -10.dbamp, units:"vol"));

    VSTPlugin.search;
})
)