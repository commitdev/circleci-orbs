#!/bin/bash

# Tests for slack-message orb.
#
# To run, create a .env file with the below variables (no quotes):
#   SLACK_BOT_TOKEN=xoxb-12345-abcd
#   BUILD_RESULT=failed
#   CHANNEL=staging-deploy
#   AUTHOR_EMAIL=person@example.com
#
# Then copy the CircleCI environment variables from the 'Using build environment variables' block in your job. E.g.:
# BASH_ENV=/tmp/.bash_env-5e012ebafe8b924337b7041c-0-build
# CIRCLE_BRANCH=my-test-branch
# CIRCLE_BUILD_NUM=14428
# ...
#
# To run the tests use:
#   export $(grep -v '^#' .env | xargs -d '\n') >/dev/null && ./test-slack-message.sh


SLACK_API_URL="https://slack.com/api"
VCS_URL="github.com"
SHORT_SHA=$(echo "${CIRCLE_SHA1}" | cut -c1-7)
FAIL_COLOUR="#ae2d2d"
PASS_COLOUR="#38ae2d"

if [ "$BUILD_RESULT" == "success" ]; then
  COLOUR=${PASS_COLOUR}
else
  COLOUR=${FAIL_COLOUR}
fi

LOOKUP_RESULT=$(curl -s -H 'Content-type: application/x-www-form-urlencoded' "${SLACK_API_URL}/users.lookupByEmail?token=${SLACK_BOT_TOKEN}&email=${AUTHOR_EMAIL}")
SUCCESS=$(echo "$LOOKUP_RESULT" | jq ".ok")
if [[ "$SUCCESS" == "true" && "$CIRCLE_BRANCH" != "master" ]]; then
  USER_ID=$(echo "$LOOKUP_RESULT" | jq -r ".user.id")
  CHANNEL=$USER_ID
  MENTION="@${USER_ID} "
else
  echo "Couldn't find user with the email ${AUTHOR_EMAIL}. Your email in Github must match your email in slack."
  echo "Response: ${LOOKUP_RESULT}"
  CHANNEL=staging-deploy
fi

echo "Sending message to ${CHANNEL}"
SEND_RESULT=$(curl -s -X POST -H 'Content-type: application/x-www-form-urlencoded' --data \
"token=${SLACK_BOT_TOKEN}&\
channel=${CHANNEL}&\
text=Your CircleCI build ${BUILD_RESULT}.&\
attachments=[{\
    \"fallback\": \"Your CircleCI build ${BUILD_RESULT}. ${CIRCLE_BUILD_URL}\", \
    \"author_name\": \"${SHORT_SHA}\", \
    \"author_link\": \"https://${VCS_URL}/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/commit/${CIRCLE_SHA1}\", \
    \"title\": \"CircleCI Build ${BUILD_RESULT}\", \
    \"title_link\": \"${CIRCLE_BUILD_URL}\", \
    \"fields\": [ \
      { \
        \"title\": \"Project\", \
        \"value\": \"${CIRCLE_PROJECT_REPONAME}\", \
        \"short\": true \
      }, \
      { \
        \"title\": \"Job Number\", \
        \"value\": \"${CIRCLE_BUILD_NUM}\", \
        \"short\": true \
      }, \
      { \
        \"title\": \"Branch\", \
        \"value\": \"${CIRCLE_BRANCH}\", \
        \"short\": true \
      }, \
      { \
        \"title\": \"Stage\", \
        \"value\": \"${CIRCLE_STAGE}\", \
        \"short\": true \
      } \
    ], \
    \"color\": \"${COLOUR}\", \
    \"footer\": \"Commit Orb\", \
    \"footer_icon\": \"https://commit.dev/favicon.ico\", \
  }]" \
"${SLACK_API_URL}/chat.postMessage?token=${SLACK_BOT_TOKEN}")
SUCCESS=$(echo "$SEND_RESULT" | jq ".ok")
if [ "$SUCCESS" == "true" ]; then
  echo "Message sent to user."
else
  echo "Error sending message to user. ${SEND_RESULT}"
fi
