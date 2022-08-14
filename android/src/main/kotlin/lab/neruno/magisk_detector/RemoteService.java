package lab.neruno.magisk_detector;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.system.Os;
import android.util.Log;

public class RemoteService extends Service {
    static {
        System.loadLibrary("vvb2060");
    }

    private final IRemoteService.Stub mBinder = new IRemoteService.Stub() {
        @Override
        public int haveSu() {
            return RemoteService.haveSu();
        }

        @Override
        public int haveMagiskHide() {
            return RemoteService.haveMagiskHide();
        }

        @Override
        public int haveMagicMount() {
            return RemoteService.haveMagicMount();
        }
    };

    @Override
    public IBinder onBind(Intent intent) {
        int appId = Os.getuid() % 100000;
        Log.d("RemoteService.onBind.appId", String.valueOf(appId));
        if (appId >= 90000) {
            return mBinder;
        }
        else return null;
    }

    static native int haveSu();

    static native int haveMagiskHide();

    static native int haveMagicMount();
}
