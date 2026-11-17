import json
import tempfile
import unittest
from pathlib import Path

from tests.control.device_driver import DeviceDriver


class CoordTest(unittest.TestCase):
    def test_percent_to_pixels(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "ui_map.json"
            p.write_text(json.dumps({"device": {"x": {"x": 0.5, "y": 0.5, "w": 0.1, "h": 0.1}}}),
                         encoding="utf-8")
            drv = DeviceDriver(ui_map_path=str(p))
            drv._info = {"model": "SM-S9280", "android": "16", "width": 2340, "height": 1080,
                         "profile": "device-SM-S9280-2340x1080-16"}
            self.assertEqual(drv._coord("x"), (1287, 594))

    def test_missing_key_raises(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "ui_map.json"
            p.write_text(json.dumps({"device": {}}), encoding="utf-8")
            drv = DeviceDriver(ui_map_path=str(p))
            drv._info = {"model": "SM-S9280", "android": "16", "width": 2340, "height": 1080,
                         "profile": "device-SM-S9280-2340x1080-16"}
            with self.assertRaises(Exception):
                drv._coord("missing")


if __name__ == "__main__":
    unittest.main()
