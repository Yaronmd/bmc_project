def main():
    with open("/tmp/hello_bmc.txt", "w") as f:
        f.write("Hello BMC\n")
    print("File /tmp/hello_bmc.txt created with content: Hello BMC")

if __name__ == "__main__":
    main()
