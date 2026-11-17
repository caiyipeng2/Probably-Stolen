import unittest

from tests.verdict.report import summarize, exit_code


def case(cid, status, assertions=None):
    return {"id": cid, "status": status, "assertions": assertions or [], "shots": []}


class VerdictTest(unittest.TestCase):
    def test_all_pass(self):
        s = summarize([case("logic/a", "PASS")], None, [], {})
        self.assertEqual(s["conclusion"], "回归通过")
        self.assertEqual(exit_code(s), 0)

    def test_new_regression(self):
        ref = {"cases": [{"id": "logic/a", "status": "PASS"}]}
        s = summarize([case("logic/a", "FAIL", [{"label": "x", "ok": False}])], ref, [], {})
        self.assertEqual(s["new_regressions"][0]["id"], "logic/a")
        self.assertEqual(exit_code(s), 1)

    def test_known_failure_not_counted(self):
        s = summarize([case("logic/a", "FAIL", [{"label": "x", "ok": False}])], None,
                      [{"case": "logic/a", "assertion": "x", "issue": "ISSUE-1"}], {})
        self.assertEqual(len(s["known_failures"]), 1)
        self.assertEqual(len(s["new_regressions"]), 0)
        self.assertEqual(exit_code(s), 0)

    def test_partial_known_failure_still_new_regression(self):
        ref = {"cases": [{"id": "logic/a", "status": "PASS"}]}
        known = [{"case": "logic/a", "assertion": "x", "issue": "ISSUE-1"}]
        s = summarize([case("logic/a", "FAIL", [{"label": "x", "ok": False},
                                                {"label": "y", "ok": False}])], ref, known, {})
        self.assertEqual(len(s["known_failures"]), 0)
        self.assertEqual(s["new_regressions"][0]["id"], "logic/a")
        self.assertEqual(exit_code(s), 1)

    def test_skip_is_not_failure(self):
        s = summarize([case("device/a", "SKIP")], None, [], {})
        self.assertEqual(exit_code(s), 0)

    def test_fail_without_reference_is_failure_not_new(self):
        s = summarize([case("logic/a", "FAIL", [{"label": "x", "ok": False}])], None, [], {})
        self.assertEqual(len(s["new_regressions"]), 0)
        self.assertEqual(s["failures"][0]["id"], "logic/a")
        self.assertEqual(exit_code(s), 1)

    def test_error_exit_2(self):
        s = summarize([case("logic/a", "ERROR")], None, [], {})
        self.assertEqual(exit_code(s), 2)

    def test_flaky_is_not_failure(self):
        s = summarize([case("ui/a", "FLAKY")], None, [], {})
        self.assertEqual(s["counts"]["flaky"], 1)
        self.assertEqual(exit_code(s), 0)


if __name__ == "__main__":
    unittest.main()
