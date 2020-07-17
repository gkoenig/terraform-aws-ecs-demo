# CI/CD demo pipeline on AWS

## Overview

AWS provides certain services to create a fully automated CI/CD pipeline to implement e.g. a blue/green deployment triggered by ```git push```. 

* ECS : **E**lastic **C**ontainer **S**ervice  
managed docker container environment, compatible with Fargate and EC2. We will use _Fargate_ as container launch type. By that we do not have to take care of underlying cluster resources (in contrast to use EC2 launch type).

* ECR : **E**lastic **C**ontainer **R**epository  
container repository, like e.g. DockerHub

* CodeCommit  
source code repository, basically _Git by AWS_

* CodeBuild  
CodeBuild is a fully managed continuous integration service that compiles source code, runs tests, and produces software packages that are ready to deploy.

* CodeDeploy  
CodeDeploy is a fully managed deployment service that automates software deployments to a variety of compute services such as Amazon EC2, AWS Fargate, AWS Lambda, and your on-premises servers

* CodePipeline  
CodePipeline is the orchestrator which glues together the VCS-,build- and deploy steps. Not only AWS internal services are possible, e.g. you can also integrate GitHub as VCS.


## Demo pipeline

This demo CI/CD pipeline will

* run container on _AWS ECS_ cluster
* fetch the container from _AWS ECR_
* store the container implementation within _CodeCommit_
* use _CodeBuild_ to build the container and push it to _ECR_
* use _CodeDeploy_ to deploy updated container to _ECS_ cluster, replacing the "old" container

![](./images/cicd-pipeline.png)

To keep the infrastructure somehow simple, the whole setup uses a VPC with only 2 public subnets (in 2 different AZs) to show HA across availability zones.

## Setup

The creation of the following resources is automated via terraform:
* vpc
* subnets (2 public)
* security groups
* loadbalancer (ALB)
* ECS cluster
* ECR (container) repository
* CodeCommit (code) repository

After those resources are up, the remaining steps are:
* push the code to CodeCommit repository
* create the CI/CD pipeline

### automated creation of resources via terraform

**prerequisites** : 
* aws cli installed and configured (by default terraform takes the AWS_ACCESS_KEY and AWS_SECRET_KEY from ~/.aws/credentials , from the profile _default_ )
  * the user you configured needs to have proper permissions to create the resources 
* terraform installed v0.12+  ==> [instructions](https://learn.hashicorp.com/terraform/getting-started/install.html)

#### create S3 bucket and dynamoDB table

```bash
cd terraform/terraform-s3-remote-state
#run once
terraform init
#check your terraform code
terraform validate
terraform plan
#deploy
terraform apply
```

#### create core AWS resources

```bash
cd terraform/core-aws
#run once
terraform init
#check your terraform code
terraform validate
terraform plan
#deploy
terraform apply
```

#### create ECS related resources

```bash
cd terraform/services/ecs
#run once
terraform init
#check your terraform code
terraform validate
terraform plan
#deploy
terraform apply
```

#### create CICD related resources

```bash
cd terraform/services/cicd
#run once
terraform init
#check your terraform code
terraform validate
terraform plan
#deploy
terraform apply
```

### push code to CodeCommit repo

### create CI/CD pipeline within AWS mgm console

