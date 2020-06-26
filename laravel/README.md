# Building
This project uses Google Cloud Build for build and deployment. This happens automatically on a merge to master.

However, if a build needs triggered manually from source. Then run this command:
~~~
gcloud builds submit . --async --substitutions \
SHORT_SHA=[A_GIVEN_COMMIT_SHA],\
_LOCATION=[CLUSTER_LOCATION],\
_CLUSTER=[CLUSTER_NAME],\
_NAMESPACE=[K8S_NAMESPACE]
~~~
(Note: This requires permissions to manually trigger builds)
