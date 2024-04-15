import os, sys, shutil

c.JupyterHub.authenticator_class = 'tmpauthenticator.TmpAuthenticator'

# launch with docker
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'

# we need the hub to listen on all ips when it is in a container
c.JupyterHub.hub_ip = '0.0.0.0'
# the hostname/ip that should be used to connect to the hub
# this is usually the hub container's name
c.JupyterHub.hub_connect_ip = 'CONTAINER_NAME'

# pick a docker image. This should have the same version of Jupyterhub
# in it as our Hub.
c.DockerSpawner.image = 'IMAGE_NAME'

# tell the user containers to connect to our docker network
c.DockerSpawner.network_name = 'NETWORK_NAME'

# delete containers when the stop
c.DockerSpawner.remove = True

# comment out this line to use Jupyter Notebook IDE instead of Jupyterlab
c.Spawner.default_url = '/lab'

# use another command to start sos-docs
#c.DockerSpawner.extra_create_kwargs.update({ 'command': 'start-singleuser.sh' })

# set a reasonable number of concurrent users
c.JupyterHub.active_server_limit = 20

# Most jupyter/docker-stacks *-notebook images run the Notebook server as
# user `jovyan`, and set the notebook directory to `/home/jovyan/work`.
#notebook_dir = os.environ.get('DOCKER_NOTEBOOK_DIR') or '/home/jovyan/work'
notebook_dir = '/home/jovyan/work'
c.DockerSpawner.notebook_dir = notebook_dir
c.DockerSpawner.extra_create_kwargs = {'user': 'root'}

# Below is not necessary if volume path already exists and was given proper permissions.
def create_dir_hook(spawner):
    volume_path = 'HOST_DIR'
    if not os.path.exists(volume_path):
        os.mkdir(volume_path)
        shutil.chown(volume_path, user=spawner.user.name, group='users')

#c.Spawner.pre_spawn_hook = create_dir_hook

# Mount the host folder, created beforehand and was given proper permissions, to a directory in notebook container
c.DockerSpawner.volumes = { 'HOST_DIR': {"bind": notebook_dir, "mode":"rw"} }

# kill idle server after a while
c.JupyterHub.services = [
     {
         'name': 'cull-idle',
         'admin': True,
         'command': [sys.executable, 'cull_idle_servers.py', '--timeout=86400'],
     }
]
