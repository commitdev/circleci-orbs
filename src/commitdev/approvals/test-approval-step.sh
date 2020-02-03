#!/bin/sh

# Test Data

# WORKFLOW_JOBS='{
#   "next_page_token" : null,
#   "items" : [ {
#     "dependencies" : [ ],
#     "job_number" : 82,
#     "id" : "ec6c3bc0-e300-48d3-a2b4-1ff66606eac5",
#     "started_at" : "2020-02-01T00:48:31Z",
#     "name" : "test",
#     "project_slug" : "gh/Direside/example-circleci-pipelines",
#     "status" : "success",
#     "type" : "build",
#     "stopped_at" : "2020-02-01T00:48:47Z"
#   }, {
#     "dependencies" : [ ],
#     "job_number" : 81,
#     "id" : "5051ad20-01e2-4463-aec0-21ad4da1a1c6",
#     "started_at" : "2020-02-01T00:48:29Z",
#     "name" : "build",
#     "project_slug" : "gh/Direside/example-circleci-pipelines",
#     "status" : "success",
#     "type" : "build",
#     "stopped_at" : "2020-02-01T00:48:40Z"
#   }, {
#     "started_at" : null,
#     "name" : "wait_for_approve",
#     "project_slug" : "gh/Direside/example-circleci-pipelines",
#     "approved_by" : "f3278297-88fd-438c-ad99-ff0a4212b31f",
#     "type" : "approval",
#     "status" : "success",
#     "id" : "565ffc9e-437e-40ae-960e-87e3660ba5e0",
#     "dependencies" : [ "5051ad20-01e2-4463-aec0-21ad4da1a1c6" ]
#   }, {
#     "started_at" : null,
#     "name" : "wait_for_approve2",
#     "project_slug" : "gh/Direside/example-circleci-pipelines",
#     "approved_by" : "f3278297-88fd-438c-ad99-ff0a4212b31f",
#     "type" : "approval",
#     "status" : "success",
#     "id" : "c467637e-a852-4784-b3df-6065d139f8b7",
#     "dependencies" : [ "5051ad20-01e2-4463-aec0-21ad4da1a1c6" ]
#   }, {
#     "dependencies" : [ "c467637e-a852-4784-b3df-6065d139f8b7", "565ffc9e-437e-40ae-960e-87e3660ba5e0" ],
#     "job_number" : 85,
#     "id" : "fbb93740-5573-47dd-81f7-28bc8c8b7ea7",
#     "started_at" : "2020-02-01T00:49:17Z",
#     "name" : "deploy",
#     "project_slug" : "gh/Direside/example-circleci-pipelines",
#     "status" : "success",
#     "type" : "build",
#     "stopped_at" : "2020-02-01T00:49:35Z"
#   } ]
# }'

WORKFLOW_JOBS=$(curl -H "Circle-Token: $CIRCLECI_API_KEY" "https://circleci.com/api/v2/workflow/${CIRCLE_WORKFLOW_ID}/job")
CURRENT_JOB_DEPENDENCIES=$(echo "$WORKFLOW_JOBS" | jq -cr ".items[] | select(.id == \"$CIRCLE_WORKFLOW_JOB_ID\") | .dependencies[]")
APPROVAL_JOBS=$(echo "$WORKFLOW_JOBS" | jq -cr '.items[] | select(.type == "approval")')

for JOB in $APPROVAL_JOBS
do
  JOB_ID=$(echo "$JOB" | jq -r .id)
  for DEPENDENCY_ID in $CURRENT_JOB_DEPENDENCIES
  do
    if [ "$DEPENDENCY_ID" = "$JOB_ID" ]; then
      APPROVED_BY=$(echo "$JOB" | jq -r .approved_by)
    fi
  done
done

APPROVER=$(curl -H "Circle-Token: $CIRCLECI_API_KEY" "https://circleci.com/api/v2/user/${APPROVED_BY}")

APPROVER_NAME=$(echo "$APPROVER" | jq -r '"\(.name) (\(.login))"')
echo "Approver: $APPROVER_NAME"
