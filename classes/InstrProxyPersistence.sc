InstrProxyPersistance {

    var <instrProxy;
    var prPath;

    *new {|instrProxy|
        ^super.new.prInit(instrProxy);
    }

    save {|version=false|

        var pn, pathOnly, fileName;
        pn = PathName(this.path);
        pathOnly = pn.pathOnly;

        if (version) {
            var dte = Date().asSortableString;
            fileName = "%_%".format(pn.fileNameWithoutExtension, dte);
        }{
            fileName = pn.fileNameWithoutExtension;
        };
            
        if (instrProxy.isKindOf(VstInstrProxy)) {
            fileName = "%.%".format(fileName, "vstpreset");
            this.path = "%%".format(pathOnly, fileName).debug("InstrProxyPersistance.save");
            instrProxy.vstplugin.writeProgram(this.path);    
        } {
            var str;
            fileName = "%.%".format(fileName, "scd");
            this.path = "%%".format(pathOnly, fileName).debug("InstrProxyPersistance.save");
            str = instrProxy.stringify;
            if (str.size > 0) {
                File.use(this.path, "w", { |f|
                    f.write(str);
                })
            };
        };

        instrProxy.changed(\save)
    }

    path {

        if (prPath.isNil) {
            prPath = "%.%-%_data.scd".format( 
                PathName(thisProcess.nowExecutingPath).pathOnly, 
                instrProxy.key.asString.select({|val| val.isAlphaNum}),
                instrProxy.instrument.asString.select({|val| val.isAlphaNum})
            ).debug("path");
        };

        ^prPath;
    }

    path_ {|val|
        prPath = val;    
    }

    load {|filePath|

        if (filePath.notNil) {
            this.path = filePath;
        };
        if ( File.exists(this.path).not) {
            this.path = "%/%".format(PathName(thisProcess.nowExecutingPath).pathOnly, this.path);
        };
        this.path.debug("InstrProxyPersistance.load");
        if (instrProxy.isKindOf(VstInstrProxy)) {
            var pn = PathName(this.path);
            var pathOnly = pn.pathOnly;
            var fileName = pn.fileNameWithoutExtension;
            fileName = "%.%".format(fileName, "vstpreset");
            this.path = "%%".format(pathOnly, fileName);
            instrProxy.vstplugin.readProgram(this.path);
        }{
            var data;
            data = this.path.load;
            instrProxy.set(*data);
        }
    }

    prInit {|argInstrProxy|

        var key, instrument;
        instrProxy =  argInstrProxy; 
        key = instrProxy.key;
        
        // is this a good idea?
        instrProxy.addUniqueMethod(\save, {|self, version=false|
            this.save(version)
        });

        instrProxy.addUniqueMethod(\load, {|self, path|
            this.load(path)
        });
    }

}