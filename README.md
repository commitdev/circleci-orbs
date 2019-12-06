# circleci-orbs

Orbs to help make deployment pipelines for CircleCI easier.

## Development

Guide to Orbs: [CircleCI - Creating Orbs](https://circleci.com/docs/2.0/creating-orbs/)

Locally you'll want to run the validate script against your changed before pushing to your branch.

```bash
circleci orb validate src/commit/orb.yml
```

Then once you push to a branch, CircleCI will build and publish your dev version of the orb at `commitdev/commit@dev:$CIRCLE_BRANCH`. You can test the orb by changing the version of the orb you're importing in another project to your dev branch.


```yaml
commit: commitdev/commit@dev:my-branch
```

## Publishing

Our orb will automatically be published when merging to master branch. By default it's a patch version bump, but we can manually change that in the config.yml if we do a larger release.

We use the [CircleCI Orb Tools Orb](https://circleci.com/orbs/registry/orb/circleci/orb-tools) to publish the orb.
