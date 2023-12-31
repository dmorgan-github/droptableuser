// note: good reference: https://github.com/rabitt/pysox/blob/master/sox/transform.py
// also: https://gist.github.com/ideoforms/d64143e2bad16b18de6e97b91de494fd
Sox {

    var <list;

    var <>path;

    *new {
        ^super.new.prInit;
    }

    speed {|val|
        list.addAll(["speed", val])
    }

    remix {|left=1, right=2|
        var val = List();
        val.add("remix");
        if (left.notNil) {
            val.add(left)
        };
        if (right.notNil) {
            val.add(right);
        };
        list.addAll(val.asArray)
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

    mono {
        list.addAll(["remix -"])
    }

    trim {|start, len|
        // len 00:04 = 4 seconds
        list.addAll(["trim", start, len]);
    }

    reverse {
        list.add("reverse")
    }

    help {
        "%sox --help".format(path).unixCmdGetStdOut.postln
    }

    transform {|src, dest, replace=false|

        var str;
        var srcpn = PathName(src);
        var destpn = PathName(dest);

        if (srcpn.parentPath == "") {
            src = "%/%".format(Document.current.dir, src);
        };
        if (destpn.parentPath == "") {
            dest = "%/%".format(Document.current.dir, dest);
        };

        str = "%sox \"%\" \"%\" ".format(path, src.standardizePath, dest.standardizePath) ++ list.join(" ");
        if (replace) {
            str = str ++ "; rm %".format(src);
        };
        str.postln.unixCmdGetStdOut.postln;
        ^"transform done"
    }

    reset {
        list.clear
    }

    prInit {
        list = List();
        path = "/usr/local/bin/";
    }
}
