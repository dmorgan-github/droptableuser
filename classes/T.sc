T {

    *all {
        var tags;
        tags = File.readAllString(Module.libraryDir ++ "tag/tags.scd");
        tags = tags.interpret;
        ^tags
    }

    *tag {|tags, val|

        var list;
        var file;
        var current = T.all();

        if (tags.isString) {
            tags = tags.asSymbol;
        };
        tags.asArray.do({|tag|
            var list;
            var key = tag.asSymbol;
            list = current[key];
            if (list.isNil) {
                list = Set.new;
                current[key] = list;
            } {
                list = list.asSet;
            };
            list.add(val);
            current[key] = list.asArray;
        });

        file = File.open(Module.libraryDir ++ "tag/tags.scd", "w");
        file.write(current.asCompileString);
        file.close;
        ^nil
    }
}
