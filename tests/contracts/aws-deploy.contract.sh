#!/usr/bin/env bash
source "$(dirname "$0")/_assert.sh"
F=".github/workflows/aws-deploy.yml"

echo "contract: aws-deploy"
test -f "$F" || { echo "  FAIL: $F does not exist"; exit 1; }

# New inputs for ECS
assert_contains "$F" 'cluster:' "declares cluster input"
assert_contains "$F" 'service:' "declares service input"
assert_contains "$F" 'image:' "declares image input"
# Three modes documented
assert_contains "$F" 'amplify \| fargate \| fargate-leader' "documents all three modes"
# Django, not Prisma, drives migrations on the fargate path
assert_contains "$F" 'manage.py migrate' "runs Django migrations"
# Real ECS deploy actions (no placeholder)
assert_contains "$F" 'amazon-ecs-render-task-definition' "renders new task-def revision"
assert_contains "$F" 'amazon-ecs-deploy-task-definition' "deploys + waits for steady-state"
assert_contains "$F" 'aws ecs run-task' "runs one-shot migration task"
assert_contains "$F" 'setup-node' "setup-node present for amplify npm ci path"
# The old placeholder must be gone
assert_absent  "$F" 'Fargate deploy not yet implemented' "no fargate placeholder remains"
# fargate-leader handled
assert_contains "$F" 'fargate-leader' "handles fargate-leader mode"
# fargate-leader must NOT trigger the migration step: the migration step's guard
# is mode == 'fargate' (exact), never fargate-leader.
assert_contains "$F" "inputs.mode == 'fargate' && inputs.migrate" "migration guarded to fargate (not leader)"
assert_absent  "$F" "inputs.mode == 'fargate-leader' && inputs.migrate" "leader never migrates"

done_ok
