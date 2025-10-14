Tag {

    classvar <>tagDir;

    *all {
        var tags;
        tags = File.readAllString(tagDir ++ "/tags.scd");
        tags = tags.interpret;
        ^tags
    }

    *tag {|tags, val|

        var list;
        var file;
        var current = Tag.all;

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

        file = File.open(tagDir ++ "/tags.scd", "w");
        file.write(current.asCompileString);
        file.close;
        ^nil
    }

    *remove {|val|
        var file;
        var current = Tag.all;
        var keys = current.keys;
        keys.do({|key|
            var list = current[key];
            var index = list.indexOfEqual(val);
            if (index.notNil) {
                list.removeAt(index);
            };
        });

        file = File.open(tagDir ++ "/tags.scd", "w");
        file.write(current.asCompileString);
        file.close;  
    }
}
