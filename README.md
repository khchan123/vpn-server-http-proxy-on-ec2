# VPN Server and HTTP Proxy on EC2 Instance

This project deploys an EC2 instance in your AWS account with VPN server and HTTP proxy installed. The EC2 instance could be deployed in any AWS region. You may use VPN to browse internet or to watch Netflix as in other region.

The CloudFormation template deploys an EC2 instance together with its required AWS infrastucture so that the EC2 instance does not mix up with existing infrastructure in your AWS account. This includes a new VPC, subnet, internet gateway, security group, IAM role and instance profile. User data of the EC2 instance installs and configures the HTTP proxy ([squid](https://github.com/squid-cache/squid)) and VPN server (pptpd).

**Note:** You will deploy a `t3a.micro` EC2 instance in your AWS account. This will incur some charges as it is beyond AWS Free Tier limit. You can choose another instance type.

## How to deploy

1. Configure your [AWS CLI credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) in a Linux or macOS environment. If you have a named profile, setting the `AWS_PROFILE` environment variable at the command line.

   ```bash
   export AWS_PROFILE=user1
   ```

2. Run a deployment script. There are several deployment scripts for different regions prepared for you as example.

   | Script             | Region       | AWS region code  |
   | ------------------ | ------------ | ---------------- |
   | `deploy.oregon.sh` | Oregon, US   | `us-west-2`      |
   | `deploy.tokyo.sh`  | Tokyo, Japan | `ap-northeast-1` |
   | `deploy.london.sh` | London, UK   | `eu-west-2`      |

3. After the script completes you will see the connection info like below in the screen.

   ```
   Output:
   ProxyPort    xxxx
   ProxyServer  xxx.xxx.xxx.xxx
   VPNPassword  xxxxxxxxxx
   VPNServer    xxx.xxx.xxx.xxx
   VPNUser      xxxxxxxx
   
   My IP without Proxy: yyy.yyy.yyy.yyy
   My IP with Proxy: xxx.xxx.xxx.xxx
   
   Server: xxx.xxx.xxx.xxx
   AMAZON-02 - England, United Kingdom
   Ping: 243ms
   ```

4. Then you can connect to your HTTP proxy and VPN server.

   - HTTP Proxy
     - Server: <u>(refer to your output)</u>
     - Port: <u>(refer to your output)</u>
     - No password
   - VPN: 
     - Protocol: PPTP
     - Encrpytion: MPPE
     - Server: <u>(refer to your output)</u>

## Configurations

You can prepare your own deployment script with different configurations.

### AWS_PROFILE

Specify `AWS_PROFILE` if you configure your AWS CLI in a named profile. For example,

```bash
AWS_PROFILE=user1
```

### AWS_DEFAULT_REGION

Deploy EC2 instance in another region. See the [AWS link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) for full list of region code and name.

For example, use this to deploy EC2 instance in Seoul, South Korea:

```bash
AWS_DEFAULT_REGION=ap-northeast-2
```

### StackName

The `StackName` refers to the stack name in CloudFormation template. You will also find it in the name of all deployed resources for identification.

```bash
StackName="Tunnel-Server"
```

### AllowedCIDR

The CIDR block ranges allowd to connect to the EC2 instance.

To allow your own public IP address only (by probing through https://ifconfig.co):

```
AllowedCIDR="$(curl https://ifconfig.co 2>/dev/null)/32"
```

To allow anyone **(this is not safe!!!)**:

```bash
AllowedCIDR="0.0.0.0/0" 
```

### InstanceType

**Default: t3a.micro**

The instance type of the EC2 instance.

For example, deploy the EC2 instance of instance type `t3.micro`.

```bash
InstanceType="t3.micro"
```

### ProxyPort

Port number for HTTP proxy

### VPNUser

VPN username

### VPNPassword

VPN password

## Connect to your EC2 instance

You can connect to your EC2 instance using SSM Session Manager. Go to the EC2 service in AWS console and find your EC2 instance. Click "Connect" -> "Session Manager" -> "Connect". You cannot connect to the EC2 instance through SSH for security purpose.

## Clean up

After you are done, remember to delete the CloudFormation stack in AWS management console. You can run the script `list-all-ec2.sh` to list your EC2 instance in all AWS regions for double check.
