
(
func: {|node, index|

    var currentcmd;
    var fxnode = node.node;
    var windowname = if (index.notNil) {
        "%/%".format(node.key, fxnode.fxchain[index].name);
    }{
        node.key
    };
    var view, target, props, scope;

    props = Ui('props').view(node, index);
    target = View().layout_(VLayout().margins_(0).spacing_(0));

    if (index.isNil) {
        scope = Ui('meter').view(fxnode);
        target.layout.add(scope);
    };

    view = View(bounds:75@150)
    .name_(windowname)
    .layout_(VLayout(
        HLayout(
            props.minWidth_(175).background_(Color.black),
            target
        ).margins_(5).spacing_(5),

        TextField()
        .keyDownAction_({|ctrl, char, mod, unicode, keycode, key|
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
                currentcmd = val;
                switch (currentcmd,
                    \scope, {
                        target.children.do({|child|
                            child.remove
                        });
                        target.layout.add(Ui(\scope).view(fxnode))
                    },
                    \freq, {
                        target.children.do({|child|
                            child.remove
                        });
                        target.layout.add(Ui(\freqscope).view(fxnode))
                    },
                    \buf, {
                        target.children.do({|child|
                            child.remove
                        });
                        target.layout.add(Ui(\buf).view(node))
                    },
                    \aeg, {
                        target.children.do({|child|
                            child.remove
                        });
                        target.layout.add(Ui(\aeg).view(node))
                    },
                    \fx, {
                        target.children.do({|child|
                            child.remove
                        });
                        target.layout.add(Ui(\fx).view(node))
                    },
                    \grain, {
                        target.children.do({|child|
                            child.remove
                        });
                        target.layout.add(Ui(\grainsliders).view(node));
                    },
                    \tgrid, {
                        target.children.do({|child|
                            child.remove
                        });
                        target.layout.add(Ui(\tgrid).view(node));
                    },
                    \meter, {
                        target.children.do({|child|
                            child.remove
                        });
                        target.layout.add(Ui(\meter).view(fxnode));
                    },
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
                        //if (cmd.beginsWith("fx")) {
                        //    var vals = cmd.split(Char.space);
                        //    var num = vals[1].asInteger;
                        //    node.fxchain[num].ui
                        //};
                        if (cmd.beginsWith("@")) {
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
                        }
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
