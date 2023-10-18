UiModule : DMModule {

    *new {|key|
        var res;
        key = "ui/%".format(key).asSymbol;
        res = super.new(key);
        ^res;
    }

    view {|...args|
        ^this.value(*args);
    }

    gui {|...args|
        ^this.view(*args).front
    }

}
