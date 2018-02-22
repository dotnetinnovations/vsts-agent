VSTS Agent in a Windows Docker container
========================================

How to run
----------

Supply your account name and VSTS token in the docker run command.

    docker run \
      -e VSTS_ACCOUNT=<name> \
      -e VSTS_TOKEN=<pat> \
      -it dotnetinnovations/vsts-agent
