#!/bin/bash

setup_ssh () {
  echo "[Manifest] Adding SSH Key";

  mkdir /root/.ssh;

  echo $SSH_KEY | base64 -d >> /root/.ssh/id_rsa_bitbucket

  chmod 600 /root/.ssh/id_rsa_bitbucket
  cat <<EOF >/root/.ssh/config
Hostname bitbucket.org
IdentityFile /root/.ssh/id_rsa_bitbucket
EOF
  ssh-keyscan -t rsa bitbucket.org > /root/.ssh/known_hosts
}

manifest_clone () {
  echo "[Manifest] Cloning Repository";

  if ! git clone "$GIT_ORIGIN" bitbucket_repo;
  then
    echo "[Manifest] Could not clone repository.";
    exit 1;
  fi

  git config --global user.email ''
  git config --global user.name "Cloud Build Agent"
}

manifest_generate () {
  echo "[Manifest] Generating Manifest";

  cd bitbucket_repo;

  git fetch && git checkout "$GIT_BRANCH";
  git remote set-url origin "$GIT_ORIGIN";

  for var in "${COMMIT_VALUES[@]}";
  do
    KEY=$(echo "$var" | cut -d '=' -f1)
    VAL=$(echo "$var" | cut -d '=' -f2)
    # Copy each argument into the Values file
    yq w -i values.yaml "$KEY" "$VAL"
  done

  git add values.yaml
  git commit -m "$COMMIT_MESSAGE"

  if ! git push;
  then
    echo "[Manifest] Failed to push manifest";
    exit 1;
  fi
}

COMMIT_MESSAGE="Updating Manifest"
COMMIT_VALUES=()

GIT_BRANCH="master"
GIT_ORIGIN=""

for i in "$@"
do
  case $i in
    --help )
      cat << EOF
Update manifest values in given repo.

Command:
  git-manifest.sh [--flags] VALUES

Examples:
  git-manifest.sh 'appImage=nginx:alpine'
  git-manifest.sh --commit-msg="Deploying App Manifest" 'appImage=nginx:alpine'

Information for all options:
  --help
    Display this help message.

  --commit-msg=""
    Use a custom commit message

  --branch="master"
    The branch that the values will get committed to.

  --origin=""
    The remote origin of the env repository.
EOF
      echo "";
      exit 0;
    ;;
    --commit-msg=* )
      COMMIT_MESSAGE=$(echo $i | sed -e 's#.*=\(\)#\1#')
    ;;
    --branch=* )
      GIT_BRANCH=$(echo $i | sed -e 's#.*=\(\)#\1#')
    ;;
    --origin=* )
      GIT_ORIGIN=$(echo $i | sed -e 's#.*=\(\)#\1#')
    ;;
    --* )
      echo "Bad argument $i";
      exit 1;
    ;;

    # Copy over values into array
    * )
      COMMIT_VALUES+=($i)
    ;;
  esac
done

if [[ -z "$SSH_KEY" ]];
then
  echo "[Manifest] Environment variable 'SSH_KEY' missing";
  exit 1;
fi

if [[ -z "$GIT_BRANCH" ]] || [[ -z "$GIT_ORIGIN" ]];
then
  echo "Missing arguments, please check the manual using --help";
  exit 1;
fi

setup_ssh
manifest_clone
manifest_generate

echo "[Manifest] Done.";
exit 0;
