"""Check Makefile artifact selection without downloading FPGA images."""
from pathlib import Path
import os
import io
import tarfile
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class FPGASelectionTests(unittest.TestCase):
    def setUp(self):
        source = Path(os.environ.get('PLUTO_SOURCE', ROOT / 'plutosdr-fw'))
        if not (source / '.git').exists():
            self.fail('Initialize plutosdr-fw or set PLUTO_SOURCE to the pinned checkout')
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name)
        archive = subprocess.check_output(['git', '-C', str(source), 'archive',
                                          '9e90bce43f849882cd43c20a08effca132790fb3', 'Makefile', 'scripts'])
        with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
            tar.extractall(self.path)
        subprocess.run(['git', 'apply', str(ROOT / 'patch/e200/0001-add-support-makefile-scripts.patch')],
                       cwd=self.path, check=True, capture_output=True)

    def make(self, target, *args, dry=True):
        return subprocess.run(['make', *(['-n'] if dry else []), 'build/system_top.xsa',
                               'TARGET=' + target, 'HAVE_VIVADO=0', 'LATEST_TAG=v0.39', *args],
                              cwd=self.path, capture_output=True, text=True)

    def test_e200_without_artifact_fails(self):
        result = self.make('e200', dry=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('No FPGA source', result.stderr)
        self.assertFalse((self.path / 'build/system_top.xsa').exists())

    def test_pluto_keeps_own_default(self):
        result = self.make('pluto')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('https://github.com/analogdevicesinc/plutosdr-fw/releases/download/v0.39/system_top.xsa', result.stdout)

    def test_e200_uses_explicit_file(self):
        result = self.make('e200', 'XSA_FILE=/verified/e200.xsa')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('cp /verified/e200.xsa build/system_top.xsa', result.stdout)
        self.assertNotIn('wget', result.stdout)

    def test_e200_uses_explicit_url(self):
        result = self.make('e200', 'XSA_URL=https://example.org/e200/system_top.xsa')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('https://example.org/e200/system_top.xsa', result.stdout)
        self.assertNotIn('analogdevicesinc/plutosdr-fw/releases', result.stdout)

    def test_e200_prefers_vivado_when_available(self):
        result = self.make('e200', 'HAVE_VIVADO=1', 'VIVADO_VERSION=2023.2', 'VIVADO_INSTALL=2023.2')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('make -C hdl/projects/e200', result.stdout)
        self.assertNotIn('wget', result.stdout)


if __name__ == '__main__':
    unittest.main()
