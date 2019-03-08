import QtQuick 2.0

Canvas {
    id: pieChart
    // canvas size
    width: parent.width
    height: parent.height

    property real coordinateX: 0.0
    property real coordinateY: 0.0

    property int topCenterX: (longAxis/2)  // 顶面椭圆心X
    property int topCenterY: (shortAxis/2) // 顶面椭圆心Y
    property int bottomCenterX: topCenterX  // 底面椭圆心X
    property int bottomCenterY: (topCenterY+columnHeight) // 底面椭圆心Y
    property int gapAngle: 5 // 扇柱间隙角度
    property int columnHeight: 18 // 柱高

    property int longAxis: 276    // 椭圆长轴
    property int shortAxis: (208-columnHeight)  // 椭圆短轴
    property int iLongAxis: 109   // 内椭圆长轴
    property int iShortAxis: (93-columnHeight)  // 内椭圆短轴

    property real gPosX: 0.0 // 保存计算出弧上x坐标值
    property real gPosY: 0.0 // 保存计算出弧上y坐标值

    property var angleArray:[
        {angleStart: 0.0, angleEnd: 0.0, color: "#fff"},
        {angleStart: 0.0, angleEnd: 0.0, color: "#fff"},
        {angleStart: 0.0, angleEnd: 0.0, color: "#fff"}]

    // handler to override for drawing
    onPaint: {
        console.log("painting....")
        // get context to draw with
        var ctx = getContext("2d")

//        // 调试准线
//        ctx.beginPath()
//        // 线一
//        ctx.moveTo(0, topCenterY)
//        ctx.lineTo(longAxis, topCenterY)
//        // 线二
//        ctx.moveTo(0, bottomCenterY)
//        ctx.lineTo(longAxis, bottomCenterY)
//        // 竖线
//        ctx.moveTo(topCenterX, 0)
//        ctx.lineTo(topCenterX, shortAxis)
//        ctx.closePath()
//        ctx.stroke()

        ctx.clearRect(0, 0, pieChart.width, pieChart.height)
        for (var i=0; i < angleArray.length; i++) {
            drawSector(ctx, angleArray[i].angleStart, angleArray[i].angleEnd, angleArray[i].color)
        }
    }

    function angleToRadian(angle)
    {
        return Math.PI/180*angle
    }

    // 圆心坐标，起止角度
    function drawSector(ctx, startAngle, endAngle, color)
    {
        // 弧上起止点坐标: 底面/顶面（外弧起点，外弧终点，内弧起点，内弧终点）
        var nodeArray = [
                {x: 0.0, y: 0.0}, {x: 0.0, y: 0.0}, {x: 0.0, y: 0.0}, {x: 0.0, y: 0.0},
                {x: 0.0, y: 0.0}, {x: 0.0, y: 0.0}, {x: 0.0, y: 0.0}, {x: 0.0, y: 0.0}]
        var cx, cy, cl, cs
        var cAngle
        for (var i=0; i<8; i++) {
            cx = bottomCenterX
            cy = bottomCenterY
            cl = longAxis
            cs = shortAxis
            cAngle = startAngle

            if (i >= 4) { // 顶面圆心
                cx = topCenterX
                cy = topCenterY
            }
            if (2==i || 3==i || 6==i || 7==i) { // 内弧轴长
                cl = iLongAxis
                cs = iShortAxis
            }
            if (1==i%2) {
                cAngle = endAngle
            }

            calCoordinate(cx, cy, cl/2, cs/2, angleToRadian(cAngle))
            nodeArray[i].x = gPosX
            nodeArray[i].y = gPosY
        }

        var topWidth = 0.3
        var otherwidth = 0.1

        ctx.strokeStyle = "grey"
        ctx.fillStyle = color
        ctx.lineWidth = otherwidth

        // 绘制底面椭圆环>>>
        ctx.save()
        ctx.beginPath()
        // 将笔触移动到底面外弧起点
        ctx.moveTo(nodeArray[0].x, nodeArray[0].y)
        // 底面外椭圆弧
        drawEllipticArc(ctx, bottomCenterX, bottomCenterY, longAxis/2, shortAxis/2,
                        startAngle, endAngle, false)
        // 底面内弧终点
        ctx.lineTo(nodeArray[3].x, nodeArray[3].y)
        // 底面内椭圆弧
        drawEllipticArc(ctx, bottomCenterX, bottomCenterY, iLongAxis/2, iShortAxis/2,
                        endAngle, startAngle, true)
        // 底面外弧起点
        ctx.lineTo(nodeArray[0].x, nodeArray[0].y)
        ctx.closePath()
        ctx.globalAlpha = 0.8
        ctx.fill()
        ctx.stroke()
        ctx.restore()
        // <<<绘制底面椭圆环


        // 绘制外弧面>>>
        ctx.save()
        ctx.beginPath()
        // 将笔触移动到底面外弧起点
        ctx.moveTo(nodeArray[0].x, nodeArray[0].y)
        // 底面外椭圆弧
        drawEllipticArc(ctx, bottomCenterX, bottomCenterY, longAxis/2, shortAxis/2,
                        startAngle, endAngle, false)
        // 顶面外弧终点
        ctx.lineTo(nodeArray[5].x, nodeArray[5].y)
        // 顶面外椭圆弧
        drawEllipticArc(ctx, topCenterX, topCenterY, longAxis/2, shortAxis/2,
                        endAngle, startAngle, true)
        // 底面外弧起点
        ctx.lineTo(nodeArray[0].x, nodeArray[0].y)
        ctx.closePath()
        ctx.globalAlpha = 0.8
        ctx.fill()
        ctx.stroke()
        ctx.restore()
        // <<<绘制外弧面


        // 绘制弧终点侧柱面>>>
        ctx.save()
        ctx.beginPath()
        // 将笔触移动到底面外弧终点
        ctx.moveTo(nodeArray[1].x, nodeArray[1].y)
        // 顶面外弧终点
        ctx.lineTo(nodeArray[5].x, nodeArray[5].y)
        // 顶面内弧终点
        ctx.lineTo(nodeArray[7].x, nodeArray[7].y)
        // 底面内弧终点
        ctx.lineTo(nodeArray[3].x, nodeArray[3].y)
        // 底面外弧终点
        ctx.lineTo(nodeArray[1].x, nodeArray[1].y)
        ctx.closePath()
        ctx.globalAlpha = 0.1
        ctx.fill()
        ctx.stroke()
        ctx.restore()
        // <<<绘制弧终点侧柱面


        // 绘制内弧面>>>
        ctx.save()
        ctx.beginPath()
        // 将笔触移动到底面内弧起点
        ctx.moveTo(nodeArray[2].x, nodeArray[2].y)
        // 底面内椭圆弧
        drawEllipticArc(ctx, bottomCenterX, bottomCenterY, iLongAxis/2, iShortAxis/2,
                        startAngle, endAngle, false)
        // 顶面内弧终点
        ctx.lineTo(nodeArray[7].x, nodeArray[7].y)
        // 顶面内椭圆弧
        drawEllipticArc(ctx, topCenterX, topCenterY, iLongAxis/2, iShortAxis/2,
                        endAngle, startAngle, true)
        // 底面内弧起点
        ctx.lineTo(nodeArray[2].x, nodeArray[2].y)
        ctx.closePath()
        ctx.globalAlpha = 0.8
        ctx.fill()
        ctx.stroke()
        ctx.restore()
        // <<<绘制内弧面


        // 绘制弧起点侧柱面>>>
        ctx.save()
        ctx.beginPath()
        // 将笔触移动到底面外弧起点
        ctx.moveTo(nodeArray[0].x, nodeArray[0].y)
        // 顶面外弧起点
        ctx.lineTo(nodeArray[4].x, nodeArray[4].y)
        // 顶面内弧起点
        ctx.lineTo(nodeArray[6].x, nodeArray[6].y)
        // 底面内弧起点
        ctx.lineTo(nodeArray[2].x, nodeArray[2].y)
        // 底面外弧起点
        ctx.lineTo(nodeArray[0].x, nodeArray[0].y)
        ctx.closePath()
        ctx.globalAlpha = 0.1
        ctx.fill()
        ctx.stroke()
        ctx.restore()
        // <<<绘制弧起点侧柱面


        // 绘制顶面椭圆环>>>
        ctx.save()
        ctx.beginPath()
        ctx.lineWidth = topWidth
        ctx.strokeStyle = "black"
        // 将笔触移动到顶面外弧起点
        ctx.moveTo(nodeArray[4].x, nodeArray[4].y)
        // 顶面外椭圆弧
        drawEllipticArc(ctx, topCenterX, topCenterY, longAxis/2, shortAxis/2,
                        startAngle, endAngle, false)
        // 顶面内弧终点
        ctx.lineTo(nodeArray[7].x, nodeArray[7].y)
        // 顶面内椭圆弧
        drawEllipticArc(ctx, topCenterX, topCenterY, iLongAxis/2, iShortAxis/2,
                        endAngle, startAngle, true)
        // 顶面外弧起点
        ctx.lineTo(nodeArray[4].x, nodeArray[4].y)
        ctx.closePath()
        ctx.globalAlpha = 0.8
        ctx.fill()
        ctx.stroke()
        ctx.restore()
        // <<<绘制顶面椭圆环

    }

    // 画一段弧线  圆心坐标，长轴/2，短轴/2, 起止角度, 描绘方向(true为逆时针)
    function drawEllipticArc(ctx, xp, yp, a, b, startAngle, endAngle, anticlockwise)
    {
        var i
        var tmpEnd
        if (anticlockwise) { // 逆时针方向
            tmpEnd = (endAngle<startAngle)?360:endAngle
            for(i=startAngle; i<=tmpEnd; i++)
            {
                drawUnitArc(ctx, xp, yp, a, b, i)
            }
            if (360 === tmpEnd) {
                // 结束角度小于起始角度，绘制0°至结束部分
                for(i=1; i<=endAngle; i++)
                {
                    drawUnitArc(ctx, xp, yp, a, b, i)
                }
            }
        }
        else { // 顺时针方向
            tmpEnd = (endAngle>startAngle)?0:endAngle
            for(i=startAngle; i>=tmpEnd; i--)
            {
                drawUnitArc(ctx, xp, yp, a, b, i)
            }
            if (0 === tmpEnd) {
                // 结束角度大于起始角度，绘制结束至360°部分
                for(i=360; i>=endAngle; i--)
                {
                    drawUnitArc(ctx, xp, yp, a, b, i)
                }
            }
        }
    }

    function drawUnitArc(ctx, xp, yp, a, b, angle)
    {
        //参数方程：x=acosθ ， y=bsinθ
        calCoordinate(xp, yp, a, b, angleToRadian(angle))
        ctx.lineTo(gPosX, gPosY)
    }

    // 计算圆弧上坐标，圆心坐标，长轴/2，短轴/2, 角度
    function calCoordinate(xp, yp, a, b, angle)
    {
        gPosX = xp + a*Math.cos(angle)
        gPosY = yp - b*Math.sin(angle)
    }

    function reDraw()
    {
        console.log("redraw...")
        pieChart.requestPaint()
    }
}
