import os
import subprocess
import unittest

class TestValidateLS(unittest.TestCase):
    def setUp(self):
        self.script_path = './scripts/validate_ls.sh'
        self.data_path = './scripts/data'
        os.makedirs(self.data_path, exist_ok=True)

        # מנקה הכל חוץ מ־validate_ls.sh
        for fname in os.listdir('./scripts'):
            if fname not in ['validate_ls.sh', 'data']:
                os.remove(os.path.join('./scripts', fname))

        for fname in os.listdir(self.data_path):
            os.remove(os.path.join(self.data_path, fname))

        # יוצרים mocks
        with open('./scripts/trigger_jenkins_b.sh', 'w') as f:
            f.write('#!/bin/bash\necho "MOCK: Triggering Jenkins B"')
        with open('./scripts/monitor_jenkins_b.sh', 'w') as f:
            f.write('#!/bin/bash\necho "MOCK: Monitoring Jenkins B"')
        os.chmod('./scripts/trigger_jenkins_b.sh', 0o755)
        os.chmod('./scripts/monitor_jenkins_b.sh', 0o755)

    def tearDown(self):
        for fname in os.listdir(self.data_path):
            os.remove(os.path.join(self.data_path, fname))

    def test_not_triggering_below_threshold(self):
        open(os.path.join(self.data_path, 'short.txt'), 'w').close()
        result = subprocess.run([self.script_path], capture_output=True, text=True)
        self.assertIn("Condition not met", result.stdout)

    def test_triggering_above_threshold(self):
        # יוצר 3 קבצים שהשמות שלהם ארוכים
        filenames = ['long-file-name.txt', 'second-file_name.txt', 'third_file-name.txt']
        for name in filenames:
            path = os.path.join(self.data_path, name)
            open(path, 'w').close()
            print(f"Created file: {path}")

        result = subprocess.run([self.script_path], capture_output=True, text=True)
        self.assertIn("Condition met", result.stdout)
        self.assertIn("MOCK: Triggering Jenkins B", result.stdout)
        self.assertIn("MOCK: Monitoring Jenkins B", result.stdout)

if __name__ == '__main__':
    unittest.main()
