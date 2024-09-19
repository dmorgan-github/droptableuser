
/*
x sequencable/modulatable from midi/osc
x sequencable/modulatable from patterns
x composable with patterns
x modulatable from bus
x viewable/modulatable with gui
savable
x playable with synthdef, vst, midi instruments
x filterable with sc fx
x filterable with vst fx
*/

// MidiInstrProxy {{{
MidiInstrProxy : InstrProxy {

    var <notechan=0, <returnbus=0, <midiout;
    var <>ctlNumMapping;

    *new {|device, chan|
        ^super.new().prInitMidiSynth(device, chan);
    }

    @ {|val, adverb|
        this.set(adverb, val)
    }

    set {|...args|
        var ctlNum;

        if (args[0].isArray) {
            args = args.flatten;
        };

        args.pairsDo({|k, v|
            //super.set(k, v);
            this.envir.put(k, v);
            if (this.ctlNumMapping.notNil ) {
                ctlNum = this.ctlNumMapping[k];
                if (ctlNum.notNil ) {
                    this.midiout.control(0, ctlNum: ctlNum, val: v)
                }; 
            }
        }); 

        this.changed(\set, args);
    }

    returnbus_ {|val|
        val = val.asArray;
        this.node.put(0, {
            var l = val.wrapAt(0);
            var r = val.wrapAt(1);
            SoundIn.ar([l, r])
        });
    }

    source_ {|pattern|

        if (pattern.isKindOf(Array)) {
            pattern = pattern.p
        };

       super.source = pattern;
    }

    instrument_ {|val|
        var path = "synth/%".format(val.toLower);
        if (M.exists(path)) {

            var module = M(path);
            if (module.notNil) {
                var mapping = module.value;
                ctlNumMapping = mapping;
                ctlNumMapping.keysValuesDo({|k, v|
                    var spec = ControlSpec(0, 127, \lin, 1, 0);
                    this.addSpec(k, spec);
                    this.envir.put(k, 0);
                });
            }
        } {
            "module does not exist: %".format(path).inform
        }
    }

    on {|note, vel=1|
        midiout.noteOn(notechan, note, vel)
    }

    off {|note|
        midiout.noteOff(notechan, note)
    }

    prInitMidiSynth {|device notechan|
        this.envir = ();
        //this.ctlNumMapping = ();
        MidiCtrl.connect(device, cb:{|obj|
            midiout = obj.out;
            this.set('type', 'midi', 'midicmd', 'noteOn', 'midiout', midiout, 'chan', notechan)
        });
    }
}
// }}}

// VstInstrProxy {{{
VstInstrProxy : InstrProxy {

    // the synth running on the server
    var <vstsynth;
    // the vst controller
    var <vstplugin;
    var <vstpreset;

    *new {|key|
        ^super.new(key);
    }

    source_ {|pattern|

        var src;

        if (pattern.isKindOf(Array)) {
            pattern = pattern.p
        };

        src = Pchain(
            pattern
        );

        super.source = src;
    }

    gui {
        vstplugin.editor;
    }

    on {|note, vel=127, extra|
        vstplugin.midi.noteOn(0, note, vel)
    }

    off {|note|
        vstplugin.midi.noteOff(0, note)
    }

    find {|str|
        var params = this.vstplugin.info.parameters;
        var vals = params.select({|p| p.name.asString.contains(str) });
        var result = List();
        vals.do({|v|
            var index = params.detectIndex({|p, i| p.name.asString.contains(v.name.asString) });
            var parm = params[index];
            result.add([index, parm]);
        });
        ^result.asArray
    }

    savePreset {|name|
        var path = Module.libraryDir +/+ "preset" +/+ name;
        vstplugin.writeProgram(path);
    }

    loadPreset {|name|
        var path = Module.libraryDir +/+ "preset" +/+ name;
        vstplugin.readProgram(path)
    }

    writeProgram {|filename|
        //var dir = Document.current.dir;
        //path = dir +/+ path;
        //vstplugin.writeProgram(path)
        var dir = PathName(thisProcess.nowExecutingPath).pathOnly;
        var path = dir +/+ filename;
        vstplugin.writeProgram(path)
    }

    readProgram {|filename|
        //var dir = Document.current.dir;
        //path = dir +/+ path;
        //vstplugin.readProgram(path)
        var dir = PathName(thisProcess.nowExecutingPath).pathOnly;
        var path = dir +/+ filename;
        vstplugin.readProgram(path)
    }

    prInitSynth {|argSynth|

        fork({

            var plugin;
            var args;

            args = argSynth.asString.split($/);
            plugin = args[0];
            if (args.size > 1){
                var path, dir;
                dir = PathName(thisProcess.nowExecutingPath).pathOnly;
                vstpreset = args[1];

                path = dir ++ vstpreset;
                if (File.exists(path).not) {
                    path = Module.libraryDir +/+ "preset" +/+ vstpreset;
                };

                if (File.exists(path)) {
                    vstpreset = path;
                } {
                    "preset does not exist: %".format(vstpreset).warn
                }
                
            };
            synthdef = SynthDescLib.global[\vsti].def;

            vstsynth = Synth(\vsti,
                args: [\out, this.node.bus.index],
                target: this.node.group.nodeID
            );

            // i can't find a better way, sync doesn't help in this scenario
            //1.wait;
            Server.default.latency.wait;
            vstplugin = VSTPluginController(vstsynth, synthDef:synthdef);
            vstplugin.open(plugin, editor: true, verbose:true, action:{|ctrl|
                if (vstpreset.notNil) {
                    vstpreset.debug("preset");
                    ctrl.readProgram(vstpreset)
                }
            });

            // need to specify which params will be modulated
            // \params, [\Mix, \Depth, 1]
            this.set('type', 'composite', 'types', [\vst_midi, \vst_set], 'vst', vstplugin)

        });
    }

    clear {
        this.vstplugin.close;
        this.vstsynth.free;
        super.clear;
    }

    *initClass {
        StartUp.add({
            SynthDef(\vsti, { |out| Out.ar(out, VSTPlugin.ar(Silent.ar(2), 2)) }).add;
        });
    }
}
// }}}

// InstrProxy {{{
InstrProxy : EventPatternProxy {

    classvar <>count=0;
    classvar <>colors;

    var <node, <cmdperiodfunc, <>color;
    var <>isMono=false, <instrument;
    var <isMonitoring, <nodewatcherfunc;
    var <metadata, <controlNames;
    var <synthdef;
    var <note, <msgFunc;
    var <key, <synthdefmodule;
    var specs;
    var <lfos;
    var defaultProtoEvent;

    *new {|key|
        ^super.new.prInit(key);
    }

    // synth
    <+ {|val|

        //var observer = InstrProxyObserver(this);        
        //val.keysValuesDo({|k, v|
        //    observer.evaluate(k, [v])
        //});

        synthdefmodule.evaluate(val);

        fork {
            synthdefmodule.add(key);
            Server.default.sync;
            // re-initialize the synth
            msgFunc = SynthDescLib.global[key].msgFunc;
            this.instrument = key;
            this.metadata.putAll(synthdefmodule.metadata);
        };
    }

    // fx inserts
    +> {|val, adverb|

        var offset = 20;
        if (adverb.notNil) {
            var index = offset + adverb.asInteger;
            this.fx(index, val); 
        }{
            if (val.isArray) {
                val.do({|v, i|
                    var index = offset + i;
                    this.fx(index, v);    
                })    
            }{
                this.fx(offset, val); 
            }
        }
    }

    // props
    @ {|val, adverb|
        if (adverb.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            this.set(adverb, val)
        }
    }

    // set fx props
    // TODO: not sure about this
    % {|val, adverb|

        if (val.isKindOf(Lfo)) {
            var mykey = "%_%_lfo".format(this.key, adverb).asSymbol;
            var nodes = val.value(mykey).first;
            lfos.put(mykey, nodes);
            this.node.set(adverb, nodes);
            {
                nodes.do({|n|
                    n.parentGroup = this.node.group    
                });
            }.defer(5)
        } {
            this.node.set(adverb, val);    
        }
    }

    // pattern
    << {|pattern, adverb|
        var num = 0;
        if (pattern.isArray) {
            var a;
            pattern.pairsDo {|k,v|
                a = a.add(k).add(v);
            };
            pattern = Pbind(*a);
        };
        //if (adverb.notNil) {
        //    num = adverb.asInteger;
        //};
        //this.ptrns.put(num, pattern);
        //patterns.clear;
        this.source = pattern;
    }

    proto {
        ^defaultProtoEvent;
    }

    proto_ {|val|
        defaultProtoEvent = val.debug("InstrProxy:proto");
        super.set(\proto, val);
    }

    set {|...args|

        var evt, nodeprops=[], synthprops=[];

        // does this impact performance?
        if (args[0].isArray) {
            args = args.flatten;
        };

        if (args[0].isKindOf(Environment)) {
            evt = args[0];
        }{
            evt = args.asEvent;
        };
        
        nodeprops = evt.use({ node.msgFunc.valueEnvir });
        synthprops = evt.use({ this.msgFunc.valueEnvir });

        if (nodeprops.size > 0) {
            var val = Array.new(nodeprops.size);
            nodeprops.keysValuesDo({|k, v|
                if (v.isNumber.or(v.isArray).or(v.isKindOf(NodeProxy)) ) {
                    val = val.add(k.asSymbol).add(v);
                } {
                    if (v.isNil) {
                        node.set(k, nil)
                    };
                }
            });
            if (val.size > 0) {
                node.set(*val)
            };
        };

        if (synthprops.size > 0) {
            var val = Array.new(synthprops.size);
            synthprops.keysValuesDo({|k, v|
                if (v.isNumber.or(v.isArray).or(v.isKindOf(NodeProxy))) {
                    val = val.add(k.asSymbol).add(v);
                } {
                    if (v.isNil) {
                        //node.group.set(k, nil)
                        node.setGroup([k, nil])
                    }
                }
            });
            if (val.size > 0) {
                //node.group.set(*synthprops)
                node.setGroup(synthprops)
            }
        };

        args.pairsDo({|k, v|
            // TODO: find a better way to do this
            if (v.isKindOf(Lfo)) {
                var mykey = "%_%_lfo".format(this.key, k).asSymbol;
                var nodes = v.value(mykey);
                lfos.put(mykey, nodes);

                super.set(k, nodes);
                {
                    nodes.do({|n|
                        n.parentGroup = this.node.group    
                    });
                }.defer(5)
            }{
                super.set(k, v);
            }
        });
    }

    instrument_ {|name|
        this.prInitSynth(name);
    }

    on {|midinote=60, vel=127, extra|
        note.on(midinote, vel, extra);
        this.changed(\noteOn, [midinote, vel, extra]);
        ^this;
    }

    off {|midinote=60|
        note.off(midinote);
        this.changed(\noteOff, [midinote]);
        ^this;
    }

    fx {|index, fx, cb|
        this.node.fx(index, fx, cb);
        ^this;
    }

    play {|argClock, protoEvent, quant, doReset=false, fadeTime=0|
        if (fadeTime > 0) {
            // node stop will force the output proxy to be freed and a new one created
            // when play is invoked - not sure this is a great way to do this
            node.stop(fadeTime:0).play(fadeTime:fadeTime);
        } {
            if (node.isMonitoring.not ) {
                node.play;
            };
        };
        if (protoEvent.isNil) { protoEvent = defaultProtoEvent};
        super.play(argClock, protoEvent:protoEvent, quant:quant, doReset:doReset)  ;
    }

    stop {|fadeTime=0|
        if (fadeTime > 0) {
            node.stop(fadeTime:fadeTime);
            {
                super.stop
            }.defer( fadeTime + 0.5 )
        } {
            super.stop
        }
    }

    clear {
        this.changed(\clear);
        "node.clear".debug("InstrProxy");
        node.clear;
        "note.clear".debug("InstrProxy");
        note.clear;
        "specs.clear".debug("InstrProxy");
        specs.clear;
        "envir.clear".debug("InstrProxy");
        envir.clear;
        "metadata.clear".debug("InstrProxy");
        metadata.clear;
        "remove cmdperiodfunc".debug("InstrProxy");
        ServerTree.remove(cmdperiodfunc);
        "releaseDependants".debug("InstrProxy");
        this.releaseDependants;
        "super.clear".debug("InstrProxy");
        super.clear;
        ^nil
    }

    controlKeys {|except|
        var keys = envir.keys(Array).sort;
        except = except ++ [];
        ^keys.reject({|key|
            except.includes(key)
        })
    }

    kill {|ids|
        ids.asArray.do({|id|
            Synth.basicNew(this.instrument, Server.default, id).free
        });
    }

    mute {|fadeTime=1|
        this.node.stop(fadeTime:fadeTime)
    }

    unmute {|fadeTime=1|
        this.node.play(fadeTime:fadeTime)
    }

    out {
        ^this.node.out
    }

    out_ {|bus=0|
        this.node.out = bus;
    }

    view {|cmds|
        // TODO: using topenvironment as a sort of cache
        //cmds = cmds ?? { "[(freq fx) props]" };
        ^UiModule('instr2').envir_(topEnvironment).view(this, nil, cmds);
    }

    gui {|cmds|
        this.view(cmds).front
    }

    printOn {|stream|
		super.printOn(stream);
		stream << " key:" << this.key << " out:" << this.out
	}

    stringify {
        var envir, keys, str = "\n";
        var node = this.node;
        envir = this.envir.copy.parent_(nil);
        keys = envir.keys.asArray.sort;

        node.fxchain.do({|obj, index|
            var prefix = "", fxname;
            var i = index - 20;
            if (obj.type == \vst) { prefix = "vst:" };
            fxname = obj.name.asString.split($.)[0];
            fxname = fxname.select({|val| val.isAlphaNum}).toLower;
            str = str ++ "fx%: '".format(i) ++ prefix ++ obj.name ++ "'";
            if (obj.params.notNil) {
                var names = obj.ctrl.info.parameters;
                //str = str ++ "~%.fxchain[%].ctrl.set(*[".format(this.key, i);
                obj.params.array.do({|val, i|
                    if (i > 0) {str = str + ","};
                    str = str ++ "'" ++ names[i].name ++ "', " ++ val.asCode;
                });
                str = str ++ "]);\n";
            };
            str = str + "\n";
        });

        //str = str + "\n";
        //str = str ++ "(\n~%".format(this.key) + "\n";
        keys.do({|k|
            var v = envir[k];
            var spec = this.getSpec[k];
            var default = if (spec.notNil) {spec.default}{nil};
            //[default, v, k, spec.default].debug("equal");
            if (v != default and: {  [\instrument, \bufposreplyid, \buf].includes(k).not }) {
                //str = str ++ ("@." ++ k);
                str = str ++ k ++ ":";
                str = str + v.asCode + "\n";
            }
        });

        envir = node.nodeMap;
        keys = envir.keys.asArray.sort;
        keys.do({|k|
            var v = envir[k];
            var spec = node.getSpec(k);
            var default = if (spec.notNil) {spec.default}{nil};
            if (v != default and: { [\i_out, \out, \fadeTime].includes(k).not } ) {
                //str = str ++ ("@." ++ k);
                str = str ++ k ++ ":";
                str = str + v.asCode + "\n";
            }
        });
        //str = str ++ ")";
        ^str;
    }

    clipboard {
        var str = this.stringify;
        "echo \"%\" | /usr/bin/pbcopy".format(str).unixCmd;
        "copied to clipboard".postln;
    }

    source_ {|pattern|
        var chain;
        pattern = pattern ?? { Pbind() };
        chain = Pchain(
            pattern,
            Pbind(
                \out, Pfunc({node.bus.index}),
                \group, Pfunc({node.group.nodeID}),
            )
        );
        super.source = if (isMono) { Pmono(instrument) <> chain <> Pbind(\trig, 1) }{ chain }
    }

    getSpec {
        ^specs;
    }

    addSpec {|...pairs|
        if (pairs.notNil) {
			pairs.pairsDo { |name, spec|
				if (spec.notNil) { spec = spec.asSpec };
                specs.put(name, spec)
			}
		};
    }

    prInitSynth {|synthname|

        instrument = synthname ?? { \default };
        synthdef = SynthDescLib.global.at(instrument);

        if (synthdef.isNil) {
            //"synth does not exist".debug(synth)
        } {

            synthdef
            .controls.reject({|cn|
                [\freq, \pitch, \trigger, \trig,
                    \in, \buf, \gate, \glide,
                    \bend, \out, \vel].includes(cn.name.asSymbol)
            }).do({|cn|
                var key = cn.name.asSymbol;
                var spec = Spec.specs[key];
                if (spec.notNil) {
                    this.addSpec(key, spec);
                }
            });

            metadata = synthdef.metadata ?? ();
            if (metadata[\specs].notNil) {
                metadata[\specs].keysValuesDo({|k, v|
                    this.addSpec(k, v);
                })
            };

            this.isMono = false;
            if (metadata['voices'] == \mono) {
                this.isMono = true;
            };

            //"set defaults from spec...".debug("ssynth");
            if (this.getSpec.notNil) {
                this.getSpec.keys.do({|key|
                    var spec = this.getSpec[key];
                    if (this.get(key).isNil) {
                        this.set(key, spec.default);
                    }
                });
            };

            controlNames = SynthDescLib.global.at(instrument).controlNames;
            this.set(\instrument, instrument);
        }
    }

    prInit {|argKey|

        var synthfunc;
        key = argKey;
        if (key.isNil) {
            key = "instr%".format(count).asSymbol;
        };

        if (count > colors.size) {
            color = Color.rand;
        }{
            color = colors.wrapAt(count);
        };
        count = count + 1;
        node = InstrNodeProxy("%/node".format(key).asSymbol);

        specs = ();
        lfos = Dictionary();
        //ptrns = Order();
        //patterns = ();
        note = InstrProxyNotePlayer(this);
        synthdefmodule = SynthDefModule();

        nodewatcherfunc = {|obj, what|
            if ((what == \play) or: (what == \stop)) {
                isMonitoring = obj.isMonitoring
            }
        };
        node.addDependant(nodewatcherfunc);

        node.play;
        super.source = Pbind();

        cmdperiodfunc = {
            {
                node.wakeUp;
                if (isMonitoring) {
                    node.play
                };
            }.defer(0.5)
        };

        node.color = color;
        ServerTree.add(cmdperiodfunc);
        ^this
    }

    *initClass {
        colors = List();
    }
}
// }}}







