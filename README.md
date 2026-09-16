# ARC112 — Deploy and Manage Applications on Google App Engine: Challenge Lab

These scripts use the allowed Python choice. **Run them inside the SSH terminal connected to the lab-setup VM**, not in your local Cloud Shell terminal. Run each command in order in the same SSH session.

```bash
curl -fsSLO https://raw.githubusercontent.com/mdshahid000/arc112-app-engine-challenge/master/01_download_python_app.sh && chmod +x 01_download_python_app.sh && ./01_download_python_app.sh
curl -fsSLO https://raw.githubusercontent.com/mdshahid000/arc112-app-engine-challenge/master/02_deploy_initial_app.sh && chmod +x 02_deploy_initial_app.sh && ./02_deploy_initial_app.sh
curl -fsSLO https://raw.githubusercontent.com/mdshahid000/arc112-app-engine-challenge/master/03_update_and_redeploy.sh && chmod +x 03_update_and_redeploy.sh && ./03_update_and_redeploy.sh
```

Step 1 clones the official Python sample. Step 2 adds the required `automatic_scaling.max_instances: 1` limit and deploys it to App Engine Standard in `us-west1`. Step 3 changes the greeting to `Goodbye world!` and redeploys the application.

Expected completion time is approximately 5–10 minutes. The lab progress checks should be clicked manually after the download, initial deployment, and update deployment.
