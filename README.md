# ARC112 — Deploy and Manage Applications on Google App Engine: Challenge Lab

This automation uses Python as the allowed language choice. Run it from **Cloud Shell**. It connects to `lab-setup` through IAP to download and update the sample, copies the app into Cloud Shell, and performs App Engine creation and both deployments from the Cloud Shell student account. This is important because the VM's compute service account may not have `appengine.applications.create` permission.

The script automatically finds the VM and zone, clones the Python Hello World sample inside the VM, adds `automatic_scaling.max_instances: 1`, copies the app to Cloud Shell, creates App Engine in `us-east4`, deploys the initial app, changes the greeting to `Hello, Cruel World!` on the VM, copies it back, and redeploys.

## Run in Cloud Shell

```bash
rm -f Meow.sh
curl -L -o Meow.sh https://raw.githubusercontent.com/mdshahid000/arc112-app-engine-challenge/main/Meow.sh
sudo chmod +x Meow.sh
./Meow.sh
```

The lab must already be started and the `lab-setup` VM must be running. Use only the temporary Skills Boost student account. The script does not store or request the temporary password.

After both deployments finish, wait approximately 30–60 seconds and click **Check my progress** for all objectives. Estimated execution time is 6–12 minutes; keep at least 15 minutes available.
