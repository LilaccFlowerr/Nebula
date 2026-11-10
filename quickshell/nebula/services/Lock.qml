pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Singleton {
    id: root

    property bool wanted: false
    property bool unlocking: false
    property int typed: 0
    property bool failed: false
    property string message: ""
    readonly property bool checking: pam.active

    property string secret: ""

    signal failedAttempt()

    function lock() {
        if (wanted) return;
        failed = false;
        message = "";
        typed = 0;
        unlocking = false;
        wanted = true;
    }

    function submit(password) {
        if (!wanted || unlocking || pam.active || password === "") return;
        failed = false;
        message = "";
        secret = password;
        pam.start();
    }

    function finish() {
        unlocking = false;
        typed = 0;
        wanted = false;
    }

    PamContext {
        id: pam

        config: "login"

        onPamMessage: {
            if (responseRequired) {
                respond(root.secret);
                root.secret = "";
            }
        }

        onCompleted: result => {
            root.secret = "";
            if (result === PamResult.Success) {
                root.unlocking = true;
                return;
            }
            root.failed = true;
            root.message = result === PamResult.MaxTries ? "Too many attempts" : result === PamResult.Error ? "Authentication error" : "Wrong password";
            root.failedAttempt();
        }

        onError: {
            root.secret = "";
            root.failed = true;
            root.message = "Authentication error";
            root.failedAttempt();
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }

        function isLocked(): bool {
            return root.wanted;
        }
    }
}
