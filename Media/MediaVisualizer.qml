import Quickshell.Services.Mpris
import QtQuick
import qs.Theme
import qs.Settings

Row {
    id: row
    property MprisPlayer player
    property bool showArtwork: true
    property real traceWidth: Settings.px(82)
    property real traceHeight: Settings.px(22)
    property color traceColor: Theme.textMuted
    readonly property bool wantsSamples: visible && enabled && (player?.isPlaying ?? false)
    property bool registered: false
    property bool ready: false

    spacing: Settings.px(6)

    function updateSubscription() {
        if (!ready || registered === wantsSamples)
            return;

        registered = wantsSamples;
        CavaSampler.consumerCount += registered ? 1 : -1;
    }

    onWantsSamplesChanged: updateSubscription()
    Component.onCompleted: {
        ready = true;
        updateSubscription();
    }
    Component.onDestruction: {
        if (registered)
            CavaSampler.consumerCount -= 1;
    }

    Image {
        width: Settings.px(26)
        height: width
        anchors.verticalCenter: parent.verticalCenter
        visible: row.showArtwork && status === Image.Ready
        source: row.showArtwork ? (row.player?.trackArtUrl ?? "") : ""
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Canvas {
        id: trace
        width: row.traceWidth
        height: row.traceHeight
        anchors.verticalCenter: parent.verticalCenter

        readonly property var levels: row.wantsSamples ? CavaSampler.levels : []
        readonly property color strokeColor: row.traceColor

        onLevelsChanged: requestPaint()
        onStrokeColorChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            const inset = Settings.px(1);
            const span = width - 2 * inset;
            const baseline = height * 0.75;
            const tint = strokeColor;
            const gradient = ctx.createLinearGradient(inset, 0, width - inset, 0);
            gradient.addColorStop(0, Qt.rgba(tint.r, tint.g, tint.b, 0.2));
            gradient.addColorStop(0.25, tint);
            gradient.addColorStop(0.72, tint);
            gradient.addColorStop(1, Qt.rgba(tint.r, tint.g, tint.b, 0));
            ctx.strokeStyle = gradient;
            ctx.lineWidth = Settings.px(1.5);
            ctx.lineCap = "round";

            ctx.beginPath();
            ctx.moveTo(inset, baseline);
            let previousX = inset;
            let previousY = baseline;
            const step = span / Math.max(1, levels.length);
            for (let i = 0; i < levels.length; ++i) {
                const x = inset + (i + 1) * step;
                const y = baseline - levels[i] * height * 0.62;
                const midX = previousX + step / 2;
                ctx.bezierCurveTo(midX, previousY, midX, y, x, y);
                previousX = x;
                previousY = y;
            }
            if (levels.length === 0)
                ctx.lineTo(width - inset, baseline);
            ctx.stroke();
        }
    }
}
