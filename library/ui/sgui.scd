
(
func: {|node, index|

    var cmdhistory = List.new;
    var currentindex = 0;
    var currentcmd;
    var fxnode = node.node;
    var windowname = if (index.notNil) {
        "%/%".format(node.key, fxnode.fxchain[index].name);
    }{
        node.key
    };
    var view, target, props, scope;
    var getView;

    props = Ui('props').view(node, index);
    target = View().layout_(VLayout().margins_(0).spacing_(0));

    if (index.isNil) {
        scope = Ui('meter').view(fxnode);
        target.layout.add(scope);
    };

    getView = {|currentcmd|
        switch (currentcmd,
            \freq, {
                Ui(\freqscope).view(node)
            },
            \grain, {
                Ui(\grainsliders).view(node)
            },
            {
                Ui(currentcmd).view(node)
            }
        );
    };


    view = View(bounds:75@150)
    .name_(windowname)
    .layout_(VLayout(
        HLayout(
            props.fixedWidth_(175).background_(Color.black),
            target
        ).margins_(5).spacing_(5),

        TextField()
        .keyDownAction_({|ctrl, char, mod, unicode, keycode, key|

            // 16777235 up
            // 16777237

            if (keycode == 126) {
                var cmd = cmdhistory.wrapAt(currentindex);
                ctrl.value = cmd;
                currentindex = (currentindex - 1).clip(0, cmdhistory.size);
            };

            if (keycode == 125) {
                var cmd = cmdhistory.wrapAt(currentindex);
                ctrl.value = cmd;
                currentindex = (currentindex + 1).clip(0, cmdhistory.size);
            };

            if (keycode == 36) {
                //[ctrl, char, mod, unicode, keycode, key].postln;
                //var args = "[" ++ ctrl.value ++ "]";
                // it seems we need asCompileString to handle symbols
                // and then we need to do interpret twice since
                // the first call returns a string when needs
                // to be interpreted as an array.
                //args = args.asCompileString.interpret.interpret;
                //args.postln;
                //node.set(*args)
                var val = ctrl.value.asSymbol;
                var view;
                currentcmd = val;

                cmdhistory.add(currentcmd);
                currentindex = cmdhistory.size -1;

                switch (currentcmd,
                    \play, {
                        node.play
                    },
                    \stop, {
                        node.stop
                    },
                    \mute, {
                        fxnode.stop
                    },
                    \unmute, {
                        fxnode.play
                    },
                    \close, {
                        target.children.do({|child|
                            child.remove
                        });
                    },
                    {
                        var cmd = val.asString;
                        cmd.postln;

                        case(

                            {cmd.beginsWith("@")}, {
                                var parts = cmd.split(Char.space);
                                var lhs = parts[0];
                                var rhs = parts[1..].join("");
                                var lhsparts = lhs.split($.);
                                var prop = lhsparts[1];
                                if (rhs.isNil or: {rhs == ""}) {
                                    var val = node.get(prop.asSymbol);
                                    ctrl.value = "@.% %".format(prop, val);
                                } {
                                    node.set(prop.asSymbol, rhs.interpret);
                                }
                            },

                            {cmd.beginsWith("split")}, {

                                var parts = cmd.split(Char.space);
                                var lhs = parts[0];
                                var rhs = parts[1..].join("");
                                var vals = rhs.interpret;

                                if (lhs == "split-v") {

                                    target.children.do({|child|
                                        child.remove
                                    });
                                    vals.do({|val|
                                        var view = getView.(val);
                                        target.layout.add(view);
                                    })
                                } {
                                    if (lhs == "split-h") {

                                    }
                                }

                            }, {
                                target.children.do({|child|
                                    child.remove
                                });
                                target.layout.add( getView.(currentcmd) )
                            }
                        );
                    }
                );
            }
        }).background_(Color.clear)
    ).margins_(0).spacing_(0)
    )
    .background_(Color.black);

    view;
}
)
