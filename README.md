# ARC112 — Deploy and Manage Applications on Google App Engine: Challenge Lab

This automation uses Python as the allowed language choice. Run it from **Cloud Shell**, not from the VM SSH terminal. It automatically finds the `lab-setup` VM and its zone, opens an IAP-tunneled SSH command session with retries, clones the Python Hello World sample inside the VM, adds `automatic_scaling.max_instances: 1`, deploys the initial app to App Engine `us-east4`, changes the greeting to `Hello, Cruel World!`, and redeploys.

## Run in Cloud Shell

```bash
curl -LO https://raw.githubusercontent.com/mdshahid000/arc112-app-engine-challenge/main/Meow.sh
sudo chmod +x Meow.sh
./Meow.sh
```

The lab must already be started and the `lab-setup` VM must be running. Use only the temporary Skills Boost student account. The script does not store or request the temporary password. If the first SSH attempt fails, the script retries automatically; opening the VM's SSH button once in the console can also initialize the lab's SSH access.

After both deployments finish, wait approximately 30–60 seconds and click **Check my progress** for the download, deployment, and update objectives. Estimated execution time is 5–10 minutes; keep at least 15 minutes available.
