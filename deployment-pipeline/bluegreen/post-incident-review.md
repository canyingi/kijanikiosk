# Post-Incident Review: Pipeline Deployed to the Live Staging Environment During Investor Demonstration

| | |
|---|---|
| Severity | Moderate (staging, customer-visible during a demonstration) |
| Duration of unavailability | 48 seconds |
| Review format | Blameless |
| Author | Amina (platform engineering) |

> **Note on timestamps.** No timestamped logs were kept from the incident itself. Times below are reconstructed from the incident narrative and are marked *(estimated)* with the basis for each estimate. The 48-second duration is the only figure stated directly in the original report.

---

## 1. Incident summary

During an investor demonstration, a release was sent to the copy of the staging site that was already serving visitors, instead of to the idle standby copy. That copy restarted, and the site could not be reached for 48 seconds before it recovered on its own. No customer data was affected, but the outage happened in front of investors and would have caused failed payments if it had been production.

---

## 2. Timeline

| Time | Event | Basis |
|---|---|---|
| 09:00 *(estimated, ±5 min)* | Investor walkthrough of the staging site begins. | Narrative: the pipeline was run during the demonstration, after it had started. |
| 09:15 *(estimated, ±2 min)* | Engineer triggers the deployment pipeline to show a new release being delivered. | Narrative places the trigger mid-demonstration. |
| 09:15 *(estimated, same minute as trigger)* | Pipeline deploys to the environment that is currently live (the target was set to the active side, not the idle side). | The deploy step runs immediately after trigger; no approval step existed. |
| 09:16 *(estimated, ±1 min)* | The live service restarts; the proxy begins returning errors to visitors, including the demonstration screen. | Narrative states errors appeared within a minute of the trigger. |
| 09:16 + ~10 s *(estimated)* | Error noticed by the presenter on the demonstration screen. | Visible immediately because the investor walkthrough was on that site. |
| 09:16 + 48 s *(derived)* | Service finishes restarting on the new version and answers again; the proxy stops returning errors. | 48 s of unavailability is the stated figure. |
| 09:18 *(estimated, ±2 min)* | Engineer confirms the site is serving normally and the demonstration continues. | Narrative: service recovered without manual rollback. |

---

## 3. Root cause

**Starting point (the gap):** the pipeline let the target environment be supplied as an input, and nothing compared that input with the environment actually serving traffic.

1. **Why did the release hit the live environment?**
   The deploy step was told to deploy to the side that was currently active. The target environment was a parameter (`DEPLOY_ENV`), set by the person running the pipeline or left at its default.
2. **Why was a wrong value accepted?**
   The deploy script trusted the parameter. It did not read the recorded state (`.active-env`) and had no rule saying "never deploy to the active side".
3. **Why did the script have no such rule?**
   In the blue/green design, the state files are only *written* by the traffic switch and never *read* by the deploy step. Deploy and switch were built as independent tools, so the deploy step had no knowledge of which side was live.
4. **Why was that split never challenged?**
   The process assumed the operator always knows which side is live. Every earlier run was done by someone who had just performed the previous switch and so knew the state; the first time the pipeline was run by someone without that context, in a hurry, during a demo, the assumption failed.
5. **Why was there no other safety net?**
   There was no pre-flight step that displays "target vs. live" and asks for confirmation, and staging had no "do not deploy" period during demonstrations.

**Structural finding:** the system relied on a person to supply information (which environment is idle) that the system already recorded. Safety depended on human memory instead of on the state file that existed for exactly this purpose.

---

## 4. Contributing factors

- **Default parameter value.** The target environment had a default that was correct at the time it was written but not after the next switch, so "accept the default" silently became "deploy to live".
- **No approval or confirmation step.** The pipeline went from trigger to deployment without showing the operator where it was about to deploy.
- **Demonstration on a shared environment.** The investor demonstration used the same staging environment the pipeline deploys to, with no lock or freeze during the session.
- **Deploying causes a restart, not a hot swap.** Deploying restarts the service, so deploying to the live side always produces an outage; the blue/green design only protects traffic if the idle side is the target.
- **Time pressure.** The pipeline was run live in front of an audience, which discourages pausing to check state.

---

## 5. What went well

- **The service recovered by itself in 48 seconds.** The restart completed and the new version passed its health check without anyone needing to intervene.
- **The problem was seen immediately** because the demonstration screen was on the affected site, so there was no delay between failure and awareness.
- **The other environment was untouched.** Because blue/green keeps two copies, the idle copy was still on the previous version and would have been available for a switch-back if the restart had failed.
- **The incident was reported openly**, which is what made this review and the fixes below possible.

---

## 6. Action items

| # | Owner (role) | Change | Target |
|---|---|---|---|
| 1 | Platform engineer | **Deploy script refuses to deploy to the active environment.** `deploy-app.sh` reads `.active-env` and exits with an error if `DEPLOY_ENV` matches it. *Status: implemented in the staging scripts and verified (deploying to the live side is now rejected with "refusing to deploy over live traffic"). Must be added to the pipeline's deploy stage.* | 1 week |
| 2 | Pipeline owner | **Pipeline computes the target instead of accepting it.** Remove the `DEPLOY_ENV` parameter and its default; the pipeline reads `.active-env` and deploys to the other side. | 2 weeks |
| 3 | Pipeline owner | **Pre-switch confirmation stage.** Before switching traffic, the pipeline prints "live: X, deploying to: Y, version: Z" and waits for an approval click. | 2 weeks |
| 4 | Engineering lead | **Demonstration lock for staging.** A lock file (`/opt/kijanikiosk/.demo-lock`) is created before any external demonstration; the pipeline exits without deploying while it exists. Add "create lock" to the demonstration preparation checklist. | 1 week |
| 5 | Platform engineer | **Automated rollback watcher after every switch.** Run the post-deploy monitor after each traffic switch so a failed release is reversed automatically. *Status: implemented and measured, fault to recovery in 14 seconds.* | Done; add to pipeline in 2 weeks |
