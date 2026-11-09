# kk-payments: Service Level Indicators and Objectives

**Status:** proposed targets (not yet measured against production traffic).
The blue/green rollback evidence in this folder was produced on a local staging environment (one laptop, nginx in front of two copies of a small test service on ports 3000 and 3001). The rollback numbers below are real measurements from that environment; the 30-day targets are proposals to be validated once production traffic data exists.

---

## 1. Service Level Indicators

### SLI 1: Availability

| Field | Specification |
|---|---|
| What it measures | The proportion of requests to kk-payments that are answered successfully. |
| Good event | A request to `/payments/*` or `/health` that returns any status **below 500**. |
| Bad event | A request that returns **5xx** (including nginx `502`/`504` when the upstream is down or times out), or a health probe that gets no response within 2 seconds. |
| Excluded | `429` (client throttled) and `4xx` caused by bad client input: these are correct answers, not outages. |
| Data source | nginx access log on the proxy (`$status`, `$request_uri`, `$upstream_addr`), plus the post-deploy monitor's health probe (`GET http://127.0.0.1:80/health` every 5 s, 2 s timeout). |
| Calculation | `good requests / total requests` over the window. Health-probe results are tracked separately as a fast signal for rollback, not mixed into the request ratio. |
| Measurement window | Rolling 30 days for the SLO; 1-minute and 5-minute windows for alerting and rollback. |

### SLI 2: Latency

| Field | Specification |
|---|---|
| What it measures | The proportion of payment requests answered fast enough for a customer at checkout. |
| Good event | A `/payments/*` request with **upstream response time < 300 ms**. |
| Bad event | A `/payments/*` request with upstream response time ≥ 300 ms, or one that times out. |
| Data source | nginx access log with `$upstream_response_time` added to the log format (to be built: the current default log format does not record it). |
| Calculation | `count(upstream_response_time < 0.300) / count(all /payments/* requests)`. Only requests that reached the service count; requests rejected at the proxy are covered by SLI 1. |
| Measurement window | Rolling 30 days; 5-minute window for rollback. |

### SLI 3: Payment error rate

| Field | Specification |
|---|---|
| What it measures | The proportion of payment submissions that kk-payments itself fails to process. |
| Bad event | A payment submission (`POST /payments`) that ends in a server-side failure: `5xx`, or an application result of `error` (for example the service cannot reach its database). |
| Not an error | A payment **declined** by the customer's bank or mobile-money provider. That is a correct outcome, not a service failure. |
| Data source | Application payment-result log line, or a metrics counter `payments_total{result="success|declined|error"}` (to be built). |
| Calculation | `payments_total{result="error"} / payments_total` (all results). |
| Measurement window | Rolling 30 days; 5-minute window for rollback, with a minimum of 20 payment attempts before the ratio is trusted. |

---

## 2. SLO targets (30-day window)

| SLI | Target (proposed) | Error budget over 30 days | What the budget means in practice |
|---|---|---|---|
| Availability | **≥ 99.9%** of requests succeed | 0.1% of requests | ≈ 43 minutes of total outage, or ≈ 36,000 failed requests at 50,000 requests/hour |
| Latency | **≥ 99%** of payment requests < 300 ms | 1% of payment requests | Slow requests are tolerated in short bursts, not as a steady state |
| Payment error rate | **≤ 0.5%** of payment submissions fail | 0.5% of submissions | At most 1 in 200 payment attempts fails because of us |

All three are labelled **proposed target (not yet measured against production traffic)**. They should be revisited after 30 days of real data: a target that is never at risk is too loose, and one that is always breached is not useful.

---

## 3. Rollback threshold table

Rollback thresholds are deliberately much stricter than the 30-day targets: the question during a release is not "have we missed the month?" but "is this new version burning budget far faster than normal?"

| SLI | Short-window threshold that triggers automated rollback | Relationship to the SLO target |
|---|---|---|
| Availability | **3 consecutive failed health probes, 5 s apart** (≈ 15 s of failure). *Implemented and measured:* fault detected 12 s after it started, traffic back on the previous version 14 s after it started. | A full outage burns the 30-day budget (≈ 43 min) at 100% failure, so every minute matters: 15 s of failure costs ≈ 0.6% of the monthly budget. Requiring 3 failures (not 1) avoids rolling back on a single dropped probe. |
| Availability (request-based, to build) | **5xx ratio > 1.44% over 5 minutes** | 1.44% is **14.4×** the 0.1% budget rate: if sustained for an hour it consumes 2% of the 30-day budget. This catches partial failures that health probes miss (the service is up but failing some requests). |
| Latency (to build) | **> 10% of payment requests ≥ 300 ms over 5 minutes** | 10× the 1% allowance. A new version that is this slow would exhaust the monthly latency budget in about 3 days. |
| Payment error rate (to build) | **> 5% of payment submissions fail over 5 minutes, with at least 20 attempts** | 10× the 0.5% budget. The 20-attempt minimum prevents a rollback when 1 of 3 early requests fails. |

Only the first row is implemented today (`post-deploy-monitor.sh`: 5 s interval, 2 s timeout, threshold 3, 60 s confidence window). The other rows are the specification for the next iteration of the monitor once the access log and payment counters exist.

---

## 4. What we do not commit to

- **Third-party payment provider response time.** The time a bank or mobile-money provider takes to approve a payment is outside our control; we measure only the time our own service takes.
- **Page load time in the customer's browser.** It depends on the customer's device and network, which nginx cannot observe, so we do not set a target for it.
- **Declined payments.** A payment declined for insufficient funds is a correct answer from the system and does not count against the error rate.
- **Availability of the staging environment.** These objectives apply to production only; staging may be interrupted for testing, as the rollback exercise deliberately did.
