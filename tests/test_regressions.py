"""Offline contracts; known bugs are explicit expected failures until fixed.

Set NIW_STRICT_REGRESSIONS=1 to make the known bugs fail the command.
All executions use temporary synthetic evidence and an isolated tool PATH.
"""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
BASH = shutil.which("bash")
known_defect = (
    (lambda test: test)
    if os.environ.get("NIW_STRICT_REGRESSIONS") == "1"
    else unittest.expectedFailure
)


class PipelineContracts(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="niw-regression-")
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.bin = self.work / "bin"
        self.bin.mkdir()
        # Do not inherit a real Claude CLI, PDF extractor, or user configuration.
        for tool in ("ls", "basename", "date", "mkdir", "find", "wc", "tr",
                     "cat", "head", "grep", "sed", "cut", "awk"):
            resolved = shutil.which(tool)
            if resolved is None:
                self.fail(f"Required test utility missing: {tool}")
            (self.bin / tool).symlink_to(resolved)
        self.env = {
            "PATH": str(self.bin),
            "HOME": str(self.work),
            "NIW_GURU_HOME": str(ROOT),
            "LC_ALL": "C",
        }
        self.source = self.work / "synthetic source"
        self.source.mkdir()
        (self.source / "cv.txt").write_text("Fictional researcher.\n")
        self.output = self.work / "output"
        self.marker = self.work / "claude-called"
        self.env["NIW_TEST_MARKER"] = str(self.marker)
        self.launcher = self.work / "niw-guru"
        self.launcher.write_text(
            (ROOT / "src/niw-guru.in").read_text().replace("@NIW_GURU_HOME@", str(ROOT))
        )

    def tool(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + body)
        path.chmod(0o755)

    def fake_claude(self, status=0):
        self.tool("claude", f': > "$NIW_TEST_MARKER"\nexit {status}\n')

    def launch(self, *args, output=None, name="run"):
        return subprocess.run(
            [BASH, str(self.launcher), "-s", str(self.source),
             "-o", str(output or self.output), "-n", name, *args],
            env=self.env, cwd=self.work, capture_output=True, text=True, timeout=10,
        )

    def test_dry_run_without_claude_creates_no_output(self):
        result = self.launch("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("[dry-run]", result.stdout)
        self.assertFalse(self.output.exists())

    def test_dry_run_never_invokes_available_claude(self):
        self.fake_claude(99)
        result = self.launch("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.output.exists())

    def test_real_run_without_claude_fails_before_writing(self):
        result = self.launch()
        self.assertEqual(result.returncode, 127, result.stderr)
        self.assertIn("CLI was not found", result.stderr)
        self.assertFalse(self.output.exists())

    def test_dry_run_still_rejects_missing_source(self):
        (self.source / "cv.txt").unlink()
        self.source.rmdir()
        result = self.launch("--dry-run")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("source is not a directory", result.stderr)
        self.assertFalse(self.output.exists())

    def test_dry_run_still_rejects_empty_source(self):
        (self.source / "cv.txt").unlink()
        result = self.launch("--dry-run")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("source directory is empty", result.stderr)

    def test_claude_failure_is_propagated(self):
        self.fake_claude(7)
        result = self.launch()
        self.assertTrue(self.marker.exists(), result.stderr)
        self.assertEqual(result.returncode, 7, result.stderr)

    @known_defect
    def test_source_overlap_is_rejected_before_any_write(self):
        self.fake_claude()
        before = sorted(p.relative_to(self.source) for p in self.source.rglob("*"))
        result = self.launch(output=self.source)
        after = sorted(p.relative_to(self.source) for p in self.source.rglob("*"))
        self.assertEqual(after, before, "Launcher wrote into its read-only source")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.marker.exists())

    @known_defect
    def test_run_name_cannot_escape_output_root(self):
        self.fake_claude()
        result = self.launch(name="../escaped")
        self.assertFalse((self.work / "escaped").exists(), "Run escaped output root")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.marker.exists())

    @known_defect
    def test_missing_deliverables_cannot_report_success(self):
        self.fake_claude()
        result = self.launch()
        self.assertTrue(self.marker.exists(), result.stderr)
        self.assertNotEqual(result.returncode, 0, "No deliverables, but successful exit")

    def locate(self, quote):
        # This fixture tests matching logic, not PDF parsing (covered separately).
        self.tool("pdfinfo", 'echo "Pages: 1"\n')
        self.tool("pdftotext", 'echo "one two three four five six seven eight nine ten eleven twelve real ending"\n')
        pdf = self.work / "mock.pdf"
        pdf.write_bytes(b"%PDF mocked extraction fixture\n")
        result = subprocess.run(
            [BASH, str(ROOT / ".claude/skills/niw-federal-evidence-harvester/scripts/pdf-locate-quote.sh"),
             str(pdf), quote], env=self.env, capture_output=True, text=True, timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def test_full_quote_is_located(self):
        self.assertEqual(self.locate(
            "one two three four five six seven eight nine ten eleven twelve real ending"), "1")

    def test_unrelated_quote_is_not_found(self):
        self.assertEqual(self.locate("This phrase never appears in the source"), "not-found")

    @known_defect
    def test_altered_quote_tail_cannot_return_verified_page(self):
        result = self.locate(
            "one two three four five six seven eight nine ten eleven twelve fabricated ending")
        self.assertFalse(result.isdigit(), "Prefix-only match is indistinguishable from full match")


if __name__ == "__main__":
    unittest.main(verbosity=2)
