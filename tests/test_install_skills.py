"""Exercise the installer against isolated home directories."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]


class InstallSkills(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='ho-rules-test-')
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.env = dict(os.environ, HOME=str(self.home), XDG_CONFIG_HOME=str(self.home / '.config'))

    def run_cli(self, *args, expected=0):
        result = subprocess.run([str(REPO / 'ho-rules'), 'install-skills', *args],
                                env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return result.stdout

    def test_dry_run_and_all_targets(self):
        self.run_cli('--all', '--dry-run')
        self.assertEqual(list(self.home.iterdir()), [])
        self.run_cli('--all')
        roots = ['.agents/skills', '.claude/skills', '.grok/skills', '.cursor/skills',
                 '.gemini/skills', '.gemini/antigravity-cli/skills', '.config/opencode/skills']
        for root in roots:
            for source in (REPO / 'skills').iterdir():
                if (source / 'SKILL.md').is_file():
                    self.assertEqual((self.home / root / source.name).resolve(), source)
        self.assertIn('already linked', self.run_cli('--all'))

    def test_conflicts_and_backups(self):
        dest = self.home / '.gemini/antigravity-cli/skills/advisor'
        dest.mkdir(parents=True)
        (dest / 'mine.txt').write_text('preserve me')
        self.run_cli('agy', expected=1)
        self.assertEqual((dest / 'mine.txt').read_text(), 'preserve me')
        self.run_cli('agy', '--force', '--dry-run')
        self.assertFalse((self.home / '.local').exists())
        self.run_cli('agy', '--force')
        self.assertTrue(dest.is_symlink())
        backups = list((self.home / '.local/state/ho-rules/backups').glob('*/advisor/mine.txt'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), 'preserve me')

    def test_invalid_target_before_writes(self):
        self.run_cli('-a', 'agy,continue', expected=1)
        self.assertEqual(list(self.home.iterdir()), [])
        self.run_cli('missing', expected=1)

    def test_broken_link_and_unrelated_skill(self):
        root = self.home / '.gemini/antigravity-cli/skills'
        root.mkdir(parents=True)
        (root / 'advisor').symlink_to(self.home / 'missing')
        (root / 'personal').mkdir()
        self.run_cli('--agent=agy', expected=1)
        self.run_cli('--agent=agy', '--force')
        self.assertTrue((root / 'personal').is_dir())
        self.assertEqual((root / 'advisor').resolve(), REPO / 'skills/advisor')


if __name__ == '__main__':
    unittest.main()
