#!/bin/bash

function terragruntPlanCheck {
  # Gather the output of `terragrunt plan`.
  echo "plan: info: planning Terragrunt configuration in ${tfWorkingDir}"
  planOutput=$(${tfBinary} plan -detailed-exitcode -input=false ${*} 2>&1)
  planExitCode=${?}
  planHasChanges=false
  planCommentStatus="Failed"
  slackColor="ffcc00"
  slackMessage=""
  planResult=$(echo "${planOutput}" | grep 'Plan')
  echo ${github.event}

  # Exit code of 0 indicates success with no changes. Print the output and exit.
  if [ ${planExitCode} -eq 0 ]; then
    echo "plan: info: successfully planned Terragrunt configuration in ${tfWorkingDir}"
    echo "${planOutput}"
    echo
    echo ::set-output name=tf_actions_plan_has_changes::${planHasChanges}
    exit ${planExitCode}
  fi

  # Exit code of 2 indicates success with changes. Print the output, change the
  # exit code to 0, and mark that the plan has changes.
  if [ ${planExitCode} -eq 2 ]; then
    planExitCode=0
    planHasChanges=true
    planCommentStatus="Success"
    slackMessage="Sheduled pipeline on *${tfWorkingDir}* has changes \n${planResult}"
    echo "plan: info: successfully planned Terragrunt configuration in ${tfWorkingDir}"
    echo "${planOutput}"
    echo

  fi

  # Exit code of !0 indicates failure.
  if [ ${planExitCode} -ne 0 ]; then
    slackColor="d80000"
    slackMessage="Sheduled pipeline on *${tfWorkingDir}* finished with *fails* \nPlease see GitHub Action logs"
    echo "plan: error: failed to plan Terragrunt configuration in ${tfWorkingDir}"
    echo "${planOutput}"
    echo

  fi

  # Comment on the pull request if necessary.
  if [ "${planHasChanges}" == "true" ] || [ "${planCommentStatus}" == "Failed" ]; then
    cat ${GITHUB_EVENT_PATH} | jq
    
    SLACK_TITLE="GitHub" \
    SLACK_TITLE_LINK="https://github.com" \
    SLACK_COLOR="${slackColor}" \
    SLACK_TEXT="Sheduled pipeline on *${tfWorkingDir}* finished with *fails*" \
    SLACK_CHANNEL="${SLACK_CHANNEL}" \
    SLACK_USERNAME="GitHub" \
    SLACK_URL="${SLACK_URL}" \
    SLACK_ICON="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" \
    notifySlack

  fi

  echo ::set-output name=tf_actions_plan_has_changes::${planHasChanges}
  echo "::set-output name=tf_actions_plan_output::${planOutput}"
  exit ${planExitCode}
}
