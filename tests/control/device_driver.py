#!/usr/bin/env python3
# [L1 控件层] device_driver.py — ADB 控件操作、设备生命周期、坐标换算
import io
import json
import subprocess
from pathlib import Path

from PIL import Image

PACKAGE = "com.caiyipeng.probablystolen.mobile"


class DeviceError(Exception):
    pass


class DeviceOffline(DeviceError):
    pass


class Unauthorized(DeviceError):
    pass


class CommandTimeout(DeviceError):
    pass


class UnsupportedCapability(DeviceError):
    pass


class DeviceDriver:
    def __init__(self, serial="", adb="adb", ui_map_path=None):
        self.serial = serial
        self.adb = adb
        self.ui_map_path = ui_map_path
        self._map = json.loads(Path(ui_map_path).read_text(encoding="utf-8")) if ui_map_path else {}
        self._info = None

    def _run(self, args, timeout=30, binary=False):
        cmd = [self.adb] + (["-s", self.serial] if self.serial else [])
        try:
            proc = subprocess.run(cmd + args, capture_output=True, timeout=timeout)
        except subprocess.TimeoutExpired as e:
            raise CommandTimeout(str(e))
        if proc.returncode != 0:
            err = proc.stderr.decode("utf-8", "replace")
            if "device offline" in err:
                raise DeviceOffline(err)
            if "unauthorized" in err:
                raise Unauthorized(err)
            raise DeviceError(err)
        return proc.stdout if binary else proc.stdout.decode("utf-8", "replace")

    def device_info(self):
        if self._info:
            return self._info
        model = self._run(["shell", "getprop", "ro.product.model"]).strip()
        android = self._run(["shell", "getprop", "ro.build.version.release"]).strip()
        png = self._run(["exec-out", "screencap", "-p"], binary=True)
        size = Image.open(io.BytesIO(png)).size
        self._info = {"model": model, "android": android, "width": size[0], "height": size[1],
                      "profile": "device-%s-%dx%d-%s" % (model, size[0], size[1], android)}
        return self._info

    def install(self, apk):
        self._run(["install", "-r", "-t", str(apk)], timeout=180)

    def clear_data(self):
        self._run(["shell", "pm", "clear", PACKAGE])

    def force_stop(self):
        self._run(["shell", "am", "force-stop", PACKAGE])

    def launch(self):
        self._run(["shell", "am", "start", "-W", "-a", "android.intent.action.MAIN",
                   "-c", "android.intent.category.LAUNCHER", "-p", PACKAGE])

    def wake(self):
        try:
            self._run(["shell", "input", "keyevent", "224"])
            self._run(["shell", "wm", "dismiss-keyguard"])
        except DeviceError:
            pass

    def key(self, code):
        self._run(["shell", "input", "keyevent", str(code)])

    def _coord(self, key):
        info = self.device_info()
        rect = self._map.get("device", {}).get(key)
        if not rect:
            raise DeviceError("no device map for " + key)
        x = int((rect["x"] + rect["w"] / 2) * info["width"])
        y = int((rect["y"] + rect["h"] / 2) * info["height"])
        return x, y

    def tap_key(self, key):
        x, y = self._coord(key)
        self._run(["shell", "input", "tap", str(x), str(y)])

    def drag_key(self, from_key, to_key, duration_ms=400):
        x1, y1 = self._coord(from_key)
        x2, y2 = self._coord(to_key)
        self._run(["shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(duration_ms)])

    def screencap(self, dest):
        png = self._run(["exec-out", "screencap", "-p"], binary=True)
        Path(dest).parent.mkdir(parents=True, exist_ok=True)
        Path(dest).write_bytes(png)

    def write_user_file(self, name, text):
        import tempfile
        local = Path(tempfile.gettempdir()) / ("qa_" + name)
        remote = "/data/local/tmp/qa_" + name
        local.write_text(text, encoding="utf-8")
        try:
            self._run(["push", str(local), remote])
            self._run(["shell", "run-as", PACKAGE, "mkdir", "-p", "files"])
            self._run(["shell", "run-as", PACKAGE, "cp", remote, "files/" + name])
        finally:
            try:
                self._run(["shell", "rm", "-f", remote])
            except DeviceError:
                pass
            local.unlink(missing_ok=True)

    def remove_user_file(self, name):
        self._run(["shell", "run-as", PACKAGE, "rm", "-f", "files/" + name])
