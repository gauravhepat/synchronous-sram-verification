import subprocess
import csv

vivado_path = r"D:\Verilog\Vivado\2024.1\bin\vivado.bat"
tcl_script = r"..\tcl\run_sim.tcl"

configs = [
    (8, 4),
    (16, 5),
    (32, 6)
]

results = []

overall_regression_pass = True

for DATA_WIDTH, ADDR_WIDTH in configs:

    print(f"\nRunning: DATA_WIDTH={DATA_WIDTH}, ADDR_WIDTH={ADDR_WIDTH}")

    result = subprocess.run(
        [
            vivado_path,
            "-mode", "batch",
            "-source", tcl_script,
            "-tclargs",
            str(DATA_WIDTH),
            str(ADDR_WIDTH)
        ],
        capture_output=True,
        text=True
    )

    output = result.stdout + result.stderr

    # ----------------------------------
    # Save individual log
    # ----------------------------------
    with open(
        f"sim_log_DW{DATA_WIDTH}_AW{ADDR_WIDTH}.txt",
        "w"
    ) as f:
        f.write(output)

    # ----------------------------------
    # SIMULATION CHECK
    # ----------------------------------
    simulation_failed = (
        "launch_simulation failed" in output or
        "compile' step failed" in output or
        "elaborate' step failed" in output or
        "ERROR:" in output
    )

    # ----------------------------------
    # ASSERTION CHECK
    # ----------------------------------
    assertion_failed = (
        "ASSERTION FAILED" in output
    )

    # ----------------------------------
    # COVERAGE CHECK
    # Full simulation completed
    # ----------------------------------
    coverage_pass = (
        "simulation ran for 1000ns" in output and
        not simulation_failed
    )

    # ----------------------------------
    # CORNER CASE CHECK
    # Random stress started + no assert fail
    # ----------------------------------
    corner_pass = (
        "Starting Random Stress Test" in output and
        not simulation_failed and
        not assertion_failed
    )

    # ----------------------------------
    # STATUS
    # ----------------------------------
    sim_status = (
        "FAILED"
        if simulation_failed
        else "PASSED"
    )

    if simulation_failed:
        assert_status = "NOT RUN"
    else:
        assert_status = (
            "FAILED"
            if assertion_failed
            else "PASSED"
        )

    cov_status = (
        "PASSED"
        if coverage_pass
        else "FAILED"
    )

    corner_status = (
        "PASSED"
        if corner_pass
        else "FAILED"
    )

    # ----------------------------------
    # Regression pass
    # ----------------------------------
    config_pass = (
        sim_status == "PASSED" and
        assert_status == "PASSED" and
        cov_status == "PASSED" and
        corner_status == "PASSED"
    )

    if not config_pass:
        overall_regression_pass = False

    regression_status = (
        "PASSED"
        if config_pass
        else "FAILED"
    )

    # ----------------------------------
    # Failure reason extraction
    # ----------------------------------
    reason = "No Error"

    for line in output.splitlines():

        if "ASSERTION FAILED" in line:
            reason = line.strip()
            break

        if "ERROR:" in line:
            reason = line.strip()
            break

    # ----------------------------------
    # PRINT DASHBOARD
    # ----------------------------------
    print(f"Simulation        : {sim_status}")
    print(f"Assertions        : {assert_status}")
    print(f"Coverage          : {cov_status}")
    print(f"Corner Cases      : {corner_status}")
    print(f"Regression        : {regression_status}")
    print(f"Reason            : {reason}")

    results.append([
        DATA_WIDTH,
        ADDR_WIDTH,
        sim_status,
        assert_status,
        cov_status,
        corner_status,
        regression_status,
        reason
    ])

# ----------------------------------
# OVERALL REGRESSION
# ----------------------------------
print("\n=================================")

if overall_regression_pass:
    print("OVERALL REGRESSION : PASSED")
else:
    print("OVERALL REGRESSION : FAILED")

print("=================================")

# ----------------------------------
# SAVE CSV
# ----------------------------------
with open(
    "regression_results.csv",
    "w",
    newline=""
) as f:

    writer = csv.writer(f)

    writer.writerow([
        "DATA_WIDTH",
        "ADDR_WIDTH",
        "Simulation",
        "Assertions",
        "Coverage",
        "CornerCases",
        "Regression",
        "Reason"
    ])

    writer.writerows(results)

print("\nRegression completed.")
print("Results saved to regression_results.csv")