import sys

REQUIRED_PYTHON = "python3.9.10"


def main():
    system_major = sys.version_info.major
    system_minor = sys.version_info.minor
    system_micro = sys.version_info.micro
    if REQUIRED_PYTHON == "python":
        required_major = 2
    elif REQUIRED_PYTHON == "python3.9.10":
        required_major = 3
        required_minor = 9
        required_micro = 10

    else:
        raise ValueError("Unrecognized python interpreter: {}".format(REQUIRED_PYTHON))

    if system_major != required_major or system_minor != required_minor:
        raise TypeError(
            "This project requires Python {}. Found: Python {}".format(
                f"{required_major}.{required_minor}", sys.version
            )
        )
    else:

        print(">>> Development environment passes all tests!")


if __name__ == "__main__":
    main()
