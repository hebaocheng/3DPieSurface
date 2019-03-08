import QtQuick 2.5
import QtQuick.Controls 1.4

ApplicationWindow {
    visible: true
    width: 276
    height: 208
    title: qsTr("Hello World")

    property int gSysMemory: 0
    property int gUserMemory: 0
    property int gLeftMemory: 0
    property real gAngleGap: 2

    property real startBase: 245


    PieSurface {
        id: pChart
        x: 0
        y: 0
        width: 276
        height: 208
    }

    // 计算结束角度(起始角度，跨越角度)
    function calcAngleEnd(baseAngle, span)
    {
        var result = baseAngle-span
        if (result < 0) {
            result = 360+result
        }
        return result
    }

    function calcSectorArea()
    {
        var span
        var tmp
        var total = gSysMemory + gUserMemory + gLeftMemory
        var calcBase = (360-gAngleGap*3)

        // 计算剩余空间占用区域
        tmp = startBase
        span = gLeftMemory / total * calcBase
        pChart.angleArray[0].angleStart = tmp
        pChart.angleArray[0].angleEnd = calcAngleEnd(tmp, span)
        pChart.angleArray[0].color = "#5286bd"

        // 计算用户空间占用区域
        tmp = pChart.angleArray[0].angleEnd - gAngleGap
        span = gUserMemory / total * calcBase
        pChart.angleArray[1].angleStart = tmp
        pChart.angleArray[1].angleEnd = calcAngleEnd(tmp, span)
        pChart.angleArray[1].color = "#d15c5c"

        // 计算系统空间占用区域
        tmp = pChart.angleArray[1].angleEnd - gAngleGap
        span = gSysMemory / total * calcBase
        pChart.angleArray[2].angleStart = tmp
        pChart.angleArray[2].angleEnd = calcAngleEnd(tmp, span)
        pChart.angleArray[2].color = "#c7b38f"
    }

    function initMemData()
    {
        gSysMemory = 21
        gUserMemory = 189
        gLeftMemory = 181
        calcSectorArea()
    }

    function changeMemData()
    {
        gSysMemory = 21
        gUserMemory = 281
        gLeftMemory = 89
        calcSectorArea()
        pChart.reDraw()
    }

    Timer{
        id: drawTimer
        interval:3000
        repeat: false
        running: true
        onTriggered: {
            changeMemData()
        }
    }


   Component.onCompleted: {
       initMemData()
       drawTimer.running=true
   }
}
