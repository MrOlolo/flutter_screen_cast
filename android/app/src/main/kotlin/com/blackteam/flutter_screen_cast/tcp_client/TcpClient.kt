package com.blackteam.flutter_screen_cast.tcp_client

import android.annotation.TargetApi
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import java.io.BufferedOutputStream
import java.io.IOException
import java.io.OutputStream
import java.net.InetAddress
import java.net.Socket

class TcpClient(val remoteHost: InetAddress, val remotePort: Int) : Thread() {
    private val TAG = "TcpSocketClient"

    private var socket: Socket? = null
    private var outputStream: OutputStream? = null
    private var bufferedOutputStream: BufferedOutputStream? = null
    private var handler: Handler? = null

    @TargetApi(Build.VERSION_CODES.CUPCAKE)
    internal inner class IncomingHandlerCallback : Handler.Callback {

        override fun handleMessage(message: Message?): Boolean {

            if (message?.obj == null) return false
            val msg = message.obj as ByteArray
            try {
                bufferedOutputStream?.write(msg)
            } catch (e: IOException) {
                e.printStackTrace()
                close()
            }
            return true
        }
    }

    @TargetApi(Build.VERSION_CODES.CUPCAKE)
    override fun run() {
        try {
            socket = Socket(remoteHost, remotePort)
            outputStream = socket?.getOutputStream()
            bufferedOutputStream = BufferedOutputStream(outputStream)
        } catch (e: IOException) {
           // Log.e(TAG, "Socket creation failed - $e")
            socket = null
            outputStream = null
            bufferedOutputStream = null
        }


        Looper.prepare()
        handler = Handler(IncomingHandlerCallback())
        Looper.loop()

    }

    fun close() {
        if (socket != null) {
            try {
                socket!!.close()
            } catch (e: IOException) {
                e.printStackTrace()
            } finally {
                socket = null
                outputStream = null
                bufferedOutputStream = null
            }
        }
    }

    fun send(data: ByteArray) {
       // Log.e(TAG, "send data")
        if (handler == null || socket == null || outputStream == null) {
            return
        }
        val message = handler!!.obtainMessage()
        message.obj = data

       // Log.e(TAG, "send data 2")
       // Log.e(TAG, "size: " + data.size)
        handler!!.sendMessage(message)
    }

}