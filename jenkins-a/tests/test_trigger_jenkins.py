import os
from dotenv import load_dotenv
import requests

env_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../scripts/.env'))
load_dotenv(dotenv_path=env_path)

JENKINS_A_URL = os.getenv("JENKINS_A_URL")
JENKINS_USER = os.getenv("JENKINS_USER")
JENKINS_TOKEN = os.getenv("JENKINS_API_TOKEN")

print("JENKINS_A_URL:", JENKINS_A_URL)
print("JENKINS_USER:", JENKINS_USER)
print("JENKINS_TOKEN:", '*' * len(JENKINS_TOKEN or ""))

def get_crumb():
    url = f"{JENKINS_A_URL}/crumbIssuer/api/json"
    response = requests.get(url, auth=(JENKINS_USER, JENKINS_TOKEN))
    response.raise_for_status()
    data = response.json()
    return data['crumbRequestField'], data['crumb']

def trigger_jenkins_job():
    crumb_field, crumb = get_crumb()
    headers = {crumb_field: crumb}
    job_url = f"{JENKINS_A_URL}/job/job-a/build"
    response = requests.post(job_url, auth=(JENKINS_USER, JENKINS_TOKEN), headers=headers)
    response.raise_for_status()
    return response

def test_trigger_jenkins():
    response = trigger_jenkins_job()
    assert response.status_code == 201
