import json
import tempfile
import unittest
from pathlib import Path
from PIL import Image
from tests.screenshot.compare import compare_image


def make(path, color, size=(100, 50)):
    Image.new("RGB", size, color).save(path)


class CompareTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.cfg = {"pixel_tolerance": 3, "diff_ratio_max": 0.001}

    def tearDown(self):
        self.tmp.cleanup()

    def test_identical_passes(self):
        a = self.root / "a.png"
        b = self.root / "b.png"
        make(a, (10, 20, 30))
        make(b, (10, 20, 30))
        self.assertEqual(compare_image(a, b, None, self.cfg)["status"], "PASS")

    def test_single_pixel_diff_fails(self):
        a = self.root / "a.png"
        b = self.root / "b.png"
        make(a, (0, 0, 0))
        img = Image.new("RGB", (100, 50), (0, 0, 0))
        img.putpixel((0, 0), (255, 255, 255))
        img.save(b)
        res = compare_image(a, b, None, {**self.cfg, "diff_ratio_max": 0.0})
        self.assertEqual(res["status"], "FAIL")
        self.assertGreater(res["diff_pixels"], 0)

    def test_mask_ignores_region(self):
        a = self.root / "a.png"
        b = self.root / "b.png"
        make(a, (0, 0, 0))
        img = Image.new("RGB", (100, 50), (0, 0, 0))
        img.paste((255, 255, 255), (0, 0, 50, 50))
        img.save(b)
        mask = {"regions": [{"x": 0.0, "y": 0.0, "w": 0.6, "h": 1.0}]}
        res = compare_image(a, b, mask, {**self.cfg, "diff_ratio_max": 0.0})
        self.assertEqual(res["status"], "PASS")

    def test_size_mismatch_fails(self):
        a = self.root / "a.png"
        b = self.root / "b.png"
        make(a, (0, 0, 0))
        make(b, (0, 0, 0), (120, 50))
        res = compare_image(a, b, None, self.cfg)
        self.assertEqual(res["status"], "FAIL")
        self.assertIn("size", res["reason"])

    def test_missing_baseline(self):
        a = self.root / "a.png"
        make(a, (0, 0, 0))
        res = compare_image(a, self.root / "missing.png", None, self.cfg)
        self.assertEqual(res["status"], "NEW_BASELINE")


if __name__ == "__main__":
    unittest.main()
