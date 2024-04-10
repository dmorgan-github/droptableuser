InstrProxyObserver {

    var <synthdefmodule;
    var <proxy;

    *new {|proxy|
        ^super.new.prInit(proxy);    
    }

    evaluate {|role, args|

        var myrole = role.asString;
        if ( "^(sig)([0-9]*)$|^(fil)$|^(aeg)$|^(fx)([0-9]*)$|^(voices)$".matchRegexp(myrole) ) {

            var module = args[0];
            var result, index = 0;

            result = myrole.findRegexp("^(sig)([0-9]*)$");
            if (result.size > 0) {
                index = if (result[2].size > 1) { result[2][1].asInteger };
                if (module.isNil) {
                    "removing sig".debug("InstrProxyObserver");
                    synthdefmodule.removeAt(index)
                }{
                    if (module.isKindOf(Function)) {
                        module = Module(module)
                    };
                    synthdefmodule.put(index, \sig -> module);  
                }
                
            };

            result = myrole.findRegexp("^aeg$");
            if (result.size > 0) {
                if (module.isNil) {
                    "removing aeg".debug("InstrProxyObserver");
                    synthdefmodule.removeAt(10)
                }{
                    if (module.isKindOf(Function)) {
                        module = Module(module)
                    };
                    synthdefmodule.put(10, \env -> module);  
                }
            };

            result = myrole.findRegexp("^fil$");
            if (result.size > 0) {
                if (module.isNil) {
                    "removing filter".debug("InstrProxyObserver");
                    synthdefmodule.removeAt(20)
                }{
                    if (module.isKindOf(Function)) {
                        module = Module(module)
                    };
                    synthdefmodule.put(20, \fil -> module);  
                }
            };

            result = myrole.findRegexp("^pit$");
            if (result.size > 0) {
                if (module.isNil) {
                    "removing pitch model".debug("InstrProxyObserver");
                    synthdefmodule.removeAt(30)
                }{
                    if (module.isKindOf(Function)) {
                        module = Module(module)
                    };
                    synthdefmodule.put(30, \pit -> module);  
                }
            };

            result = myrole.findRegexp("^voices$");
            if (result.size > 0) {
                if (module.isKindOf(Function)) {
                    module = Module(module)
                };
                synthdefmodule.set(\voices, module)
            };

            result = myrole.findRegexp("^(fx)([0-9]*)$");
            if (result.size > 0) {
                index = if (result[2].size > 1) { result[2][1].asInteger };
                index = 20 + index;
                if (module.isKindOf(Module)) {
                    module = module.func;
                }{
                    if (module.isKindOf(Function)) {
                        //module = Module(module)
                        // pass function
                    } {
                        module = module.asSymbol;
                    }
                };
                proxy.node.fx(index, module);
            };

            ^true;
        } {
            ^false;
        }
    }

    prInit {|instrproxy|
        proxy =  instrproxy;
        synthdefmodule = proxy.synthdefmodule;  
    }

}




// InstrProxyBuilder {{{
InstrProxyBuilder {

    classvar <fx;
    classvar <sig, <fil;

    var <synthdefmodule;
    var <proxy;   
    var current, currentargs;
    var num = 0, fxnum = 20;

    *new {|instrproxy, key|
        ^super.new.prInit(instrproxy, key)
    }

    value {|func|
        var mod;
        mod = Module(func);
        // TODO: this needs to work with any role
        this.prAddModule('sig', mod);
        ^this;
    }

    // TODO: relying on this is not particularly robust
    doesNotUnderstand {|selector ...args|
        var mod, key; 
        //selector.debug("selector");
        if (synthdefmodule.modules.size == 0) {
            if (sig[selector].notNil) {
                mod = Module(sig[selector])
            } {
                key = "synth/%".format(selector).asSymbol;
                mod = Module(key);
            };
            this.prAddModule('sig', mod, args);
        } {
            current.add(selector);
            currentargs.add(args);
        };
        ^this;
    }

    // osc
    + {|module|
        var id = current.pop;
        var args = currentargs.pop;
        var mod;
        if (sig[id].notNil) {
            mod = Module(sig[id])
        } {
            var key = "synth/%".format(id).asSymbol;
            mod = Module(key);
        };
        this.prAddModule('sig', mod, args);
        ^this;
    }

    // amp
    * {|module|
        var id = current.pop;
        var args = currentargs.pop;
        var key = "env/%".format(id).asSymbol;
        var mod = Module(key);
        this.prAddModule('env', mod, args);
        ^this;
    }

    // filter
    > {|module|
        var id = current.pop;
        var args = currentargs.pop;
        var mod;
        if (fil[id].notNil) {
            mod = Module(fil[id])
        } {
            var key = "filter/%".format(id).asSymbol;
            mod = Module(key);
        };
        this.prAddModule('fil', mod, args);
        ^this;
    }

    // pitch
    @ {|module|
        var id = current.pop;
        var args = currentargs.pop;
        var mod;
        if (fil[id].notNil) {
            mod = Module(fil[id])
        } {
            var key = "pitch/%".format(id).asSymbol;
            mod = Module(key);
        };
        this.prAddModule('pit', mod, args);
        ^this;
    }

    // fx insert
    | {|module|
        var id, key, func, args;
        id = current.pop;
        args = currentargs.pop;
        func = fx[id];
        proxy.node.fx(fxnum, func);
        fxnum = fxnum + 1;
        ^this;
    }

    prAddModule {|role, mod, args|
        if (args.notNil) {
            args.pairsDo({|k, v|
                mod.set(k.asSymbol, v)
            })
           // mod.set(*args)//debug("args")
        };
        synthdefmodule.put(num, role -> mod);
        num = num + 1;
    }

    prInit {|instrproxy, key|
        current = List();
        currentargs = List();
        proxy = instrproxy ?? InstrProxy(key);
        synthdefmodule = proxy.synthdefmodule;
        synthdefmodule.modules.clear;
    }

    *initClass {
        fx = Dictionary();
        fx['del'] = 'delay/fb';
        fx['rev'] = 'reverb/miverb';
        fx['ps'] = 'granular/pitchshift';
        fx['compress'] = 'dynamics/softkneecompressor';
        fx['eq'] = 'eq/eq';
        fx['dist'] = 'distortion/softclip';
        fx['crush'] = 'distortion/crush';
        fx['spiralstretch'] = 'vst:++spiralstretch.vst3';
        fx['bubbler'] = 'vst:++bubbler.vst3';
        fx['lofi'] = 'vst:CHOWTapeModel.vst3';

        sig = Dictionary();
        fil = Dictionary();
    }
}
// }}}