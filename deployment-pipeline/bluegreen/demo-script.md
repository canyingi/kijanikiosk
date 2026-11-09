# Board Demonstration Script: Automatic Recovery

*For Nia. Read the plain lines aloud. Lines in [brackets] are stage directions for the engineer at the keyboard and are not read.*

---

[Screen: two terminal windows side by side. Left: the monitor, not yet started. Right: the operator script, ready. Proxy health shows v1.3.0 on blue.]

Today you will watch our system release a new version of the payments service, hit a serious fault, and recover on its own. Nobody will touch the keyboard once it starts.

[Engineer confirms green is running v1.4.0 on standby with zero traffic.]

We always keep two copies of the service. One serves customers. We have just installed the new version on the other copy, which is ready but receiving no customers yet.

[Engineer starts post-deploy-monitor.sh 60 in the left window, then run-cycle.sh switches traffic from blue to green.]

The watchdog on the left is now checking the service every five seconds. Now we move customers across to the new version. Notice nothing on screen goes blank.

[Proxy health shows v1.4.0. Monitor lines show active=green, status ok.]

Customers are now on the new version, and the watchdog confirms it is healthy.

[Script stops kk-api-green.service: this is T0, the controlled fault.]

Now we deliberately break the new version, the way a serious bug would.

[Monitor shows three failed checks, then ROLLBACK TRIGGERED, then ROLLBACK COMPLETE. Proxy health shows v1.3.0.]

The watchdog noticed three failed checks in a row, decided on its own that the release was bad, and moved customers back to the previous version.

[Point to the summary: Total T0->T2: 14s.]

The system detected the problem and restored normal service in 14 seconds, with no person involved. Our previous recovery took four minutes and needed someone watching a screen. At our busiest hour, four minutes of failure means roughly three thousand failed payments; fourteen seconds means fewer than two hundred.
