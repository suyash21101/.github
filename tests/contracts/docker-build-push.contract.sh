#!/usr/bin/env bash
source "$(dirname "$0")/_assert.sh"
F=".github/workflows/docker-build-push.yml"

echo "contract: docker-build-push"
test -f "$F" || { echo "  FAIL: $F does not exist"; exit 1; }

# Required inputs
assert_contains "$F" 'ecr_repository:' "declares ecr_repository input"
assert_contains "$F" 'role_to_assume:' "declares role_to_assume input"
assert_contains "$F" 'aws_region:' "declares aws_region input"
assert_contains "$F" 'dockerfile:' "declares dockerfile input"
# OIDC, no static keys
assert_contains "$F" 'id-token: write' "requests OIDC id-token"
assert_contains "$F" 'aws-actions/configure-aws-credentials@v4' "uses OIDC credential action"
assert_contains "$F" 'aws-actions/amazon-ecr-login@v2' "logs into ECR"
assert_contains "$F" 'docker/build-push-action@v6' "builds & pushes via buildx action"
assert_contains "$F" 'provenance: false' "disables provenance attestation (ECR compatibility)"
assert_contains "$F" 'build_args:' "declares build_args input"
# sha-<commit> default tag + outputs
assert_contains "$F" 'sha-' "defaults image tag to sha-<commit>"
assert_contains "$F" 'image_uri:' "exposes image_uri output"

done_ok
