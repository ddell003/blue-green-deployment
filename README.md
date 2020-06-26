# blue-green-deployment
Blue/Green Deployment With Docker &amp; Kubernetes 

## GitOps Update Manifest
Since Cloud Build doesn't support commiting and pushing to a bitbucket repository, you have to define a ssh key, which gets messy fast.

This image allows us to specify the manifest repository and update the values.yaml file in it.
