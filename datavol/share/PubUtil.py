import requests
import pprint

def measure():
    url = 'http://localhost:8882/csp/mqtt/rest/measure'

    res = requests.post(url)
    #print(res.status_code)
    #pprint.pprint(res.json())
    return res.json()

def reset():
    url = 'http://localhost:8882/csp/mqtt/rest/reset'
    res = requests.post(url)
    #pprint.pprint(res.json())
    return res.json()

