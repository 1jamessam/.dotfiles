# Dagster GraphQL Queries for Debugging

## 1. Get Run Overview

Returns run status, timing, pipeline name, tags (including failure reason, image, schedule).

```graphql
query GetRunOverview($runId: String!) {
  runOrError(runId: $runId) {
    __typename
    ... on Run {
      runId
      status
      startTime
      endTime
      pipelineName
      tags { key value }
    }
    ... on RunNotFoundError { message }
  }
}
```

**curl:**
```bash
curl -s $DAGSTER_GQL/graphql -H 'Content-Type: application/json' -d '{
  "query": "{ runOrError(runId: \"RUN_ID\") { __typename ... on Run { runId status startTime endTime pipelineName tags { key value } } ... on RunNotFoundError { message } } }"
}'
```

## 2. Get Full Event Log

Returns all events for a run: step starts, failures, log messages, engine events.

```graphql
query GetRunEvents($runId: String!) {
  runOrError(runId: $runId) {
    __typename
    ... on Run {
      eventConnection(afterCursor: null) {
        events {
          __typename
          ... on MessageEvent {
            timestamp
            message
            stepKey
          }
          ... on ExecutionStepFailureEvent {
            stepKey
            error {
              message
              stack
              causes { message }
            }
          }
          ... on RunFailureEvent {
            error {
              message
              stack
            }
          }
          ... on EngineEvent {
            error {
              message
              stack
            }
          }
        }
      }
    }
  }
}
```

**curl:**
```bash
curl -s $DAGSTER_GQL/graphql -H 'Content-Type: application/json' -d '{
  "query": "{ runOrError(runId: \"RUN_ID\") { __typename ... on Run { eventConnection(afterCursor: null) { events { __typename ... on MessageEvent { timestamp message stepKey } ... on ExecutionStepFailureEvent { stepKey error { message stack causes { message } } } ... on RunFailureEvent { error { message stack } } ... on EngineEvent { error { message stack } } } } } } }"
}'
```

## 3. List Recent Failed Runs

```graphql
query RecentFailures {
  runsOrError(filter: { statuses: [FAILURE] }, limit: 5) {
    __typename
    ... on Runs {
      results {
        runId
        status
        startTime
        endTime
        pipelineName
        tags { key value }
      }
    }
  }
}
```

**curl:**
```bash
curl -s $DAGSTER_GQL/graphql -H 'Content-Type: application/json' -d '{
  "query": "{ runsOrError(filter: { statuses: [FAILURE] }, limit: 5) { __typename ... on Runs { results { runId status startTime endTime pipelineName tags { key value } } } } }"
}'
```

## 4. List Runs for a Specific Job

```bash
curl -s $DAGSTER_GQL/graphql -H 'Content-Type: application/json' -d '{
  "query": "{ runsOrError(filter: { pipelineName: \"JOB_NAME\" }, limit: 10) { __typename ... on Runs { results { runId status startTime endTime tags { key value } } } } }"
}'
```

## 5. Get Run Step Stats

```graphql
query GetStepStats($runId: String!) {
  runOrError(runId: $runId) {
    __typename
    ... on Run {
      stepStats {
        stepKey
        status
        startTime
        endTime
        attempts {
          startTime
          endTime
          status
        }
      }
    }
  }
}
```

## 6. Schedule Dry Run

Test what a schedule would produce without executing it.

```graphql
mutation ScheduleDryRun(
  $scheduleName: String!
  $locationName: String!
  $repositoryName: String!
  $timestamp: Float!
) {
  scheduleDryRun(
    selectorData: {
      scheduleName: $scheduleName
      repositoryLocationName: $locationName
      repositoryName: $repositoryName
    }
    timestamp: $timestamp
  ) {
    ... on DryRunInstigationTick {
      evaluationResult {
        runRequests {
          jobName
          runConfigYaml
          tags { key value }
        }
        error { message stack }
      }
    }
    ... on PythonError { message stack }
    ... on ScheduleNotFoundError { message }
  }
}
```

## Tips

- Always pipe through `python3 -m json.tool` for readable output
- Set `DAGSTER_GQL` to the base URL (e.g. `http://localhost:3333`)
- For production: use `HTTPS_PROXY="http://localhost:8888" kubectl -n dagster port-forward pod/<webserver-pod> 3333:80` (forward to the **pod**, not the svc — the svc goes through the oauth2-proxy sidecar)
- **Timestamp units differ by field — do not assume.**
  - `Run.startTime` / `Run.endTime` (query #1): Unix **seconds** as a float (e.g. `1776744531.103277`). Run duration = `endTime - startTime` seconds directly.
  - Event `timestamp` on `MessageEvent`/etc. (query #2): Unix **milliseconds** as a string (e.g. `"1776751673683"`). Divide by 1000 for seconds.
- Key tags: `dagster/failure_reason`, `dagster/schedule_name`, `dagster/partition`, `dagster/image`
