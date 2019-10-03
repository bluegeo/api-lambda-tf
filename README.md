# api-lambda-tf
A light terraform implementation of API-Driven lambda function invocations

_Configured on [aws](https://aws.amazon.com/) with [terraform](https://www.terraform.io/)_

---

**Note:** docker is required, and the exec commands will only work on *ix operating systems

**Do not manually configure any infrastructure managed by this repo on AWS!**

---

### AWS Credentials
Set up your AWS credentials (if you haven't already) using the AWS CLI.

**Note: Do not put your AWS credentials in the `.tf` code! Use the aws-cli**

`pip install awscli --upgrade --user`

Add the aws-cli executable to your system path variables using [these instructions](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)

Configure your system aws credentials (creates $HOME/.aws/credentials):

`aws configure`

Follow the prompts as necessary, using your credentials from the AWS account (replacing the values
below with your own credentials):

```bash
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-west-2
Default output format [None]: json
```
---

### Library configuration
User or project-specific variables are entered by creating a `terraform.tfvars` file in the repository root.
An example of the requirements of this file are:

```text
app_name = "yourappname"  // Do not include spaces or special characters here
app_version = "v0.1"
environment = "development"
aws_profile = "default"
aws_region = "us-west-2"
```

This file is not meant to be committed.

---

### Functions configuration
You may deploy any number of functions at once, and they are built, deployed, and run by **name**
To build a function you must do three things:
1. Enter the function name in the `variables.tf` file (in the project root) under the `api_methods` list variable.
Note: An example/testing method called `invoke-default` is already included (remove it if desired).
2. Create a directory in `api/methods/lambda` with your function name **exactly matching that from above**.
3. In the directory place (check the example in `invoke-default`):
    * A Dockerfile to build the function.
    * A `handler.py` python (3.6) script to be run in the lambda function.
    * A `parameters.json` file that maps the function parameters. Use the syntax provided in `invoke-default`.

---

### Deployment
Get everything ready using:
```bash
terraform init
```
Once things have successfully initialized, run
```bash
terraform apply --auto-approve
```
And wait for everything to deploy (or for errors)

To remove infrastructure (in its entirety) use:

`terraform destroy`

Once successfully deployed the API Gateway invoke url will be printed in the console. Alternatively, to
access the url use the command:

```bash
terraform output
```

---
viola
