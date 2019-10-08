import os
import sys

c.JupyterHub.authenticator_class = 'tmpauthenticator.TmpAuthenticator'

# launch with docker
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'

# we need the hub to listen on all ips when it is in a container
c.JupyterHub.hub_ip = '0.0.0.0'
# the hostname/ip that should be used to connect to the hub
# this is usually the hub container's name
c.JupyterHub.hub_connect_ip = 'jupyterhub'

# pick a docker image. This should have the same version of Jupyterhub
# in it as our Hub.
c.DockerSpawner.image = 'IMAGE_NAME_PLACE_HOLDER'

# tell the user containers to connect to our docker network
c.DockerSpawner.network_name = 'jupyterhub'

# delete containers when the stop
c.DockerSpawner.remove = True

# comment out this line to use Jupyter Notebook IDE instead of Jupyterlab
c.Spawner.default_url = '/lab'

# use another command to start sos-docs
#c.DockerSpawner.extra_create_kwargs.update({ 'command': 'start-singleuser.sh' })

# set a reasonable number of concurrent users
c.JupyterHub.active_server_limit = 20

# mount volumes
c.DockerSpawner.volumes = {
    #'/path/on/host': '/path/in/container'
    os.path.expanduser('~'): '/home/jovyan/work'
}

# kill idle server after a while
c.JupyterHub.services = [
     {
         'name': 'cull-idle',
         'admin': True,
         'command': [sys.executable, 'cull_idle_servers.py', '--timeout=86400'],
     }
]