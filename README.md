# Project 2 Template

## Initial Set up

The following steps should only need to be done once:

### Set Environment Variable

Add the following to your `.bash_profile` script, or similar for your shell:

```powershell
# If your ucsb email is user_1@ucsb.edu, then YOUR_ACCOUNT_NAME is user-1
# Note: If you have an underscore in your account name, please replace with a hypen.
setx CS291_ACCOUNT YOUR_ACCOUNT_NAME
```

### Install `gcloud` tool

Follow the instructions here:
https://cloud.google.com/sdk/docs/#install_the_latest_cloud_tools_version_cloudsdk_current_version

### Authenticate with Google

Make sure you select your `@ucsb.edu` account when authenticating.

```powershell
gcloud auth login
```

### Verify the above works

```powershell
gcloud projects describe cs291-f19
```

The above should produce the following output:

```
createTime: '2019-07-18T19:28:19.613Z'
lifecycleState: ACTIVE
name: cs291-f19
parent:
  id: '867683236978'
  type: organization
projectId: cs291-f19
projectNumber: '689092254566'
```

### Create Application Default Credentials

Again, make sure you select your @ucsb.edu account when authenticating.

```powershell
gcloud auth application-default login
```

### Install Docker

Follow the instructions here: https://www.docker.com/products/docker-desktop

### Link Docker and Gcloud

```powershell
gcloud auth configure-docker
```

## Develop Locally

Edit your file however you want then follow the next two steps to test your
application:

### Build Container

```powershell
docker build -t us.gcr.io/cs291-f19/project2_$Env:CS291_ACCOUNT .
```

### Run Locally

```powershell
docker run -it --rm \
  -p 3000:3000 \
  -v ~/.config/gcloud/application_default_credentials.json:/root/.config/gcloud/application_default_credentials.json \
  us.gcr.io/cs291-f19/project2_$Env:CS291_ACCOUNT
```

#### modified for Windows Edu

See: [Windows 10: Docker for Windows: unable to share drive](https://github.com/docker/for-win/issues/690)

See: [Can't share host drive (D) with Docker in Windows with a user with or without password](https://github.com/docker/for-win/issues/125)

Copy `application_default_credentials.json` to project directory.

```powershell
docker run -it --rm `
  -p 3000:3000 `
  -v application_default_credentials.json:/root/.config/gcloud/application_default_credentials.json `
  us.gcr.io/cs291-f19/project2_$Env:CS291_ACCOUNT
```

### Test Using CURL

```powershell
curl -D- localhost:3000/
```

The default application should provide output that looks like the following:

```http
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Content-Length: 12

Hello World
```

## Production Deployment

Each time you want to deploy your application to Google Cloud Run, perform the
following two steps:

### Push Container to Google Container Registry

```powershell
docker push us.gcr.io/cs291-f19/project2_$Env:CS291_ACCOUNT
```

### Deploy to Google Cloud Run

```powershell
gcloud beta run deploy \
  --allow-unauthenticated \
  --concurrency 80 \
  --image us.gcr.io/cs291-f19/project2_$Env:CS291_ACCOUNT \
  --memory 128Mi \
  --platform managed \
  --project cs291-f19 \
  --region us-central1 \
  --service-account project2@cs291-f19.iam.gserviceaccount.com \
  --set-env-vars RACK_ENV=production \
  $Env:CS291_ACCOUNT
```

The last line of output should look similar to the following:

```
Service [{ACCOUNT_NAME}] revision [{ACCOUNT_NAME}-00018] has been deployed and is serving 100 percent of traffic at https://{ACCOUNT_NAME}-fi6eeq56la-uc.a.run.app
```

### View Logs

1. Browse to: https://console.cloud.google.com/run?project=cs291-f19

2. Click on the service with your ACCOUNT_NAME

3. Click on "LOGS"

4. Browse logs, and consider changing the filter to "Warning" to find more pressing issues.

## Resources

- https://cloud.google.com/run/docs/quickstarts/build-and-deploy
- https://googleapis.dev/ruby/google-cloud-storage/latest/index.html

## Possible Errors

### invalid reference format

Re-run the `export` command.

## Project 1 Questions

* On average, how many successful requests can ab complete to /token in 8 seconds with various power-of-two concurrency levels between 1 and 256?

  concurrency 1: 88/8s (88/42 = 210%)\
  concurrency 4: 345/8s (345/163 = 212%)\
  concurrency 16: 1340/8s (1340/638 = 210%)\
  concurrency 64: 4396/8s (4396/2478 = 177%)\
  concurrency 256: 9069/8s (9069/8301 = 109%)
  
* Using data you've collected, describe how this service's performance compares to that of your lambda function from Project 1 (remeasure those results if necessary).

  This service is about twice as fast as the lambda functions at low concurrency (<64). However it is only 77% faster at -c 64 and 9% faster at -c 256. This service also spends a very long time spinning up after being left idle for a few minutes.

* What do you suspect accounts for the difference in performance between your AWS Lambda web service, and your Google Cloud Run service?

  At low concurrency (<64), Google Cloud Run is be faster, perhaps because it has a simpler architecture (no API gateway in between), or perhaps Google servers are just faster. At higher concurrency (>= 64), it might be hitting CPU limits at each of the containers. Each container is set to accept 80 connections, which is probably too much for one instance, and Google Cloud Run would not spawn new instances until that limit is reached. (I know memory is not the limiting factor, since the performance is the same when I doubled it.) 
  
