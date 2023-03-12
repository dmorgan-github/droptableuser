(
func: {|node|

    var paths;
    var path = Module.libraryDir ++ "fx/";
    var fxmenu, browse;
    var vstlist = Halo.at(\vstlist);

    var vsts = {
        if (vstlist.isNil) {
            // get the unique list of plugins
            // prefering vst3 if vst2 version also exists
            var plugins = ();
            var list = V
            .ls
            .reject({arg val;
                var plugin = VSTPlugin.plugins[val.asSymbol];
                plugin.isNil
                or: {
                    VSTPlugin.plugins[val.asSymbol].category.contains("Instrument")
                }
                or: {
                    VSTPlugin.plugins[val.asSymbol].category.contains("Synth")
                }
            });

            list.do({|name|
                var noext;
                name = name.asString;
                noext = name.split($.)[0].asSymbol;
                if (plugins[noext].isNil) {
                    plugins.put(noext, 0);
                };
                if (name.endsWith("vst3")) {
                    plugins[noext] = 1
                };
            });

            vstlist = plugins.keys
            .collect({|item| if (plugins[item] == 1) { "%.vst3".format(item).asSymbol }{item} })
            .asArray
            .sort;

            Halo.put(\vstlist, vstlist)
        };

        vstlist
    };

    browse = {arg path, files=List.new;
        var folder = PathName.new(path);
        if (folder.isFolder) {
            var folders = folder.folders;
            files = files.addAll(folder.files);
            folders.do({arg folder;
                browse.(folder.fullPath, files);
            });
        };
        files;
    };


    paths = browse.(path);

    StaticText().string_("...")
    .setContextMenuActions(
        *(
            paths.collect({arg path;
                var name = path.folderName ++ '/' ++ path.fileNameWithoutExtension;
                MenuAction( name, {arg action, what, value;

                    var id = action.string.asSymbol;
                    var maxindex;

                    maxindex = node.objects.indices
                    .reject({|val| val < 100 or: {val >= 1000} }).maxItem ?? {100};

                    node.fx(maxindex + 10, id);
                });
            })
            ++ vsts.().collect({arg vst;
                MenuAction(vst, {arg action;

                    var id = "vst:%".format(action.string).asSymbol;
                    var maxindex;

                    maxindex = node.objects.indices
                    .reject({|val| val < 100 or: {val >= 1000} }).maxItem ?? {100};

                    node.fx(maxindex + 10, id);
                })
            })
        )
    );
}
)
