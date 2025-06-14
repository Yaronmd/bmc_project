import os
import subprocess
import unittest
import tempfile
import shutil


def set_executable(scripts_dir, script_names):
    """
    Set executable permissions (755) for a list of script files inside a directory.

    :param scripts_dir: The directory where the scripts are located.
    :param script_names: List of script file names to set as executable.
    """
    for name in script_names:
        path = os.path.join(scripts_dir, name)
        os.chmod(path, 0o755)
        
class TestValidateLS(unittest.TestCase):
    """
    Unit tests for validate_ls.sh script logic.
    """
    def setUp(self):
        """
        Create a temporary directory structure, copy and mock the necessary scripts,
        and set them as executable.
        """
        self.temp_dir = tempfile.TemporaryDirectory()
        self.scripts_dir = os.path.join(self.temp_dir.name, 'scripts')
        self.data_dir = os.path.join(self.scripts_dir, 'data')

        os.makedirs(self.data_dir, exist_ok=True)

        self.validate_script_name = 'validate_ls.sh'
        self.trigger_script_name = 'trigger_jenkins_b.sh'
        self.monitor_script_name = 'monitor_jenkins_b.sh'

        self.validate_script_path = os.path.join(self.scripts_dir, self.validate_script_name)
        self.trigger_script_path = os.path.join(self.scripts_dir, self.trigger_script_name)
        self.monitor_script_path = os.path.join(self.scripts_dir, self.monitor_script_name)

        # Copy validate_ls.sh
        shutil.copy('./scripts/validate_ls.sh', self.validate_script_path)

        # Create mock trigger and monitor scripts
        trigger_content = '#!/bin/bash\necho "MOCK: Triggering Jenkins B"'
        monitor_content = '#!/bin/bash\necho "MOCK: Monitoring Jenkins B"'

        with open(self.trigger_script_path, 'w') as f:
            f.write(trigger_content)
        with open(self.monitor_script_path, 'w') as f:
            f.write(monitor_content)

        # Set permissions
        set_executable(self.scripts_dir, [
            self.validate_script_name,
            self.trigger_script_name,
            self.monitor_script_name
        ])

        self.script_path = self.validate_script_path


    def tearDown(self):
        """
        Clean up the temporary directory after tests.
        """
        print("Clean up test files...")
        self.temp_dir.cleanup()

    def test_not_triggering_below_threshold(self):
        """
        Test that the script does not trigger Jenkins B when the word-like parts count is below threshold.
        """
        file_path = os.path.join(self.data_dir, 'short.txt')
        open(file_path, 'w').close()
        print(f"Created file: {file_path}")

        result = subprocess.run([self.script_path], capture_output=True, text=True)
        print(f"Script output:\n{result.stdout}")

        self.assertIn("Condition not met", result.stdout)
        print("test_not_triggering_below_threshold passed: Jenkins B was not triggered as expected.")

    def test_triggering_above_threshold(self):
        """
        Test that the script triggers Jenkins B when the word-like parts count exceeds threshold.
        """
        filenames = ['long-file-name.txt', 'second-file_name.txt', 'third_file-name.txt']
        
        for name in filenames:
            path = os.path.join(self.data_dir, name)
            open(path, 'w').close()
            print(f"Created file: {path}")

        result = subprocess.run([self.script_path], capture_output=True, text=True)
        print(f"Script output:\n{result.stdout}")
        self.assertIn("Condition met", result.stdout)
        self.assertIn("MOCK: Triggering Jenkins B", result.stdout)
        self.assertIn("MOCK: Monitoring Jenkins B", result.stdout)
        print("test_triggering_above_threshold passed: Jenkins B was triggered as expected.")


if __name__ == '__main__':
    unittest.main()