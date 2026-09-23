"""Regression tests for patch.sh preflight and error handling."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PatchScriptTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'patch.sh').write_bytes((ROOT / 'patch.sh').read_bytes())
        for component in ['.', 'hdl', 'linux', 'buildroot', 'u-boot-xlnx']:
            (self.root / 'plutosdr-fw' / component / '.git').mkdir(parents=True, exist_ok=True)
        for p in ['0001-add-three-ant-hdl-support-bump-to-v0.39-v1.patch',
                  *['e200/0001-add-support-' + x + '.patch' for x in ['uboot', 'linux', 'buildroot', 'makefile-scripts']]]:
            path = self.root / 'patch' / p
            path.parent.mkdir(parents=True, exist_ok=True)
            path.touch()
        binpath = self.root / 'bin'
        binpath.mkdir()
        fake = binpath / 'git'
        fake.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$CALLS"\n'
                        'case "$*" in *"--check"*"linux.patch"*) '
                        '[ "${FAIL_CHECK:-0}" = 0 ] || exit 1;; esac\n'
                        'case "$*" in *"--check"*) ;; *"linux.patch"*) '
                        '[ "${FAIL_APPLY:-0}" = 0 ] || exit 1;; esac\n')
        fake.chmod(0o755)
        self.env = dict(os.environ, PATH=str(binpath) + ':' + os.environ['PATH'], CALLS=str(self.root / 'calls'))

    def run_script(self, *args):
        return subprocess.run(['sh', str(self.root / 'patch.sh'), *args], env=self.env, capture_output=True, text=True, cwd='/')

    def test_invalid_target_never_calls_git(self):
        self.assertNotEqual(self.run_script('../../bad').returncode, 0)
        self.assertFalse((self.root / 'calls').exists())

    def test_all_checks_precede_any_application(self):
        result = self.run_script('e200')
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = (self.root / 'calls').read_text().splitlines()
        self.assertEqual(len(calls), 10)
        self.assertTrue(all('--check' in c for c in calls[:5]))
        self.assertTrue(all('--check' not in c for c in calls[5:]))

    def test_failed_check_never_applies_or_reports_success(self):
        self.env['FAIL_CHECK'] = '1'
        result = self.run_script('e200')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('successfully', result.stdout)
        self.assertTrue(all('--check' in c for c in (self.root / 'calls').read_text().splitlines()))

    def test_missing_submodule_fails(self):
        (self.root / 'plutosdr-fw/hdl/.git').rmdir()
        result = self.run_script('e200')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('initialize recursive submodules', result.stderr)

    def test_missing_patch_never_applies(self):
        (self.root / 'patch/e200/0001-add-support-buildroot.patch').unlink()
        result = self.run_script('e200')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Missing patch:', result.stderr)
        self.assertTrue(all('--check' in c for c in (self.root / 'calls').read_text().splitlines()))

    def test_failed_application_stops_and_never_reports_success(self):
        self.env['FAIL_APPLY'] = '1'
        result = self.run_script('e200')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('successfully', result.stdout)
        calls = (self.root / 'calls').read_text().splitlines()
        self.assertEqual(len(calls), 8)
        self.assertIn('linux.patch', calls[-1])


if __name__ == '__main__':
    unittest.main()
