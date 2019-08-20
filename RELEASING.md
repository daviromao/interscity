# Releasing InterSCity

In this document, we'll cover the steps necessary to release InterSCity.

## Checklist

You should not proceed to release unless all of these have been attended:

* Check for open merge requests and notify authors giving them 3 days to merge
* Is the CI green? If not, make it green

## Release steps

* Freeze the master branch
* Update the CHANGELOG
  - many times commits are made without the CHANGELOG being updated. You should review the commits since the last release, and fill in any missing information for each CHANGELOG. You can review the commits for the 3.0.10 release like this: `git log v3.0.9..`
  - make sure to use semantic versioning
  - make sure to a new `Unreleased` section
* Push docker tag matching the CHANGELOG version for the base docker image
* Get each individual service Dockerfile `FROM` image pointing to the new tag
* Push docker tags matching the CHANGELOG version

```shell
export VERSION=0.1.0
export SERVICES=(resource-cataloguer resource-adaptor data-collector actuator-controller resource-discoverer kong-api-gateway)

for SERVICE in $SERVICES
do
  docker pull registry.gitlab.com/interscity/interscity-platform/interscity-platform/${SERVICE}:latest
  docker tag registry.gitlab.com/interscity/interscity-platform/interscity-platform/${SERVICE}:latest registry.gitlab.com/interscity/interscity-platform/interscity-platform/${SERVICE}:${VERSION}
  docker push registry.gitlab.com/interscity/interscity-platform/interscity-platform/${SERVICE}:${VERSION}
done
```

* Fix the created tags to the [ansible vars](deploy/ansible/group_vars/all) defined images
* Create a git tag matching the CHANGELOG version
* Get each individual service Dockerfile `FROM` image pointing back to the latest
* Get the [ansible vars](deploy/ansible/group_vars/all) docker images pointing back to the latest
* Announce the release to the users mailing list (interscity-platform@googlegroups.com)
