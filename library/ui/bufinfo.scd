Require(App.librarydir ++ "ui/common.scd");
(
func: {arg buf;

    var bufname = if (buf.path.notNil) { PathName(buf.path).fileName } { "buf" };
    var view = View().layout_(VLayout().margins_(0).spacing_(0)).minSize_(Size(300, 150));
    var sfv = SoundFileView()
    .gridResolution_(0.0)
    .drawsRMS_(false)
    .toolTip_(bufname);

    buf.loadToFloatArray(action:{arg a;
        {
            sfv.setData(a, channels: buf.numChannels);
        }.defer
    });
    view.layout.add(sfv);
    view.layout.add(
        HLayout(nil,
            StaticText().string_(buf.bufnum),
            StaticText().string_(" | "),
            StaticText().string_(buf.sampleRate),
            StaticText().string_(" | "),
            StaticText().string_(buf.numFrames),
            StaticText().string_(" | "),
            StaticText().string_(buf.duration)
        ).spacing_(2).margins_(2)
    );
    view.name = bufname;
    view.front;
}
)
