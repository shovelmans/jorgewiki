from flask import Flask, jsonify
import subprocess

app = Flask(__name__)

NAMESPACE = "centreon"


def run(cmd):
    try:
        output = subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL).decode()
        return output.strip()
    except:
        return "ERROR"


@app.route("/health")
def health():

    components = {}
    global_status = "UP"

    # -----------------------
    # CHECK PODS
    # -----------------------

    pods = run(f"kubectl get pods -n {NAMESPACE} --field-selector=status.phase!=Running --no-headers")

    if pods and "No resources found" not in pods:
        components["pods"] = {
            "status": "DOWN",
            "details": pods.splitlines()
        }
        global_status = "DOWN"
    else:
        components["pods"] = {
            "status": "UP"
        }

    # -----------------------
    # CHECK DEPLOYMENTS
    # -----------------------

    deploy = run(f"kubectl get deploy -n {NAMESPACE} --no-headers")

    zero_replica = []

    for line in deploy.splitlines():
        parts = line.split()

        if len(parts) >= 2:
            ready = parts[1]

            if "/" in ready:
                r, t = ready.split("/")

                if t == "0":
                    zero_replica.append(parts[0])

    if zero_replica:
        components["deployments"] = {
            "status": "DOWN",
            "details": [f"{d} 0 replicas" for d in zero_replica]
        }
        global_status = "DOWN"
    else:
        components["deployments"] = {
            "status": "UP"
        }

    result = {
        "status": global_status,
        "components": components
    }

    return jsonify(result)


app.run(host="0.0.0.0", port=8080)