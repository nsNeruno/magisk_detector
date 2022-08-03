package lab.neruno.magisk_detector

import android.app.Activity
import android.content.ComponentName
import android.content.ServiceConnection
import android.content.SharedPreferences
import android.os.Build
import android.os.IBinder
import android.os.SystemClock
import android.util.Log
import androidx.annotation.NonNull
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.*
import java.nio.charset.StandardCharsets
import java.security.GeneralSecurityException

/** MagiskDetectorPlugin */
class MagiskDetectorPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  private val tag = "MagiskDetector"

  @Suppress("unused")
  private val connection: ServiceConnection = object : ServiceConnection {
    override fun onServiceConnected(name: ComponentName, binder: IBinder) {
//      val service: IRemoteService = IRemoteService.Stub.asInterface(binder)
//      try {
//        setCard1(service.haveSu())
//      } catch (e: RemoteException) {
//        Log.e(tag, "RemoteException", e)
//      }
    }

    override fun onServiceDisconnected(name: ComponentName) {
//      binding.textView.setText(R.string.error)
    }

    override fun onNullBinding(name: ComponentName) {
//      setError()
    }
  }

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "magisk_detector_channel")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "haveSu" -> {
        result.success(Native.haveSu())
      }
      "haveMagicMount" -> {
        result.success(Native.haveMagicMount())
      }
      "findMagiskdSocket" -> {
        result.success(Native.findMagiskdSocket())
      }
      "testIoctl" -> {
        result.success(Native.testIoctl())
      }
      "props" -> {
        result.success(props())
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  /**
   * This `ActivityAware` [io.flutter.embedding.engine.plugins.FlutterPlugin] is now
   * associated with an [android.app.Activity].
   *
   *
   * This method can be invoked in 1 of 2 situations:
   *
   *
   *  * This `ActivityAware` [io.flutter.embedding.engine.plugins.FlutterPlugin] was
   * just added to a [io.flutter.embedding.engine.FlutterEngine] that was already
   * connected to a running [android.app.Activity].
   *  * This `ActivityAware` [io.flutter.embedding.engine.plugins.FlutterPlugin] was
   * already added to a [io.flutter.embedding.engine.FlutterEngine] and that [       ] was just connected to an [       ].
   *
   *
   * The given [ActivityPluginBinding] contains [android.app.Activity]-related
   * references that an `ActivityAware` [ ] may require, such as a reference to the
   * actual [android.app.Activity] in question. The [ActivityPluginBinding] may be
   * referenced until either [.onDetachedFromActivityForConfigChanges] or [ ][.onDetachedFromActivity] is invoked. At the conclusion of either of those methods, the
   * binding is no longer valid. Clear any references to the binding or its resources, and do not
   * invoke any further methods on the binding or its resources.
   */
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  /**
   * The [android.app.Activity] that was attached and made available in [ ][.onAttachedToActivity] has been detached from this `ActivityAware`'s [io.flutter.embedding.engine.FlutterEngine] for the purpose of
   * processing a configuration change.
   *
   *
   * By the end of this method, the [android.app.Activity] that was made available in
   * [.onAttachedToActivity] is no longer valid. Any references to the
   * associated [android.app.Activity] or [ActivityPluginBinding] should be cleared.
   *
   *
   * This method should be quickly followed by [ ][.onReattachedToActivityForConfigChanges], which signifies that a new
   * [android.app.Activity] has been created with the new configuration options. That method
   * provides a new [ActivityPluginBinding], which references the newly created and associated
   * [android.app.Activity].
   *
   *
   * Any `Lifecycle` listeners that were registered in [ ][.onAttachedToActivity] should be deregistered here to avoid a possible
   * memory leak and other side effects.
   */
  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  /**
   * This plugin and its [io.flutter.embedding.engine.FlutterEngine] have been re-attached to
   * an [android.app.Activity] after the [android.app.Activity] was recreated to handle
   * configuration changes.
   *
   *
   * `binding` includes a reference to the new instance of the [ ]. `binding` and its references may be cached and used from now until
   * either [.onDetachedFromActivityForConfigChanges] or [.onDetachedFromActivity]
   * is invoked. At the conclusion of either of those methods, the binding is no longer valid. Clear
   * any references to the binding or its resources, and do not invoke any further methods on the
   * binding or its resources.
   */
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  /**
   * This plugin has been detached from an [android.app.Activity].
   *
   *
   * Detachment can occur for a number of reasons.
   *
   *
   *  * The app is no longer visible and the [android.app.Activity] instance has been
   * destroyed.
   *  * The [io.flutter.embedding.engine.FlutterEngine] that this plugin is connected to
   * has been detached from its [io.flutter.embedding.android.FlutterView].
   *  * This `ActivityAware` plugin has been removed from its [       ].
   *
   *
   * By the end of this method, the [android.app.Activity] that was made available in [ ][.onAttachedToActivity] is no longer valid. Any references to the
   * associated [android.app.Activity] or [ActivityPluginBinding] should be cleared.
   *
   *
   * Any `Lifecycle` listeners that were registered in [ ][.onAttachedToActivity] or [ ][.onReattachedToActivityForConfigChanges] should be deregistered here to
   * avoid a possible memory leak and other side effects.
   */
  override fun onDetachedFromActivity() {
    activity = null
  }

  private fun props(): Int? {
    val activity = this.activity ?: return null
    val sp: SharedPreferences
    try {
      val masterKey = MasterKey.Builder(activity)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()
      sp = EncryptedSharedPreferences.create(
        activity,
        activity.packageName,
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
      )
    } catch (e: GeneralSecurityException) {
      Log.e(tag, "Unable to open SharedPreferences.", e)
      return -1
    } catch (e: IOException) {
      Log.e(tag, "Unable to open SharedPreferences.", e)
      return -1
    }
    val spFingerprint = sp.getString("fingerprint", "") ?: ""
    val fingerprint = Build.FINGERPRINT
    Log.i(
      tag,
      "spFingerprint=$spFingerprint \n  fingerprint=$fingerprint"
    )
    val spBootId = sp.getString("boot_id", "") ?: ""
    val bootId = getBootId()
    Log.i(tag, "spBootId=$spBootId \n  bootId=$bootId")
    val spPropsHash = sp.getString("props_hash", "") ?: ""
    return if (spFingerprint == fingerprint && spBootId.isNotEmpty() && spPropsHash.isNotEmpty()) {
      if (spBootId != bootId) {
        if (spPropsHash == Native.getPropsHash()) 0 else 1
      } else 2
    } else {
      val editor = sp.edit()
      editor.putString("fingerprint", fingerprint)
      editor.putString("boot_id", bootId)
      editor.putString("props_hash", Native.getPropsHash())
      editor.apply()
      2
    }
  }

  private fun getBootId(): String {
    var bootId = ""
    try {
      FileInputStream("/proc/sys/kernel/random/boot_id").use { `is` ->
        val reader: Reader =
          InputStreamReader(`is`, StandardCharsets.UTF_8)
        bootId = BufferedReader(reader).readLine().trim { it <= ' ' }
      }
    } catch (e: IOException) {
      Log.w(tag, "Can't read boot_id.", e)
    }
    if (bootId.isEmpty()) {
      bootId = ((System.currentTimeMillis() - SystemClock.elapsedRealtime()) / 10).toString()
    }
    return bootId
  }
}
