App {

    classvar <>workspacedir, <>mediadir, <>librarydir;
    classvar <>touchoscserver, <>touchoscport;
    classvar <>isrecording;

    *initClass {
        workspacedir = "~/Documents/supercollider/workspaces/".standardizePath;
        mediadir = "~/Documents/supercollider/media/".standardizePath;
        librarydir = "~/projects/droptableuser/library/".standardizePath;
        //touchoscserver = "10.0.1.81";
        //touchoscport = 9000;
    }
}
