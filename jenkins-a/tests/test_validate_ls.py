import os
import subprocess
import unittest

class TestValidateLS(unittest.TestCase):
    def setUp(self):
        self.script_path = './scripts/validate_ls.sh'
        self.data_dir = './scripts/data'
        print("DEBUG: validate_ls.sh exists:", os.path.exists(self.script_path))

        os.makedirs(self.data_dir, exist_ok=True)

        # נדרוס את הסקריפטים האמיתיים ב־mock
        with open('./scripts/trigger_jenkins_b.sh', 'w') as f:
            f.write('#!/bin/bash\necho "MOCK: Triggering Jenkins B"')
        with open('./scripts/monitor_jenkins_b.sh', 'w') as f:
            f.write('#!/bin/bash\necho "MOCK: Monitoring Jenkins B"')
        os.chmod('./scripts/trigger_jenkins_b.sh', 0o755)
        os.chmod('./scripts/monitor_jenkins_b.sh', 0o755)

    def tearDown(self):
        # מנקה רק את קבצי הנתונים
        for fname in os.listdir(self.data_dir):
            os.remove(os.path.join(self.data_dir, fname))

    def test_not_triggering_below_threshold(self):
        open(os.path.join(self.data_dir, 'short.txt'), 'w').close()
        result = subprocess.run([self.script_path], capture_output=True, text=True)
        self.assertIn("Condition not met", result.stdout)

    def test_triggering_above_threshold(self):
        for name in ['long-file-name.txt', 'second-file.txt', 'third-file.txt']:
            open(os.path.join(self.data_dir, name), 'w').close()
        result = subprocess.run([self.script_path], capture_output=True, text=True)
        self.assertIn("Condition met", result.stdout)
        self.assertIn("MOCK: Triggering Jenkins B", result.stdout)
        self.assertIn("MOCK: Monitoring Jenkins B", result.stdout)

if __name__ == '__main__':
    unittest.main()
