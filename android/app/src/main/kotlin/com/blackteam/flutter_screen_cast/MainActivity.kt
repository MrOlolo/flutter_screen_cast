package com.blackteam.flutter_screen_cast

import android.annotation.TargetApi
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Matrix
import android.graphics.PixelFormat
import android.graphics.Point
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Display
import android.view.OrientationEventListener
import android.view.Surface
import android.widget.Toast
import com.blackteam.flutter_screen_cast.tcp_client.TcpClient
import com.blackteam.flutter_screen_cast.udp_client.DatagramSocketClient

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.ByteArrayOutputStream
import java.net.InetAddress
import java.net.UnknownHostException

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
class MainActivity : FlutterActivity() {
    private val streamController = "ivt.black/stream_controller"
    private val TAG = MainActivity::class.java.name
    private val REQUEST_CODE = 100
    private val FPS = 25
    private var IMAGES_PRODUCED: Int = 0
    private val MEDIA_PROJ_NAME = "video_stream"
    private val VIRTUAL_DISPLAY_FLAGS = DisplayManager.VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY or DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC
    private var sMediaProjection: MediaProjection? = null

    private var mProjectionManager: MediaProjectionManager? = null
    private var mImageReader: ImageReader? = null
    private var mHandler: Handler? = null
    private var mDisplay: Display? = null
    private var mVirtualDisplay: VirtualDisplay? = null
    private var mDensity: Int = 0
    private var mWidth: Int = 0
    private var mHeight: Int = 0
    private var mRotation: Int = 0
    private var mOrientationChangeCallback: OrientationChangeCallback? = null

    private var tcpSocketClient: TcpClient? = null
    private var datagramSocketClient: DatagramSocketClient? = null
    private var remoteHost: InetAddress? = null
    private val remotePort: Int = 49152

    private lateinit var _result: MethodChannel.Result
    private var resultSended = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        mProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        // start capture handling thread
        object : Thread() {
            override fun run() {
                Looper.prepare()
                mHandler = Handler()
                Looper.loop()
            }
        }.start()

        MethodChannel(flutterView, streamController).setMethodCallHandler { call, result ->
            when (call.method) {

                "start"
                -> {
                    resultSended = false
                    _result = result
                    val ip: String? = call.argument<String>("ip")
                    try {
                        if (!createSocket(ip!!)) {
                            Log.e(TAG, "Failed to connect tcp://$remoteHost:$remotePort")
                            if (!resultSended) {
                                result.error("1", "Failed to connect tcp://$remoteHost:$remotePort", null)
                                resultSended = true
                            }
                        } else {
                            Log.i(TAG, "TCP Socket created.")
                            startProjection()
                        }
                    } catch (t: Throwable) {
                        if (!resultSended) {
                            result.error("1", t.toString(), null)
                            resultSended = true
                        }
                    }
                }
                "stop" -> {
                    resultSended = false
                    _result = result

                    closeSocket()
                    stopProjection()

                    if (!resultSended) {
                        result.success("stopped")
                        resultSended = true
                    }
                }
            }
        }
    }

    private inner class OrientationChangeCallback internal constructor(context: Context) : OrientationEventListener(context) {

        @TargetApi(Build.VERSION_CODES.KITKAT)
        override fun onOrientationChanged(orientation: Int) {
            Log.e(TAG, "change orientation")
            try {
                val rotation = mDisplay!!.rotation
                if (rotation != mRotation) {
                    mRotation = rotation
                    if (mVirtualDisplay != null) {
                        mVirtualDisplay?.release()
                    }
                    if (mImageReader != null) {
                        mImageReader?.setOnImageAvailableListener(null, null)
                    }

                    createVirtualDisplay()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

        }
    }

    private inner class ImageAvailableListener : ImageReader.OnImageAvailableListener {
        private var lastImageMillis: Long = 0

        private var reusableBitmap: Bitmap? = null

        override fun onImageAvailable(reader: ImageReader) {
            val os: ByteArrayOutputStream
            var bitmap: Bitmap? = null

            try {
                val image = reader.acquireLatestImage()
                if (image != null) {
                    val now = System.currentTimeMillis()
                    if (now - lastImageMillis < 1000 / FPS) {
                        Log.e(TAG, "skip image")
                        image.close()
                        return
                    }
                    lastImageMillis = now

                    //                    // create bitmap
                    bitmap = getCleanBitmap(image)
                    image.close()
                    //Bitmap resizedBitmap = getResizedBitmap(bitmap, 1920, 1080);
                    os = ByteArrayOutputStream()
                    bitmap!!.compress(Bitmap.CompressFormat.JPEG, 30, os)
                    sendData(null, os.toByteArray())
                    //                    // write bitmap to a file
                    //                    fos = new FileOutputStream(STORE_DIRECTORY + "/myscreen_" + IMAGES_PRODUCED + ".png");
                    //                    bitmap.compress(CompressFormat.JPEG, 50, fos);

                    os.close()
                    IMAGES_PRODUCED++
                    Log.e(TAG, "captured image: $IMAGES_PRODUCED")
                }

            } catch (e: Exception) {
                e.printStackTrace()
            } finally {

                bitmap?.recycle()

                //                if (image != null) {
                //                    image.close();
                //                }
            }
        }

        private fun getCleanBitmap(image: Image): Bitmap? {
            val plane = image.planes[0]
            val width = plane.rowStride / plane.pixelStride
            val cleanBitmap: Bitmap
            if (width > image.width) {
                reusableBitmap = Bitmap.createBitmap(width, image.height, Bitmap.Config.ARGB_8888)

                reusableBitmap!!.copyPixelsFromBuffer(plane.buffer)
                cleanBitmap = Bitmap.createBitmap(reusableBitmap!!, 0, 0, image.width, image.height)
            } else {
                cleanBitmap = Bitmap.createBitmap(image.width, image.height, Bitmap.Config.ARGB_8888)
                cleanBitmap.copyPixelsFromBuffer(plane.buffer)
            }
            return cleanBitmap
        }

        fun getResizedBitmap(bm: Bitmap, newWidth: Int, newHeight: Int): Bitmap {
            val width = bm.width
            val height = bm.height
            val scaleWidth = newWidth.toFloat() / width
            val scaleHeight = newHeight.toFloat() / height
            // CREATE A MATRIX FOR THE MANIPULATION
            val matrix = Matrix()
            // RESIZE THE BIT MAP
            if (scaleWidth > scaleHeight) {
                matrix.postScale(scaleWidth, scaleWidth)
            } else {
                matrix.postScale(scaleHeight, scaleHeight)
            }

            // "RECREATE" THE NEW BITMAP
            val resizedBitmap = Bitmap.createBitmap(
                    bm, 0, 0, width, height, matrix, false)
            bm.recycle()
            return resizedBitmap
        }

    }

    private inner class MediaProjectionStopCallback : MediaProjection.Callback() {
        override fun onStop() {
            Log.e("ScreenCapture", "stopping projection.")
            mHandler!!.post {
                if (mVirtualDisplay != null) mVirtualDisplay?.release()
                if (mImageReader != null) mImageReader?.setOnImageAvailableListener(null, null)
                if (mOrientationChangeCallback != null) mOrientationChangeCallback?.disable()
                sMediaProjection?.unregisterCallback(this@MediaProjectionStopCallback)
            }
        }

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_CODE) {
            Log.e(TAG, "Unknown request code: $requestCode")
            if (!resultSended) {
                _result.error("0", "STRANGE CASE", null)
                resultSended = true
            }
            return
        }
        if (resultCode != RESULT_OK) {
            Toast.makeText(this,
                    "Screen Cast Permission Denied", Toast.LENGTH_SHORT).show()
            if (!resultSended) {
                _result.error("1", "access denied", null)
                resultSended = true
            }
            return
        }
        if (requestCode == REQUEST_CODE) {
            sMediaProjection = mProjectionManager?.getMediaProjection(resultCode, data!!)

            if (sMediaProjection != null) {
                // display metrics
                val metrics = resources.displayMetrics
                mDensity = metrics.densityDpi
                mDisplay = windowManager.defaultDisplay

                // create virtual display depending on device width / height
                createVirtualDisplay()

                // register orientation change callback
                mOrientationChangeCallback = OrientationChangeCallback(this)
                if (mOrientationChangeCallback!!.canDetectOrientation()) {
                    mOrientationChangeCallback?.enable()
                }

                // register media projection stop callback
                sMediaProjection?.registerCallback(MediaProjectionStopCallback(), mHandler)
                if (!resultSended) {
                    _result.success("started")
                    resultSended = true
                }
            }
        }
    }

    /****************************************** UI Widget Callbacks  */
    private fun startProjection() {
        startActivityForResult(mProjectionManager?.createScreenCaptureIntent(), REQUEST_CODE)
    }

    private fun stopProjection() {
        mHandler!!.post {
            if (sMediaProjection != null) {
                sMediaProjection?.stop()
            }
        }
    }

    /****************************************** Factoring Virtual Display creation  */
    private fun createVirtualDisplay() {
        // get width and height
        val size = Point()
        val rotation = mDisplay?.rotation
        mDisplay?.getSize(size)
        if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) {
            mWidth = if (size.x > size.y) size.y else size.x
            mHeight = if (size.x > size.y) size.x else size.y
        } else {
            mWidth = if (size.x > size.y) size.x else size.y
            mHeight = if (size.x > size.y) size.y else size.x
        }

        // start capture reader
        mImageReader = ImageReader.newInstance(mWidth, mHeight, PixelFormat.RGBA_8888, 5)
        mVirtualDisplay = sMediaProjection?.createVirtualDisplay(MEDIA_PROJ_NAME, mWidth, mHeight, mDensity, VIRTUAL_DISPLAY_FLAGS, mImageReader!!.surface, null, mHandler)
        mImageReader?.setOnImageAvailableListener(ImageAvailableListener(), mHandler)
    }

    private fun sendData(header: ByteArray?, data: ByteArray) {
        if (tcpSocketClient != null) {
            if (header != null) {
                tcpSocketClient?.send(header)
            }
            Log.e(TAG, "data " + data.size)
            tcpSocketClient?.send(data)
        } else if(datagramSocketClient != null){
            if (header != null) {
                val headerAndBody = ByteArray(header.size + data.size)
                System.arraycopy(header, 0, headerAndBody, 0, header.size)
                System.arraycopy(data, 0, headerAndBody, header.size, data.size)
                datagramSocketClient?.send(headerAndBody)
            } else {
                datagramSocketClient?.send(data)
            }
        } else {
            Log.e(TAG, "tcp socket not available.")
            stopProjection()
        }
    }

    private fun createSocket(ip: String): Boolean {
        try {
            this.remoteHost = InetAddress.getByName(ip)
        } catch (e: UnknownHostException) {
            Toast.makeText(this,
                    e.message, Toast.LENGTH_SHORT).show()
            e.printStackTrace()
        }

        tcpSocketClient = TcpClient(remoteHost!!, remotePort)
        tcpSocketClient?.start()
        return true
    }

    private fun createUdpSocket(ip: String): Boolean {
        try {
            this.remoteHost = InetAddress.getByName(ip)
        } catch (e: UnknownHostException) {
            Toast.makeText(this,
                    e.message, Toast.LENGTH_SHORT).show()
            e.printStackTrace()
        }

        datagramSocketClient = DatagramSocketClient(remoteHost!!, remotePort)
        datagramSocketClient?.start()
        return true
    }

    private fun closeSocket() {
        if (datagramSocketClient != null) {
            datagramSocketClient?.close()
            datagramSocketClient = null
        }
        if (tcpSocketClient != null) {
            try {
                tcpSocketClient?.close()
            } catch (ex: Exception) {
                ex.printStackTrace()
            } finally {
                tcpSocketClient = null
            }
        }
    }


}
