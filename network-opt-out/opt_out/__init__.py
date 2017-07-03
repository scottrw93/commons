#!/usr/bin/env/python
import requests
import sys
import time
BLAZAR_ROOT_URL = 'http://bootstrap.hubteam.com/blazar/v2'


def main():
    expiresAt = int(1000 * time.time()) + (1000*60*60*24*14)

    repos = map(lambda x: x.lower(), sys.argv[1:])

    repoData = {}
    branches = requests.get(BLAZAR_ROOT_URL + '/branches').json()

    for repoName in repos:
        for branch in branches:
            if branch['repository'].lower() == repoName:
                repoData[branch['repository']] = branch['repositoryId']
                break

    for repoName in repoData:
        repoId = repoData[repoName]
        r  = requests.post(BLAZAR_ROOT_URL + '/repositories-without-net-lock-down', json={'repositoryId': repoId, 'repositoryName': repoName, 'expiresAtMillis': expiresAt})
        r.raise_for_status()

if __name__ == '__main__':
    main()
