// note: good reference: https://github.com/rabitt/pysox/blob/master/sox/transform.py
Sox {

    var <list;

    *new {
        ^super.new.prInit;
    }

    remix {|left, right|
        list.addAll(["remix", left, right])
    }

    norm {|level=(-6)|
        list.addAll(["norm", level])
    }

    silence {|thresh=0.1|
        list.addAll(["silence", "1", thresh, "-50d"]);
        list.add("reverse");
        list.addAll(["silence", "1", thresh, "-50d"]);
        list.add("reverse")
    }

    fade {|fadeInDur=8, fadeOutDur=8|
        list.addAll(["fade", "q", fadeInDur]);
        if (fadeOutDur > 0) {
          list.add("reverse");
          list.addAll(["fade", "q", fadeOutDur]);
          list.add("reverse");
        }
    }

    reverse {
        list.add("reverse")
    }

    transform {|src, dest|

        var str;
        var srcpn = PathName(src);
        var destpn = PathName(dest);

        if (srcpn.parentPath == "") {
            src = "%/%".format(Document.current.dir, src);
        };
        if (destpn.parentPath == "") {
            dest = "%/%".format(Document.current.dir, dest);
        };

        str = "sox \"%\" \"%\" ".format(src.standardizePath, dest.standardizePath) ++ list.join(" ");
        str.postln.unixCmdGetStdOut;
        ^"transform done"
    }

    reset {
        list.clear
    }

    prInit {
        list = List();
    }
}
