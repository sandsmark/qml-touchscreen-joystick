import QtQuick 2.12
import QtQuick.Window 2.12
import com.iskrembilen 1.0

Window {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    color: "black"

    Rectangle {
        id: dragArea
        anchors.centerIn: parent

        width: 200
        height: width
        radius: Math.max(width/2, height/2)
        color: "white"

        // Some retro-glossy skeumorphic shit
        gradient: Gradient {
            GradientStop { position: 0.0; color: "lightgray" }
            GradientStop { position: 0.33; color: "gray" }
            GradientStop { position: 1.0; color: "white" }
        }

        Item {
            id: dragIndicator
            width: 20
            height: width
            property real defaultX: dragArea.width/2 - width/2
            property real defaultY: dragArea.height/2 - height/2
            x: defaultX
            y: defaultY


            Rectangle {
                id: dragIndicatorRect
                visible: dragMouseArea.containsMouse
                color: "black"
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                radius: width/2
            }
        }
        Rectangle {
        id: backgroundRect
        width: 200
        height: 150
        radius: 5
        anchors.centerIn: parent
        color: "red"

        Rectangle {
            id: dropShadowRect
            property real offset: Math.min(parent.width*0.025, parent.height*0.025)
            color: "purple"
            width: parent.width
            height: parent.height
            z: -1
            opacity: 0.75
            radius: backgroundRect.radius + 2
            anchors.left: parent.left
            anchors.leftMargin: -offset
            anchors.top: parent.top
            anchors.topMargin: offset
        }
    }
    }

    property real startGlobalX: 0
    property real startGlobalY: 0
    property real startX: 0
    property real startY: 0
    property real speed: 0
    property real heading: 0

    MouseArea {
        id: dragMouseArea
        anchors.fill: parent
        enabled: true
        cursorShape: Qt.ArrowCursor
        onPressed:{
            if (!dragArea.contains(mapToItem(dragArea, Qt.point(mouse.x, mouse.y)))) {
                return;
            }

            const globalPos = mapToGlobal(mouse.x, mouse.y);
            startGlobalX = globalPos.x;
            startGlobalY = globalPos.y;

            const localPos = mapToItem(dragArea, mouse.x, mouse.y);
            startX = localPos.x;
            startY = localPos.y;
            cursorShape = Qt.BlankCursor;
            speed = 0;
        }
        onReleased: {
            Cursor.setPosition(startGlobalX, startGlobalY);
            dragIndicator.x = dragIndicator.defaultX;
            dragIndicator.y = dragIndicator.defaultY;

            speed = 0;

            cursorShape = Qt.ArrowCursor;
        }
        onPositionChanged: {
            var newPos = mapToItem(dragArea, mouse.x, mouse.y);
            const origPos = newPos;
            var changed = false;
            const maxX = dragArea.width + dragIndicator.width * 2;
            const maxY = dragArea.height + dragIndicator.height * 2;
            const minX = -(dragIndicator.width*2);
            const minY = -(dragIndicator.height*2);
            if (newPos.x > maxX) {
                newPos.x = maxX;
                changed = true;
            }
            if (newPos.y > maxY) {
                newPos.y = maxY;
                changed = true;
            }
            if (newPos.x < minX) {
                newPos.x = minX;
                changed = true;
            }
            if (newPos.y < minY) {
                newPos.y = minY;
                changed = true;
            }

            const deltaX = newPos.x - startX;
            const deltaY = newPos.y - startY;
            var distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
            const maxDistance = dragArea.width / 2;
            if (distance > maxDistance) {
                distance = maxDistance;
            }

            const angle = Math.atan2(deltaY, deltaX);

            dragIndicator.x = Math.cos(angle) * distance + dragArea.width / 2 - dragIndicator.width/2;
            dragIndicator.y = Math.sin(angle) * distance + dragArea.height / 2 - dragIndicator.height/2;
            dragIndicatorRect.rotation = angle*180/Math.PI;

            heading = angle;
            speed = distance / maxDistance;

            if (changed) {
                const gpos = dragArea.mapToGlobal(newPos.x, newPos.y);
                Cursor.setPosition(gpos.x, gpos.y);
                return;
            }
        }
    }
}
