# Channel Playout Management UI
This repo contains all of the tools and instructions necessary for you to deploy and build an HTML dashboard, capable of interfacing with, and creating a playout schedule for AWS Elemental MediaLive. This is what the finished product will look like!

![](readme_images/ux1.png)

## Assumptions
These instructions assume that:

- You've already created an AWS account
- You have sample content in an S3 bucket that has been sanitized to MP4 format
- I will think of more assumptions...


## Architecture
These instructions utilize these AWS Services:
- AWS Elemental MediaLive (this is the playout engine)
- AWS Elemental MediaPackage (this service packages the OTT stream and acts as an origin)
- AWS Elementa MediaConvert (this service is responsible for reliably distributing transport stream video)
- Amazon S3 (this storage service will be the origin for our playout assets)
- Amazon EC2 (this virtual compute service will be where we host our dashboard site and transmux the output of MediaConnect to RTMP for display)
- Amazon API Gateway
- AWS Lambda
- IAM

![](readme_images/ux2.png)


