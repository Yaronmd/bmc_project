import os
import subprocess
import unittest
import tempfile
import shutil


class TestValidateLS(unittest.TestCase):
    def setUp(self):

        self.temp_dir = tempfile.TemporaryDirectory()
        self.scripts_dir = os.path.join(self.temp_dir.name, 'scripts')
        self.data_dir = os.path.join(self.scripts_dir, 'data')
        os.makedirs(self.data_dir, exist_ok=True)

        shutil.copy('./scripts/validate_ls.sh', self.scripts_dir)

        with open(os.path.join(self.scripts_dir, 'trigger_jenkins_b.sh'), 'w') as f:
            f.write('#!/bin/bash\necho "MOCK: Triggering Jenkins B"')
        with open(os.path.join(self.scripts_dir, 'monitor_jenkins_b.sh'), 'w') as f:
            f.write('#!/bin/bash\necho "MOCK: Monitoring Jenkins B"')
        os.chmod(os.path.join(self.scripts_dir, 'trigger_jenkins_b.sh'), 0o755)
        os.chmod(os.path.join(self.scripts_dir, 'monitor_jenkins_b.sh'), 0o755)
        os.chmod(os.path.join(self.scripts_dir, 'validate_ls.sh'), 0o755)

        self.script_path = os.path.join(self.scripts_dir, 'validate_ls.sh')

    def tearDown(self):
        # מנקה את התיקייה הזמנית
        self.temp_dir.cleanup()

    def test_not_triggering_below_threshold(self):
        open(os.path.join(self.data_dir, 'short.txt'), 'w').close()
        result = subprocess.run([self.script_path], capture_output=True, text=True)
        self.assertIn("Condition not met", result.stdout)

    def test_triggering_above_threshold(self):
        filenames = ['long-file-name.txt', 'second-file_name.txt', 'third_file-name.txt']
        for name in filenames:
            path = os.path.join(self.data_dir, name)
            open(path, 'w').close()
            print(f"Created file: {path}")

        result = subprocess.run([self.script_path], capture_output=True, text=True)
        self.assertIn("Condition met", result.stdout)
        self.assertIn("MOCK: Triggering Jenkins B", result.stdout)
        self.assertIn("MOCK: Monitoring Jenkins B", result.stdout)


if __name__ == '__main__':
    unittest.main()
