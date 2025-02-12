import json
import sys
import os


def convert_pylint_to_sonar(pylint_json_path, sonar_json_output_path):
    """
    Converts a Pylint JSON report to SonarQube Generic Issue Format.

    :param pylint_json_path: Path to the Pylint JSON report
    :param sonar_json_output_path: Path to the SonarQube-compatible JSON output
    """
    if not os.path.exists(pylint_json_path):
        print(f"❌ Error: Pylint report not found at {pylint_json_path}")
        sys.exit(1)

    try:
        with open(pylint_json_path, "r") as pylint_file:
            pylint_data = json.load(pylint_file)

        sonar_issues = []
        severity_mapping = {
            "fatal": "BLOCKER",
            "error": "CRITICAL",
            "warning": "MAJOR",
            "refactor": "MINOR",
            "convention": "INFO",
        }

        for issue in pylint_data:
            severity = severity_mapping.get(issue.get("type", "warning"), "MINOR")
            sonar_issues.append(
                {
                    "engineId": "pylint",
                    "ruleId": issue.get("message-id", "pylint-issue"),
                    "severity": severity,
                    "type": "CODE_SMELL",
                    "primaryLocation": {
                        "message": issue.get("message", "No message"),
                        "filePath": issue.get("path", "unknown"),
                        "textRange": {
                            "startLine": issue.get("line", 1),
                            "startColumn": issue.get("column", 0),
                        },
                    },
                }
            )

        # Write to SonarQube-compatible JSON
        with open(sonar_json_output_path, "w") as sonar_file:
            json.dump({"issues": sonar_issues}, sonar_file, indent=4)

        print(
            f"✅ Successfully converted Pylint report to SonarQube format: {sonar_json_output_path}"
        )

    except Exception as e:
        print(f"❌ Error processing Pylint report: {e}")
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python convert_pylint_to_sonar.py <pylint_json_input> <sonar_json_output>"
        )
        sys.exit(1)

    pylint_json_path = sys.argv[1]
    sonar_json_output_path = sys.argv[2]

    convert_pylint_to_sonar(pylint_json_path, sonar_json_output_path)
