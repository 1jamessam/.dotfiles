---
name: dagster-ops
description: >
  Investigate and fix failed Dagster pipeline runs. Use when given a Jira ticket, Dagster run ID, or
  description of a pipeline failure. Connects to Dagster GraphQL (local or production via kubectl),
  pulls run logs, diagnoses root causes, and suggests or applies fixes.
  Trigger on: failed run, pipeline error, Dagster alert, DTS ticket, dagster run URL.
argument-hint: "<jira-ticket-or-run-id>"
---

# Dagster Pipeline Ops: Monitor, Debug & Fix

You are a Dagster pipeline operations expert. Given a failed run reference (Jira ticket, run ID, or
Dagster URL), you investigate the failure end-to-end and either fix it or produce a clear diagnosis.

## Input

`$ARGUMENTS` can be any of:
- A **Jira ticket** key (e.g. `DTS-2833`) or URL
- A **Dagster run ID** (UUID like `7ce6f5dc-1a37-4a82-ac7a-983373d1df7e`)
- A **Dagster run URL** (e.g. `https://dagster.rentspree.dev/runs/...`)
- A **description** of the problem (e.g. "rental listings pipeline failed last night")

## Workflow

Execute these phases in order. Skip phases that don't apply.

### Phase 1: Gather Context

**If Jira ticket provided:**
1. Fetch the ticket using the Atlassian MCP tool (`getJiraIssue` with `responseContentFormat: markdown`)
2. Extract: summary, description, Dagster run URLs, DoD items, assignee
3. Note any linked tickets or referenced Slack threads

**If Dagster URL provided:**
Extract the run ID from the URL path: `/runs/<run-id>`

**If description provided:**
Search Slack and Jira for recent mentions to find the run ID.

### Phase 2: Access Dagster Run Logs

Try these methods in order until one works:

**Method A: Local dagster dev (port 3000)**
```bash
curl -s http://localhost:3000/graphql -H 'Content-Type: application/json' \
  -d '{"query": "{ version }"}'
```

**Method B: GKE cluster via kubectl port-forward**

**Step 1: Determine the correct cluster.** Prefer inferring from the Dagster URL:

| URL host | Environment | Cluster / bastion |
|----------|-------------|-------------------|
| `dagster-np.rentspree.dev` | non-prod (dev) | dev cluster + non-prod bastion |
| `dagster.rentspree.dev`    | prod           | prod cluster + prod bastion |

If only a run ID or description was given (no URL), ask the user. "dagster dev" run locally
= dev cluster, production/scheduled runs = prod cluster.

```bash
kubectl config current-context
# Available contexts:
#   gke_prj-data-dev-429603_us-west1-a_data-dev-cluster   (dev)
#   gke_prj-data-prod-429603_us-west1-a_data-prod-cluster (prod)
# Switch if needed:
kubectl config use-context gke_prj-data-dev-429603_us-west1-a_data-dev-cluster
```

**Step 2: Ensure bastion tunnel is up.**

The bastion depends on the cluster. Both tunnel to local port `8888`, so only one can be
active at a time — switching clusters mid-session requires killing the existing tunnel.

| Cluster | Bastion | Project |
|---------|---------|---------|
| dev (non-prod) | `rentspree-us-west1-a-infra-non-prod-bastion-1` | `prj-infra-non-prod-429603` |
| prod | `rentspree-us-west1-a-infra-prod-bastion-1` | `prj-infra-prod-429603` |

Zone for both: `us-west1-a`.

**Auto-start flow (preferred):**

1. Check if port `8888` is already listening:
   ```bash
   nc -z localhost 8888 && echo UP || echo DOWN
   ```
   If `UP`, reuse it (see "switching clusters" below if downstream kubectl calls fail).

2. If `DOWN`, launch the tunnel **in the background** using Claude Code's
   `run_in_background: true` Bash option (not shell `&`, so the process is tracked):

   DEV:
   ```bash
   gcloud compute ssh rentspree-us-west1-a-infra-non-prod-bastion-1 \
     --tunnel-through-iap --project prj-infra-non-prod-429603 --zone us-west1-a \
     -- -N -L8888:127.0.0.1:8888
   ```
   PROD:
   ```bash
   gcloud compute ssh rentspree-us-west1-a-infra-prod-bastion-1 \
     --tunnel-through-iap --project prj-infra-prod-429603 --zone us-west1-a \
     -- -N -L8888:127.0.0.1:8888
   ```

3. Poll for up to ~20s for the port to open:
   ```bash
   for i in $(seq 1 20); do nc -z localhost 8888 && break; sleep 1; done
   nc -z localhost 8888 && echo READY || echo FAILED
   ```

4. Also check the background process is still alive (via BashOutput on the task id). If the
   gcloud process exited early, it almost certainly hit an interactive prompt (IAP consent,
   SSH key passphrase, `gcloud auth login` needed) — fall back to manual.

**Manual fallback** (if auto-start times out or the background process exits):

Ask the user to run the matching command above in a separate terminal (without `-N` if they
want an interactive session), then continue once `nc -z localhost 8888` succeeds.

**Switching clusters mid-session:** if the tunnel is up but points to the wrong bastion
(downstream kubectl calls fail with connection/cert errors despite port being open):
```bash
lsof -ti:8888 | xargs kill -9
```
then re-run the auto-start flow with the correct bastion.

**Step 3: Port-forward to the webserver pod.**
IMPORTANT: The webserver pod has an oauth2-proxy sidecar (port 4180). Forwarding to the
**service** goes through the proxy and returns 302 redirects to Google OAuth. You must forward
to the **pod** directly, targeting the `dagster-service` container on port 80.

Run the port-forward **in the background** via Claude Code's `run_in_background: true` Bash
option (not shell `&`) so the process is tracked and can be cleanly killed by task id:

```bash
# 1. Free local port 3333
lsof -ti:3333 | xargs kill -9 2>/dev/null

# 2. Find the webserver pod (pod name changes on every rollout — always re-resolve)
HTTPS_PROXY="http://localhost:8888" kubectl -n dagster get pods --no-headers | grep webserver
```

Launch this as a backgrounded Bash task (`run_in_background: true`):
```bash
HTTPS_PROXY="http://localhost:8888" kubectl -n dagster port-forward pod/<WEBSERVER_POD_NAME> 3333:80
```

Then poll until 3333 is ready and verify the GraphQL endpoint:
```bash
for i in $(seq 1 10); do nc -z localhost 3333 && break; sleep 1; done
curl -s http://localhost:3333/graphql -H 'Content-Type: application/json' \
  -d '{"query": "{ version }"}'
# expect: {"data":{"version":"..."}}
```
If you get a 302 redirect or HTML instead of JSON, you're hitting the oauth proxy — forward
to the pod, not the svc.

**Method C: If no access**, ask the user to provide logs or set up access.

### Phase 3: Query Run Details

IMPORTANT: Use the **exact curl commands** from [graphql-queries.md](./references/graphql-queries.md).
Do NOT improvise GraphQL queries — the Dagster schema has non-obvious types (e.g. event logs
are at `runOrError.eventConnection.events`, not `logsForRun.nodes`).

**Step 1:** Get run overview — query #1 from reference (status, timing, tags, failure reason)
**Step 2:** Get full event log — query #2 from reference, then filter with jq:
```bash
| jq '[.data.runOrError.eventConnection.events[] | select(.__typename == "ExecutionStepFailureEvent" or .__typename == "RunFailureEvent")]'
```
**Step 3:** Identify the exact step that failed and the root cause from `error.causes[].message`

### Phase 4: Diagnose Root Cause

Analyze the error against these common failure patterns:

| Pattern | Error Signature | Likely Cause |
|---------|----------------|--------------|
| **Partition mismatch** | `Cannot access partition_key for a non-partitioned run` | Schedule not partition-aware; missing `partition_def` in schedule builder |
| **Missing credentials** | `ValueError: ...must be set` or `SecretNotFound` | Env vars or GCP secrets not configured |
| **API failure** | `ConnectionError`, `Failure`, rate limit messages | External API down or rate-limited |
| **Token expiry** | `Token has expired`, 401 | Auth token refresh failed |
| **Schema mismatch** | `BigQuery` errors, column not found | BQ schema out of sync with pipeline |
| **OOM / timeout** | Pod killed, step timeout | Increase resource requests or batch size |
| **Import error** | `ModuleNotFoundError` | Missing dependency or wrong Python version |
| **Recipe config** | `PipelineInitError`, `ValidationError for *Config` | Invalid recipe YAML value (e.g. Pydantic constraint violation). Check connector docs for valid ranges/types |
| **DNS / connection** | `ServerSelectionTimeoutError`, `dns.resolver.NoNameservers` | Database unreachable from K8s pod (wrong URI, missing network access, DNS resolution) |

For each diagnosis:
1. Read the failing code file to understand what the step does
2. Trace the error to the exact line
3. Check git history for recent changes that might have caused the issue
4. Search Slack for related discussions about the failure

### Phase 5: Fix or Recommend

**If the fix is clear and safe:**
1. Implement the fix in the codebase
2. Run tests (`pytest`) to verify
3. Summarize what was changed and why

**If the fix requires discussion:**
1. Document the root cause clearly
2. List possible fixes with trade-offs
3. Recommend the best approach

**If the fix is in an external system (infra, config, credentials):**
1. Document what needs to change and where
2. Provide exact commands or config snippets
3. Tag the responsible team

### Phase 6: Verify DD Coverage (DoD item if applicable)

Check whether the failure would be caught by monitoring:
1. Did Dagster mark the run as FAILURE? (Check run status)
2. Is there a Datadog monitor for this pipeline/job?
3. If the run succeeded despite data issues (silent failure), flag this as a monitoring gap

## Output Format

Always produce a structured summary:

```
## Diagnosis: <one-line summary>

**Run:** <run-id>
**Status:** <SUCCESS|FAILURE>
**Failed Step:** <step name>
**Duration:** <time>
**Partition:** <partition key if any>

### Root Cause
<Clear explanation of what went wrong and why>

### Error
<Key error message and relevant stack trace lines>

### Fix
<What was done or what needs to be done>

### Monitoring
<Whether DD/alerting would catch this, and any gaps>
```

## Important Notes

- Always clean up the `kubectl port-forward` on 3333 after use: `lsof -ti:3333 | xargs kill -9` and restore kubectl context if switched. The bastion tunnel on 8888 can usually be left running between invocations (saves re-auth) — only kill it when switching between dev and prod bastions.
- Never modify production systems without explicit user approval
- If a run is still in progress, report current status and offer to poll
- For recurring failures, check if there's a pattern across recent runs
- For recipe-based pipeline errors (`PipelineInitError`), check connector Pydantic config constraints — some fields reject 0 or null even when docs suggest they're valid for "unlimited"
