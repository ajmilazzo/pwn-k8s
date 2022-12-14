# pwn-k8s

A highly exploitable, overly privileged kubernetes deployment + exploit script.

<img src="/captain-hook.png" width="200" />

## Usage

Ensure you a kubernetes cluster (minikube, k3s, etc) setup & `kubectl` installed.

1. Spin up the deployment: `kubectl apply -f pwnable.yaml`
2. Hack: `./pwn.sh`

See [flycatcher-k8s](https://github.com/ajmilazzo/flycatcher-k8s) for kubernetes security tools to defend against this sort of attack.

Note: this has been tested on `macOS 13` with a `k3os` cluster. Results may vary on other systems.

## pwnable.yaml

Exploitable kubernetes manifest, along with a few other resources.

### Resources:

* user2 ServiceAccount
* cluster-role-binding-user2 ClusterRoleBinding
* mysecretname Secret
* basic-debian-pod-bound-token Deployment

### ClusterRoleBinding

This ClusterRoleBinding attaches "cluster-admin" ClusterRole to the "user2" ServiceAccount - effectivley granting all cluster permissions to the "user2" ServiceAccount.

### Deployment

The Deployment does nothing functionality-wise except sleep for infinity - this keeps the pod from entering a CrashLoop state. However, a token granting access to the "user2" ServiceAccount is mounted at the path `/var/run/secrets/my-bound-token`. 

Luckily, the token only has a 1 hour TTL, making it more difficult (but not impossible) to exploit than a long-lived token.

### Secret

The secret is of a special type - `kubernetes.io/service-account-token`. This binds the secret to a long-lived ServiceAccount token with no expiry, a potential gold mine for an APT.

## pwn.sh

Exploit script for the pwnable.yaml manifest.

### Stages

1. Grab the exploitable pod name
2. `exec` into the pod, and cat the bound ServiceAccount token
3. Find the IP of the host running the script
4. Launch a new pod using the k8s API that runs a reverse shell 
5. Listen on the host running the script 
6. Execute commands!

## Disclaimer

pwn-k8s is for educational purposes only. It is the end user's responsibility to obey all applicable local, state and federal laws. Authors assume no liability and are not responsible for any misuse or damage caused by this program.