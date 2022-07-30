(
func: {|node|
    var view, webview;
    webview = WebView();//.minSize_(Size(100, 300));
    view = View().layout_(VLayout(
        webview
    ));
    webview.url = "https://hydra.ojack.xyz/?sketch_id=rangga_4";
    view;
}
)