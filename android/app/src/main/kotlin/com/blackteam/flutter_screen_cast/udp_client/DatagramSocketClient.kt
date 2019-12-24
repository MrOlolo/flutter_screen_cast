package com.blackteam.flutter_screen_cast.udp_client

import android.os.AsyncTask
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import java.io.IOException
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.NetworkInterface
import java.net.SocketException

class DatagramSocketClient(val remoteHost: InetAddress, val remotePort: Int) : Thread("DatagramSocketClient") {
    private val TAG = "DatagramSocketClient"
    private var datagramSocket: DatagramSocket? = null
    private var handler: Handler? = null
    private val MTU = 1024

    override fun run() {
        try {
            datagramSocket = DatagramSocket()
        } catch (e: SocketException) {
            e.printStackTrace()
        }
        Looper.prepare()
        handler = object : Handler() {
            override fun handleMessage(message: Message?) {
                if (message == null || message.obj == null) return
                val msg = message.obj as ByteArray
                val totalLength = msg.size
                var remainLength = msg.size
                while (remainLength > 0) {
                    val offset = totalLength - remainLength
                    val size = if (remainLength > MTU) MTU else remainLength
                    remainLength -= size
                    try {
                        datagramSocket?.send(DatagramPacket(msg, offset, size, remoteHost, remotePort))
                    } catch (ex: IOException) {
                        ex.printStackTrace()
                    }
                }
            }
        }
        Looper.loop()
    }

    fun close() {
        datagramSocket?.close()
    }

    fun send(data: ByteArray?) {
        if (handler == null || datagramSocket == null) {
            return
        }
        val message: Message = handler!!.obtainMessage()
        message.obj = data
        handler!!.sendMessage(message)
    }
}