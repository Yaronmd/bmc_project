import subprocess
import os

def test_hello_script():
    print("Running hello.py script...")
    result = subprocess.run(
        ["python3", "jenkins-b/scripts/hello.py"],
        capture_output=True,
        text=True
    )

    print("Return code:", result.returncode)
    print(result.stdout)
    if result.stderr:
        print("Error:\n", result.stderr)

    assert result.returncode == 0, f"Expected return code 0, got {result.returncode}"

    output_file = "/tmp/hello_bmc.txt"
    assert os.path.exists(output_file), f"Expected file {output_file} to exist"

    with open(output_file, "r") as f:
        content = f.read()

    print(f"File content: {content.strip()}")
    assert "Hello BMC" in content, "Expected 'Hello BMC' in file content"
