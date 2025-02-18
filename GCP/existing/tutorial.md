# GCP Existing Bucket Protection Example

<walkthrough-tutorial-duration duration="10"></walkthrough-tutorial-duration>
This demonstration leverages Terraform to provide a functional example of adding protection to an existing GCP bucket with the QuickScan Pro APIs. All of the necessary resources for using this solution to protect an existing GCP Cloud Storage bucket are implemented for you as part of the environment configuration process, including sample files and command line helper scripts.

## Select Project

<walkthrough-project-setup></walkthrough-project-setup>

---
### Toggle Editor for more space

(optional) <walkthrough-spotlight-pointer spotlightId="toggle-editor">**Toggle Editor**</walkthrough-spotlight-pointer>

## Setup

### Set Cloud Shell Project

```sh
gcloud config set project <walkthrough-project-id/>
```

### Enable GCP Services

In order to properly use this demo, run the following helper script to enable the appropriate GCP services:

```sh
./enable_services.sh
```

### CrowdStrike Falcon API Credentials

Create or modify an API Key in the Falcon Console and
Assign the following scopes:

- **QuickScan Pro** - `READ`, `WRITE`
- **Malquery** - `READ`, `WRITE`

> You will be asked to provide these credentials when the `existing.sh` script executes.

### Existing Bucket Name

You will need to know the name of the existing bucket you would like to use for this demonstration.

---
Next, you'll be standing up an environment for this demonstration.

## Let's Get Started

Execute the following command to stand up the demonstration:

***Please note that the input for your credentials are hidden.***

```sh
./existing.sh up
```

You will be asked to provide your CrowdStrike API credentials, as well as the existing bucket name.

If this is the first time you're executing the demonstration, Terraform will initialize the working folder after you submit these values. After this process completes, Terraform will begin to stand-up the environment.

It takes roughly 3 minutes to stand up the environment.

When the environment is done, you will be presented with the message:

```terminal

╭━━━┳╮╱╱╭╮╱╱╱╭━━━┳━━━┳━╮╱╭┳━━━╮
┃╭━╮┃┃╱╱┃┃╱╱╱╰╮╭╮┃╭━╮┃┃╰╮┃┃╭━━╯
┃┃╱┃┃┃╱╱┃┃╱╱╱╱┃┃┃┃┃╱┃┃╭╮╰╯┃╰━━╮
┃╰━╯┃┃╱╭┫┃╱╭╮╱┃┃┃┃┃╱┃┃┃╰╮┃┃╭━━╯
┃╭━╮┃╰━╯┃╰━╯┃╭╯╰╯┃╰━╯┃┃╱┃┃┃╰━━╮
╰╯╱╰┻━━━┻━━━╯╰━━━┻━━━┻╯╱╰━┻━━━╯

Welcome to the CrowdStrike Falcon Existing GCP Bucket Protection demo environment!

The name of your existing bucket is gs://cs-quickscan-existing-bucket-example.
...
...
```

---
Next, you'll use the helper commands to upload the sample files, and check for findings.

## Using the Demonstration

Now that your environment is stood up, and your cloud-shell is configured, you can start testing functionality.

### List sample files

Run the following command to list the sample files:

```sh
ls ~/testfiles
```

The folder contains the following sample types:

+ 2 safe sample files
+ 3 malware sample files
+ 2 unscannable sample files

#### Example

```terminal
malicious1.bin malicious2.bin malicious3.bin  safe1.bin  safe2.bin  unscannable1.png  unscannable2.jpg
```

### Upload sample files

Run the following command to upload the entire contents of the `~/testfiles` folder to the demonstration bucket:

```sh
upload
```

#### Example

```terminal
Uploading test files, please wait...
Uploading malicious1.bin to gs://cs-quickscan-existing-bucket-example...
Uploading malicious2.bin to gs://cs-quickscan-existing-bucket-example...
Uploading malicious3.bin to gs://cs-quickscan-existing-bucket-example...
Uploading safe1.bin to gs://cs-quickscan-existing-bucket-example...
Uploading safe2.bin to gs://cs-quickscan-existing-bucket-example...
Uploading unscannable1.png to gs://cs-quickscan-existing-bucket-example...
Uploading unscannable2.jpg to gs://cs-quickscan-existing-bucket-example...
Upload complete. Check Cloud Functions logs or use the get-findings command for scan results.
```

---
Next, you'll review the output from the Cloud Functions demonstration function.

## Review Cloud Function Logs

There are a few ways to view the status of the files uploaded to the demonstration bucket. Below
you will use the helper command `get-findings` as the main method for this demonstration.

### Use the `get-findings` helper command

Run the following command to view any detected Malware threats:

```sh
get-findings
```

*Note: You may need to wait a few seconds before both malicious files are detected*

#### Example

```terminal
Output from Cloud Functions logs:
LOG: Threat malicious3.bin removed from bucket cs-quickscan-existing-bucket-example
LOG: Verdict for malicious3.bin: suspicious
LOG: Threat malicious2.bin removed from bucket cs-quickscan-existing-bucket-example
LOG: Verdict for malicious2.bin: suspicious
LOG: Threat malicious1.bin removed from bucket cs-quickscan-existing-bucket-example
LOG: Verdict for malicious1.bin: suspicious
```

### Use the gcloud cli (Optional)

Run the following command using the gcloud cli:

```sh
gcloud functions logs read csexample-cs_bucket_protection --min-log-level=info
```

This will give you more information surrounding a log entry.

#### Example

```terminal
LEVEL: I
NAME: cs-quickscap-pro-cs_bucket_protection
EXECUTION_ID: is5tggxnonpx
TIME_UTC: 2025-01-16 15:29:43.221
LOG: No threat found in unscannable2.jpg
...
...
```

### Use the Logging Dashboard (Optional)

The quickest method for viewing the logs on the console is to:

Navigate to the [Cloud Functions](https://console.cloud.google.com/functions) service page
-> Select the demo function
-> Select `LOGS`

---
Next, you'll verify the malicious files were removed from the bucket.

## Verify malicious files were deleted

Run the `list-bucket` helper command to list the objects in the demonstration bucket:

```sh
list-bucket
```

The following files should be in your bucket:

```terminal
gs://cs-quickscan-existing-bucket-example/safe1.bin
gs://cs-quickscan-existing-bucket-example/safe2.bin
gs://cs-quickscan-existing-bucket-example/unscannable1.png
gs://cs-quickscan-existing-bucket-example/unscannable2.jpg
...
...
```

Since this is an existing bucket, verify the malicious files are not in the output, as they should
have been removed from the bucket.

---
Next, you'll tear down the demonstration to prevent your organization from yelling at you about runaway cloud costs ;)

## Tearing Down the Demonstration

To tear down the environment, and clean up any associated files, run the following command:

***Note: This does not delete your existing bucket or any files in it!***

```sh
./existing.sh down
```

> You will be asked to provide the name of your existing bucket

Once the environment has been destroyed and cleaned up, you will be provided the message:

```terminal
Destroy complete! Resources: 13 destroyed.

╭━━━┳━━━┳━━━┳━━━━┳━━━┳━━━┳╮╱╱╭┳━━━┳━━━╮
╰╮╭╮┃╭━━┫╭━╮┃╭╮╭╮┃╭━╮┃╭━╮┃╰╮╭╯┃╭━━┻╮╭╮┃
╱┃┃┃┃╰━━┫╰━━╋╯┃┃╰┫╰━╯┃┃╱┃┣╮╰╯╭┫╰━━╮┃┃┃┃
╱┃┃┃┃╭━━┻━━╮┃╱┃┃╱┃╭╮╭┫┃╱┃┃╰╮╭╯┃╭━━╯┃┃┃┃
╭╯╰╯┃╰━━┫╰━╯┃╱┃┃╱┃┃┃╰┫╰━╯┃╱┃┃╱┃╰━━┳╯╰╯┃
╰━━━┻━━━┻━━━╯╱╰╯╱╰╯╰━┻━━━╯╱╰╯╱╰━━━┻━━━╯
```

---
Finally, you'll learn more about customizing this demonstration (if applicable)

## Customize Demonstration

In the event that you would like to re-run this demonstration and use different values:
<walkthrough-editor-open-file
    filePath="demo/variables.tf">
    Edit the variable Terraform file
</walkthrough-editor-open-file>

---
Congratulations on completing this demonstration!
<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
