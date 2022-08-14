package lab.neruno.magisk_detector

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.os.RemoteException
import android.util.Log
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** MagiskDetectorPlugin */
class MagiskDetectorPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, LifecycleEventObserver {

  private val tag = "MagiskDetector"

  private var su: Int? = null
  private var magicMount: Int? = null
  private var magiskHide: Int? = null

  private var binding: ActivityPluginBinding? = null

  private val connection: ServiceConnection = object : ServiceConnection {
    override fun onServiceConnected(name: ComponentName, binder: IBinder) {
      val service: IRemoteService = IRemoteService.Stub.asInterface(binder)
      try {
        su = service.haveSu()
        magicMount = service.haveMagicMount()
        magiskHide = service.haveMagiskHide()
      } catch (e: RemoteException) {
        Log.e(tag, "RemoteException", e)
        channel.invokeMethod(
          "onServiceRemoteException",
          mapOf("message" to e.message),
          null
        )
      }
    }

    override fun onServiceDisconnected(name: ComponentName) {
      channel.invokeMethod("onServiceDisconnected", null, null)
    }

    override fun onNullBinding(name: ComponentName) {
      channel.invokeMethod("onNullBinding", null, null)
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
        result.success(su)
      }
      "haveMagicMount" -> {
        result.success(magicMount)
      }
      "haveMagiskHide" -> {
        result.success(magiskHide)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun onActivityObtained(activity: Activity) {
//    val appContext = activity.applicationContext
    val intent = Intent(activity, RemoteService::class.java)
//    val intent = Intent("lab.neruno.magisk_detector.RemoteService").apply {
//      `package` = activity.packageName
//    }
    try {
      val isServiceBound = activity.bindService(intent, connection, Context.BIND_AUTO_CREATE)
      if (!isServiceBound) {
        channel.invokeMethod("onAppHackedError", null, null)
      }
    } catch (ex: Exception) {
      Log.e(this.javaClass.name, ex.message ?: ex.javaClass.name)
    }
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
    this.binding = binding
    activity = binding.activity
    FlutterLifecycleAdapter.getActivityLifecycle(binding).addObserver(this)
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
    activity?.unbindService(connection)
    activity = null
    binding?.let {
      FlutterLifecycleAdapter.getActivityLifecycle(it).removeObserver(this)
    }
    binding = null
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
    this.binding = binding
    activity = binding.activity
    FlutterLifecycleAdapter.getActivityLifecycle(binding).addObserver(this)
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
    activity?.unbindService(connection)
    activity = null
    binding?.let {
      FlutterLifecycleAdapter.getActivityLifecycle(it).removeObserver(this)
    }
    binding = null
  }

  /**
   * Called when a state transition event happens.
   *
   * @param source The source of the event
   * @param event The event
   */
  override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
    if (event == Lifecycle.Event.ON_START) {
      activity?.let {
        onActivityObtained(it)
      }
    }
  }
}
