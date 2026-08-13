import importlib.util
from pathlib import Path
import unittest

MODULE = Path(__file__).parents[1] / "scripts/daily_audit.py"
SPEC = importlib.util.spec_from_file_location("daily_audit", MODULE)
audit = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(audit)


class DailyAuditTests(unittest.TestCase):
    def test_redacts_home_and_ip(self):
        value = audit.redact(f"{Path.home()}/secret 192.168.1.4")
        self.assertNotIn(str(Path.home()), value)
        self.assertNotIn("192.168.1.4", value)

    def test_report_has_twelve_sections(self):
        data = {"started_at": "2026-08-12T10:00:00-03:00", "duration_seconds": 1.0, "checks": {}}
        report = audit.render(data)
        for number in range(1, 13):
            self.assertIn(f"## {number}.", report)


if __name__ == "__main__":
    unittest.main()
