T : Track {}

Track {

    classvar <>mod;

    *instr {|key, cb ...pairs|
        var builder, result;
        var proxy = currentEnvironment[key];
        builder = InstrProxyBuilder(proxy, key);
        result = cb.value(builder);
        currentEnvironment[key] = result.proxy;
        if (pairs.debug("pairs").notNil) {
            result.proxy.synthdefmodule.set(*pairs);
        };
        ^currentEnvironment[key]
    }

    *vst {|key, name|
        var proxy = VstInstrProxy(key).instrument_(name);
        currentEnvironment[key] = proxy;
        ^currentEnvironment[key];
    }

    *midi {|key, device, chan|
        var proxy = MidiInstrProxy(device, chan);
        currentEnvironment[key] = proxy;
        ^currentEnvironment[key];
    }

    *sig {|id, func|
        InstrProxyBuilder.sig.put(id, func);    
    }

    *fil {|id, func|
        InstrProxyBuilder.fil.put(id, func);
    }

    *lfo {
        if (mod.isNil) {
            mod = Module('device/lfo').();
        };
        ^mod;
    }
}

