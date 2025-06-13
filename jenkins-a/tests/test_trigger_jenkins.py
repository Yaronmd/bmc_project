import unittest
from unittest.mock import patch
import requests

def get_crumb(jenkins_url, user, token):
    response = requests.get(f"{jenkins_url}/crumbIssuer/api/json", auth=(user, token))
    response.raise_for_status()
    data = response.json()
    return data['crumbRequestField'], data['crumb']

def trigger_jenkins_job(jenkins_url, job_name, user, token):
    crumb_field, crumb = get_crumb(jenkins_url, user, token)
    headers = {crumb_field: crumb}
    response = requests.post(f"{jenkins_url}/job/{job_name}/build", auth=(user, token), headers=headers)
    response.raise_for_status()
    return response

class TestJenkinsTrigger(unittest.TestCase):

    @patch('requests.post')
    @patch('requests.get')
    def test_trigger_success(self, mock_get, mock_post):
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {
            'crumbRequestField': '.crumb',
            'crumb': 'mocked-crumb'
        }

        # Mock ה־trigger
        mock_post.return_value.status_code = 201

        # Run
        response = trigger_jenkins_job('http://mock-jenkins', 'job-a', 'admin', 'token')

        # Check
        self.assertEqual(response.status_code, 201)
        mock_get.assert_called_once()
        mock_post.assert_called_once()
        print("Trigger Jenkins mock test passed!")

if __name__ == '__main__':
    unittest.main()
