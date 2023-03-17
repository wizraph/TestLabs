Deploy the resources required to perform auto-remediation in an AWS environment, and configure Wiz to send Issues to the deployed resources.

# Before you begin

The prerequisites are:

- The user performing the connection must be an AWS account admin user
- Access to <a href="https://app.wiz.io/" target="_blank">Wiz</a> as either Global Admin or Global Contributor
- (Recommended) A list of Cloud Configuration Rules in Wiz for which you will enable auto-remediation

# Deployment steps

[Step 1](#deploy-auto-remediation-infrastructure): Deploy auto-remediation infrastructure

[Step 2](#configure-auto-remediation-in-wiz): Configure auto-remediation in Wiz

[Step 3](#recommended-test-the-lambda-function): (Recommended) Test the Lambda function

If something doesn't go as expected, take a look at the [Troubleshooting](doc:aws-rem-troubleshooting) guide.

After you've gotten everything deployed, you might consider [editing the built-in IAM permissions](#optional-edit-iam-permissions) if you prefer to adhere to the least-privileged model.

Later on, you might need to [update the built-in playbooks](doc:auto-rem-playbooks-aws#update-playbooks).

## Deploy auto-remediation infrastructure

First, you need to use CloudFormation to instantiate a dedicated SNS Topic, SQS Queue, IAM Role and Policy, and Lamdba function, from the [Wiz bucket](#deploy-resources-from-the-wiz-bucket) located in `us-east-2`

### Deploy resources from the Wiz bucket

1. Log in to the AWS account where you will place your remediation stack.
2.Use the link below to launch the CloudFormation Stack. CloudFormation is opened in a new tab with all settings preconfigured.

(https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/quickcreate?stackName=wiz-advanced-remediation&templateURL=https://wizio-public.s3.us-east-2.amazonaws.com/deployment-v2/aws/remediation/cft/cft_wiz_remediation_stack_from_sqs.json)

3. The Auto Remediation stack deployment needs to take place in us-east-2 region.
4. On the Review page, you can modify the following parameters:
   - `Stack name`—A friendly name given to the remediation stack
   - `CrossAccountRole`—The name to be used for cross-account remediations. Make sure you use the same name when creating the IAM Role in your Target account(s).
   - `SourceCodeKeyPath`—Leave as is, unless you host the CFT in your own bucket and need to point it to your own location.
   - `WizRemediationBucketName`—The Auto-remediation bucket name. The default is "wizio-public". Only change to another bucket name if you are following the instructions to [deploy in another region](#deploy-resources-from-an-alternate-bucket).
   - `WizRemediationResourcesPrefix`—A prefix added to all resources created by the CloudFormation Stack, for your own management. Defaults to "Wiz", which creates a role named Wiz-Remediation-Stack-Role. You can modify the prefix.

![](https://files.readme.io/837bb5a-Create_stack_3.png)


5. Tick the checkbox under Capabilities: **I acknowledge that AWS CloudFormation might create IAM resources.** This is required to create the role for Lambda.
6. Click **Create stack**.

This CloudFormation stack creates the following resources:

- AWS SNS Topic—Receives Issues from Wiz and triggers an SNS Subscription to send to the SQS Queue.
- AWS SQS Queue—Receives Issues from Wiz and triggers the remediation Lambda function.
- AWS IAM Role and Policy—Used by the Lambda function. See its full [list of permissions](#cft_wiz_remediation_stack_fromjson) below.
- AWS Lambda Function—Contains the main parser, which extracts key data from Issues, and the playbook scripts that remediate the offending resources.

## Configure auto-remediation in Wiz

After creating the required infrastructure in your AWS account(s), there are several things that must be configured in Wiz:

1. [Set Cloud Configuration Rules to function as Controls](#set-cloud-configuration-rules-to-function-as-controls)
2. [Create an SNS Integration](#create-an-sns-integration)
3. [Trigger the Action](#trigger-the-action)

### Set Cloud Configuration Rules to function as Controls

By default, Cloud Configuration Rules do not generate Issues in Wiz, only Controls. Because auto-remediation can only be performed on an Issue, you must set Cloud Configuration Rules for which you want to enable auto-remediation to function as Controls. 

1. Go to the <a href="https://app.wiz.io/policies/cloud-configuration-rules" target="_blank">Policies > Cloud Configuration Rules</a> page.
2. Filter for Rules that support auto-remediation in AWS:
   1. Click **Cloud Platform** > **Amazon Web Services**.
   2. Click **Filter** > **Supports Auto Remediation** > **True** (<a href="https://app.wiz.io/policies/cloud-configuration-rules#~(filters~(serviceType~(equals~(~'AWS))~hasAutoRemediation~(equals~true)))" target="_blank">direct link</a>).

![](https://files.readme.io/2433a6d-rule_as_control.png)

3. Click **Control** toggles to set Cloud Configuration Rules to function as Controls.

### Create an SNS Integration

You will need the **WizRemediationSNSTopic** ARN from the Outputs section of the CloudFormation stack created in [Step 1](#deployment-steps).

1. Navigate to the <a href="https://us-east-2.console.aws.amazon.com/cloudformation" target="_blank">AWS CloudFormation Dashboard</a> in the region where you created the stack in Step 1.
2. Click the Wiz Remediation stack name.
3. Select the **Outputs** tab.

![](https://files.readme.io/46e54ab-remediation-sns-topic-cft.png "remediation-sns-topic-cft.png")


4. Copy the **WizRemediationSNSTopic** ARN to a local file.
5. Follow the guide on creating an [SNS Integration](doc:sns-integration). <a id="return-from-sns"></a>

### Trigger the Action

The Action that passes Issues data to the SNS Topic can be triggered by Automation Rules when a new Issue is generated, or it can be triggered manually by users.

If you would like auto-remediation to occur without a "human in the loop", you must create an Automation Rule. See the page on [Automation Rules](doc:response-automation-overview).

Otherwise, you must trigger auto-remediation [on-demand](doc:auto-rem-overview#on-demand-auto-remediation), whenever a new Issue is generated.

## (Recommended) Test the Lambda function

The base remediation package comes with a test playbook called [AWS-TEST.py](doc:auto-rem-playbooks-aws#test-event). The comment section in the beginning of the playbook has a sample SQS message that you can use to test your setup.

1. Navigate to your <a href="https://us-east-2.console.aws.amazon.com/lambda" target="_blank">AWS Lambda Dashboard</a>.
2. Click the Function name.
3. In the Code tab, click the down arrow next to the **Test** button > **Configure test event**.
4. Choose **Create new test event** along with the `hello-world` **Event template**.
5. Provide a test name, e.g., "test-event".
6. Replace the test event's contents with the sample SQS message found in the comment section of the AWS-TEST.py playbook. Be sure to replace `123456789012` in the `subscriptionId` field with your Main AWS account ID. This is the test event:

```json
{
  "Records": [
    {
      "messageId": "12341234-abcd-abcd-abcd-123412341234",
      "receiptHandle": "MessageReceiptHandle",
      "body": "{\"trigger\": {\"source\": \"Action\", \"type\": \"Action\", \"ruleId\": \"1\", \"ruleName\": \"1\"}, \"issue\": {\"id\": \"ee878f26-bcd8-4a4d-bba1-f9684a0488cf\", \"status\": \"ACTIVE\", \"severity\": \"HIGH\", \"created\": \"2021-07-01M01:01:01Z\", \"projects\": null}, \"resource\": {\"id\": \"test-resource\", \"name\": \"test-resource\", \"type\": \"security_group\", \"cloudPlatform\": \"aws\", \"subscriptionId\": \"123456789012\", \"subscriptionName\": \"TestAccount\", \"region\": \"us-east-2\", \"status\": \"ACTIVE\", \"cloudProviderURL\": \"someurl.com\"}, \"control\": {\"id\": \"TEST-001\", \"name\": \"Test Control\", \"description\": \"ssh\", \"severity\": \"HIGH\", \"sourceCloudConfigurationRuleId\": \"TEST-001\", \"sourceCloudConfigurationRuleName\": \"Test Control\"}}",
      "attributes": {
        "ApproximateReceiveCount": "1",
        "SentTimestamp": "1523233000000",
        "SenderId": "123456789012",
        "ApproximateFirstReceiveTimestamp": "1523233000001"
      },
      "messageAttributes": {},
      "md5OfBody": "7b270e59b47ff90a553787f90a553787",
      "eventSource": "aws:sqs",
      "eventSourceARN": "arn:aws:sqs:us-east-2:123456789012:WizIssuesQueue",
      "awsRegion": "us-east-2"
    } 
  ]   
}
```



7. Click **Create**, then click **Test**. The Execution results page loads, showing:  
   `This playbook is invoked by arn:aws:lambda:<region>:<parent_account_name>:function:<lambda_function_name>` followed by the output of `sts.get_caller_identity()`. Note that the `Arn` uses the credential from the Lambda role.
8. (Optional) For a multi-account deployment, repeat the steps above, but replace `123456789012` in the `subscriptionId` field with your **Target** AWS account ID(s). The Execution results page loads, showing `This playbook is invoked by arn:aws:lambda:<region>:<parent_account_name>:function:<lambda_function_name>` followed by the output of `sts.get_caller_identity()`. Note that the `Arn` uses the assumed role on another account.

> 👍 
> 
> Whew! That's it. You're done setting up auto-remediation.