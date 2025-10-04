#!/bin/bash

# Test script to demonstrate CI/CD detection for GitHub CLI tests
# This script shows how GitHub CLI tests behave in different environments

echo "🧪 Testing CI/CD Detection for GitHub CLI Tests"
echo "================================================"

# Source the CI/CD detection function
is_ci_environment() {
    # Check for custom override first - if WQS_CI_MODE=0, never detect CI
    if [[ "${WQS_CI_MODE:-}" == "0" ]]; then
        return 1  # Not CI environment (override)
    fi

    # Check common CI/CD environment variables
    [[ -n "${CI:-}" ]] || \
    [[ -n "${CONTINUOUS_INTEGRATION:-}" ]] || \
    [[ -n "${GITHUB_ACTIONS:-}" ]] || \
    [[ -n "${GITLAB_CI:-}" ]] || \
    [[ -n "${JENKINS_URL:-}" ]] || \
    [[ -n "${TRAVIS:-}" ]] || \
    [[ -n "${CIRCLECI:-}" ]] || \
    [[ -n "${AZURE_PIPELINES:-}" ]] || \
    [[ -n "${BUILDKITE:-}" ]] || \
    [[ -n "${DRONE:-}" ]] || \
    [[ -n "${TEAMCITY_VERSION:-}" ]] || \
    [[ -n "${APPVEYOR:-}" ]] || \
    [[ -n "${CODEBUILD_BUILD_ID:-}" ]]
}

# Test 1: Normal local environment
echo "Test 1: Local Development Environment"
if is_ci_environment; then
    echo "❌ FAIL: Detected CI/CD in local environment"
else
    echo "✅ PASS: Local environment detected correctly"
fi
echo

# Test 2: Simulate GitHub Actions
echo "Test 2: GitHub Actions Environment"
GITHUB_ACTIONS=true
if is_ci_environment; then
    echo "✅ PASS: GitHub Actions CI/CD detected correctly"
else
    echo "❌ FAIL: GitHub Actions not detected"
fi
unset GITHUB_ACTIONS
echo

# Test 3: Simulate GitLab CI
echo "Test 3: GitLab CI Environment"
GITLAB_CI=true
if is_ci_environment; then
    echo "✅ PASS: GitLab CI detected correctly"
else
    echo "❌ FAIL: GitLab CI not detected"
fi
unset GITLAB_CI
echo

# Test 4: Simulate generic CI
echo "Test 4: Generic CI Environment"
CI=true
if is_ci_environment; then
    echo "✅ PASS: Generic CI detected correctly"
else
    echo "❌ FAIL: Generic CI not detected"
fi
unset CI
echo

# Test 5: Custom override
echo "Test 5: Custom Override (WQS_CI_MODE=0)"
GITHUB_ACTIONS=true
WQS_CI_MODE=0
if is_ci_environment; then
    echo "❌ FAIL: Override not working (should skip CI detection)"
else
    echo "✅ PASS: Custom override working correctly"
fi
unset GITHUB_ACTIONS WQS_CI_MODE
echo

# Test 6: Show what happens in each environment
echo "Test 6: GitHub CLI Test Behavior Simulation"
echo "-------------------------------------------"

simulate_github_cli_test() {
    local env_name="$1"
    echo "Environment: $env_name"

    if is_ci_environment; then
        echo "  → GitHub CLI tests: SKIPPED (CI/CD detected)"
        echo "  → Message: 'Skipping GitHub CLI tests (CI/CD environment detected)'"
    else
        echo "  → GitHub CLI tests: RUNNING (Local development)"
        echo "  → Tests: Installation, authentication, scripts, configuration"
    fi
    echo
}

# Local development
simulate_github_cli_test "Local Development"

# GitHub Actions
GITHUB_ACTIONS=true
simulate_github_cli_test "GitHub Actions"
unset GITHUB_ACTIONS

# Jenkins
JENKINS_URL=http://jenkins.example.com
simulate_github_cli_test "Jenkins"
unset JENKINS_URL

echo "🎉 All CI/CD detection tests completed!"
echo
echo "Summary:"
echo "- ✅ Local environments run all GitHub CLI tests"
echo "- ✅ CI/CD environments automatically skip GitHub CLI tests"
echo "- ✅ Custom override (WQS_CI_MODE=0) forces tests in CI/CD"
echo "- ✅ No interference with CI/CD pipelines"
