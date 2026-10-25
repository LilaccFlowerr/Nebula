pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int users: 0
    readonly property bool running: users > 0
    property int interval: 2000

    property real cpu: 0
    property var coreUsage: []
    property int historyLength: 30
    property var cpuHistory: []
    property real cpuTemp: 0
    property real memUsed: 0
    property real memTotal: 0
    readonly property real mem: memTotal > 0 ? memUsed / memTotal : 0
    property real swapUsed: 0
    property real swapTotal: 0
    property real diskUsed: 0
    property real diskTotal: 0
    readonly property real disk: diskTotal > 0 ? diskUsed / diskTotal : 0
    property real netDown: 0
    property real netUp: 0

    readonly property string cpuName: {
        const match = cpuInfo.text().match(/^model name\s*:\s*(.+)$/m);
        return match ? match[1].replace(/\(R\)|\(TM\)|\d+(st|nd|rd|th) Gen |CPU|Processor|@.*$/g, "").replace(/\s+/g, " ").trim() : "";
    }

    property bool hasIntel: false
    property string gpuName: ""
    property real gpu: 0
    property real gpuFreq: 0
    property int gpuMhz: 0

    property bool hasNvidia: false
    property bool nvidiaActive: false
    property string nvidiaName: ""
    property real nvidia: 0
    property real nvidiaTemp: 0
    property int nvidiaMhz: 0
    property real nvidiaMemUsed: 0
    property real nvidiaMemTotal: 0

    readonly property bool useNvidia: hasNvidia && nvidiaActive
    readonly property real gpuLoad: useNvidia ? nvidia : gpu
    readonly property string activeGpuName: useNvidia ? nvidiaName : gpuName

    property string intelCard: ""
    property string nvidiaCard: ""
    property string tempPath: ""

    property var lastTotals: []
    property var lastIdles: []
    property real lastRx: -1
    property real lastTx: 0
    property real lastNetTime: 0
    property real lastRc6: -1
    property real lastRc6Time: 0

    function cleanGpu(raw, vendor) {
        const inner = raw.match(/\[(.+)\]/);
        const name = (inner ? inner[1] : raw).split(" / ")[0].replace(/Max-Q|Mobile/g, "").replace(/\s+/g, " ").trim();
        return name.startsWith(vendor) ? name : vendor + " " + name;
    }

    function update() {
        updateCpu();
        updateMem();
        updateNet();
        if (tempPath !== "") {
            tempFile.reload();
            cpuTemp = (parseInt(tempFile.text()) || 0) / 1000;
        }
        if (intelCard !== "")
            updateIntel();
        if (nvidiaCard !== "") {
            nvidiaStatus.reload();
            nvidiaActive = nvidiaStatus.text().trim() === "active";
        }
    }

    function updateCpu() {
        statFile.reload();
        const lines = statFile.text().split("\n").filter(line => line.startsWith("cpu"));
        const totals = [];
        const idles = [];
        const usage = [];
        lines.forEach((line, i) => {
            const parts = line.trim().split(/\s+/).slice(1, 8).map(v => parseInt(v) || 0);
            const total = parts.reduce((a, b) => a + b, 0);
            const idle = parts[3] + parts[4];
            const lastTotal = lastTotals[i] ?? 0;
            usage.push(lastTotal > 0 && total > lastTotal ? 1 - (idle - lastIdles[i]) / (total - lastTotal) : 0);
            totals.push(total);
            idles.push(idle);
        });
        const measured = lastTotals.length > 0;
        lastTotals = totals;
        lastIdles = idles;
        cpu = usage[0] ?? 0;
        if (measured)
            cpuHistory = [...cpuHistory.slice(-(historyLength - 1)), cpu];
        coreUsage = usage.slice(1);
    }

    function updateNet() {
        netFile.reload();
        let rx = 0;
        let tx = 0;
        for (const line of netFile.text().split("\n").slice(2)) {
            const [name, data] = line.split(":");
            if (!data || name.trim() === "lo")
                continue;
            const fields = data.trim().split(/\s+/);
            rx += parseInt(fields[0]) || 0;
            tx += parseInt(fields[8]) || 0;
        }
        const now = Date.now();
        if (lastRx >= 0 && now > lastNetTime) {
            netDown = Math.max(0, (rx - lastRx) / (now - lastNetTime) * 1000);
            netUp = Math.max(0, (tx - lastTx) / (now - lastNetTime) * 1000);
        }
        lastRx = rx;
        lastTx = tx;
        lastNetTime = now;
    }

    function updateMem() {
        memFile.reload();
        const info = {};
        for (const line of memFile.text().split("\n")) {
            const match = line.match(/^(\w+):\s+(\d+)/);
            if (match)
                info[match[1]] = parseInt(match[2]) * 1024;
        }
        memTotal = info.MemTotal ?? 0;
        memUsed = memTotal - (info.MemAvailable ?? 0);
        swapTotal = info.SwapTotal ?? 0;
        swapUsed = swapTotal - (info.SwapFree ?? 0);
    }

    function updateIntel() {
        rc6File.reload();
        freqFile.reload();
        maxFreqFile.reload();
        const rc6 = parseInt(rc6File.text()) || 0;
        const now = Date.now();
        if (lastRc6 >= 0 && now > lastRc6Time)
            gpu = Math.max(0, Math.min(1, 1 - (rc6 - lastRc6) / (now - lastRc6Time)));
        lastRc6 = rc6;
        lastRc6Time = now;
        const max = parseInt(maxFreqFile.text()) || 0;
        gpuMhz = parseInt(freqFile.text()) || 0;
        gpuFreq = max > 0 ? gpuMhz / max : 0;
    }

    onRunningChanged: {
        lastTotals = [];
        lastRx = -1;
        lastRc6 = -1;
        if (running)
            update();
    }

    Timer {
        running: root.running
        interval: root.interval
        repeat: true
        onTriggered: root.update()
    }

    Timer {
        running: root.running
        interval: 30000
        repeat: true
        triggeredOnStart: true
        onTriggered: diskProc.running = true
    }

    Process {
        id: diskProc
        command: ["df", "-B1", "--output=size,used", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("\n")[1]?.trim().split(/\s+/) ?? [];
                root.diskTotal = parseInt(fields[0]) || 0;
                root.diskUsed = parseInt(fields[1]) || 0;
            }
        }
    }

    Process {
        running: root.running && root.useNvidia
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu,clocks.gr,memory.used,memory.total", "--format=csv,noheader,nounits", "-lms", String(root.interval)]
        onRunningChanged: if (!running) root.nvidia = 0
        stdout: SplitParser {
            onRead: line => {
                const [util, temp, mhz, used, total] = line.split(",").map(v => parseFloat(v) || 0);
                root.nvidia = util / 100;
                root.nvidiaTemp = temp;
                root.nvidiaMhz = mhz;
                root.nvidiaMemUsed = used * 1048576;
                root.nvidiaMemTotal = total * 1048576;
            }
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "for c in /sys/class/drm/card*; do case $c in *-*) continue;; esac; [ -e $c/device/driver ] && echo gpu $c $(basename $(readlink $c/device/driver)) $(lspci -s $(basename $(readlink -f $c/device)) | cut -d: -f3-); done; for h in /sys/class/hwmon/hwmon*; do case $(cat $h/name) in coretemp|k10temp|zenpower) echo temp $h/temp1_input; break;; esac; done"]
        stdout: SplitParser {
            onRead: line => {
                const [kind, path, driver, ...rest] = line.trim().split(" ");
                const name = rest.join(" ");
                if (kind === "temp")
                    root.tempPath = path;
                else if (driver === "i915") {
                    root.intelCard = path;
                    root.gpuName = root.cleanGpu(name, "Intel");
                    root.hasIntel = true;
                } else if (driver === "nvidia") {
                    root.nvidiaCard = path;
                    root.nvidiaName = root.cleanGpu(name, "NVIDIA");
                    root.hasNvidia = true;
                }
            }
        }
    }

    FileView {
        id: cpuInfo
        path: "/proc/cpuinfo"
        blockLoading: true
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        blockLoading: true
    }

    FileView {
        id: netFile
        path: "/proc/net/dev"
        blockLoading: true
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        blockLoading: true
    }

    FileView {
        id: tempFile
        path: root.tempPath
        blockLoading: true
    }

    FileView {
        id: rc6File
        path: root.intelCard !== "" ? root.intelCard + "/gt/gt0/rc6_residency_ms" : ""
        blockLoading: true
    }

    FileView {
        id: freqFile
        path: root.intelCard !== "" ? root.intelCard + "/gt/gt0/rps_act_freq_mhz" : ""
        blockLoading: true
    }

    FileView {
        id: maxFreqFile
        path: root.intelCard !== "" ? root.intelCard + "/gt/gt0/rps_RP0_freq_mhz" : ""
        blockLoading: true
    }

    FileView {
        id: nvidiaStatus
        path: root.nvidiaCard !== "" ? root.nvidiaCard + "/device/power/runtime_status" : ""
        blockLoading: true
    }
}
