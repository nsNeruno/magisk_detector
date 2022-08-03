package lab.neruno.magisk_detector;

public class Native {
    static {
        System.loadLibrary("vvb2060");
    }

    static native int haveSu();

    static native int haveMagicMount();

    static native int findMagiskdSocket();

    static native int testIoctl();

    static native String getPropsHash();
}
