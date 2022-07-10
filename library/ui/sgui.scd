
(
func: {|node, index|

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
        scope = Ui('scope').view(fxnode);
        target.layout.add(scope);
    };

    view = View(bounds:475@250)
    .name_(windowname)
    .layout_(VLayout(
            HLayout(
                props.minWidth_(235).background_(Color.black),
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
                    switch (val, 
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
                        \close, {
                            target.children.do({|child|
                                child.remove
                            });
                        },
                        {
                            var cmd = val.asString;
                            cmd.postln;
                            if (cmd.beginsWith("fx")) {
                                var vals = cmd.split(Char.space);
                                var num = vals[1].asInteger;
                                node.fxchain[num].ui
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
