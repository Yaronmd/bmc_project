import subprocess

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
    assert "Hello BMC" in result.stdout, "Expected 'Hello BMC' in output"
