# Before you begin

The prerequisites are:

- Access to the Wiz WIZLABS Tenant as either Global Admin or Global Contributor
- If you don't have access to this tenant, ask Raph Soeiro for access to it

# Overview

Deploy the Wiz Outpost to an Azure tenant and observe scanning process and troubleshooting.

As part of the initial lab setup, you will receive an Azure tenant.

**Note:** If you get into any issues that are Azure related or lab-platform related, please contact Raph Soeiro.

# Getting started with the Azure Portal

1. To get the lab environment details, including username and password for your allocated Azure tenant, you can select **Environment Details** tab. 

1. Open a new private session and access the Azure portal: https://portal.azure.com/

1. Login using the credentials from step 1.

# Create a new Virtual Machine

1. In the Azure portal, go to Virtual Machines, and click on **Create**

1. Details:
    - **Resource Group:** wiz-outpost
    - **Image:** Ubuntu 18.04 LTS
    - **Size:** B2s
    - **Authentication type:** Password
    - **Select inbound ports:** 22 and 80

1. Leave the rest with the default setting, and finishing the creation by clicking on **Review + create**

# Check for AAD prereqs

1. In the Azure portal, go to Azure Active Director, click on Enterprise applications.

1. Remove the 'Application type == <username>' filter.

1. Search for 'AAD App Management' application.

1. If you are able to find it, go to the next section.

1. If you can't find the application, click on New application.

1. Select or search for Box, open the dialog and click on create.

1. After the Box application is installed, try to search for the 'AAD App Management' application again. If you can find it, go to the next section. Otherwise ask for guidance from Raph or Scott.

# Create a Wiz Outpost in Azure

1. In the Wiz portal, navigate to Settings > Outposts, then click **Add Outpost**.

![](https://files.readme.io/5831df0-new_outpost.png)
  
2. In the New Outpost dialog:
   1. Enter a name for the new Outpost.
   2. For Cloud Platform, select **Azure**.
   3. Copy the command that calls the Azure outpost creation script for use below.
3. Open the Azure Cloud Shell, and make sure **Bash** is selected as the input.

![](https://files.readme.io/16029d0-bash_shell.png)


4. Paste the command you copied from the Wiz portal, replacing the following parameters:
   - `<subscription>`—The ID of the dedicated subscription where the Outpost will be created
   - `<kv-name>`—A globally unique name for the key vault that will be created
   - `<resource-group-region>`—The region where the resource group will be created, e.g. "eastus"
   - `<storage-account-name>`—A name for the storage account that will be created

> ❗️ 
> 
> You must adhere to the following naming restrictions:
> 
> - `<kv-name>`—Alphanumeric characters (a-z, A-Z, 0-9) and hyphens only, starting with a letter and ending with either a letter or digit. No consecutive hyphens. Must be globally unique. Length: 3-24 characters.
> - `<storage-account-name>`—Lowercase letters (a-z) and numbers (0-9) only. Must be globally unique. Length: 3-24 characters.

6. Execute the command.

![](https://files.readme.io/a341b65-script_output.png)

7. Copy the following script outputs to a local file for use below:
- Azure Tenant ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Subscription ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Orchestrator Client ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Orchestrator Client Secret: xxxxxxxxxxxxxxxxxxxxxxxxx
- Worker Client ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Worker Client Secret: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Scanner Client ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Scanner Secret: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Scanner App Name: Wiz Disk Analyzer - Scanner
- Resource group name: wiz-orchestrator-global-rg
- Key vault name: xxxxxxx
- Storage account name: sxxxxx

8. Return to the Wiz portal. In the New Outpost dialog:
   1. Enter your Azure **Tenant ID** and the **Subscription ID** of the new subscription you created for Wiz. You can find your Tenant ID by searching for Tenant Properties in your Azure portal.
   2. Paste the **Orchestrator Client ID**, **Orchestrator Client Secret**, **Worker Client ID**, **Worker Client Secret**, **Key Vault Name**, **Resource Group Name**, and **Storage Account Name** that you copied from the output of the deployment script.
   3. (Optional) If you are connecting to a sovereign cloud environment, tick **I'm connecting to a sovereign cloud environment** then select the **Sovereign Cloud Environment**.

9. Click **Add Outpost**. Your new Outpost is added to the Settings > Outpost page with status Initialized.

![](https://files.readme.io/447a4d0-your_new_outpost.png)

> ❗️ 
> #Stop here and post your full script output in the advanced-bootcamp-austin-mar23 channel in Slack. Take a short break while we validate your install.
> ##Wait for Raph to react to your message with a checkmark emoji before continuing. 
>
>
> You're only halfway there!
> 
> Once the Wiz Outpost has been created in your Azure environment, you need to add a Connector to receive its data. The clusters will not start running until a cloud connector is deployed, which will trigger the scanning. 


# Connect Wiz App to your cloud

1. In the Wiz portal, go to **Settings** > **Connectors**, then click **Add Connector** > **Microsoft Azure**.

![](https://files.readme.io/286dc6b-outpost_connector_1.png)"

2. For Installation Type, select **Outpost Azure App**.

3. In the **Outpost** drop-down, select the Azure Outpost you created earlier.

4. Enter the **Tenant ID** of the tenant you want to scan. You can find your Tenant ID by searching for Tenant Properties in your Azure portal.

5. Click **Connect with Azure**, then consent to connecting the Wiz read-only fetcher application to your environment.

## Grant App permissions

Select **Allow data scanning** for Wiz to provide DSPM capabilities.

1. Log in to your Azure portal.

1. Open the Azure Cloud Shell, and make sure **Bash** is selected as the input.

![](https://files.readme.io/cebd2c4-bash_shell.png)

1. From the Wiz portal, copy the subscription Bash command, replacing the `<subscription-id>` parameter with the ID from your Azure environment.

1. Run the command in your Azure Cloud Shell.

1. From the output of the wiz-azure.sh script, copy the **Scanner Secret** value to a local file for use below.

1. Return to the Wiz portal, tick **Deployment script completed, ready to complete connector setup**, and paste the Scanner Secret from the previous step.


![](https://files.readme.io/c391a54-outpost_connector_3.png)

8. Click **Continue**.

## Enter connector details

![](https://files.readme.io/095dd68-details.png)

1. Enter a display name for the new Azure Connector.
2. (Optional) In order to use the Wiz Identity Analysis module, click **Connect with Azure AD**, which requires Global Administrator in Azure Active Directory (AD) permission even for a Subscription-level connection, then accept the connection in the new tab. After you've accepted the connection, you can close the tab.

> 📘 Note
> 
> If you don't currently have access to the Global Administrator in Azure Active Directory (AD) permission, you can skip this step for now. You can add this permission after finishing the initial connection process.

3. Click **Finish**.

> 👍 Success
> 
> Congrats, you're done! Once the cloud connector is successfully added, the Wiz orchestrator will automatically provision all the required resources in the dedicated subscription (where the Outpost has been created).

# Initiate a manual rescan of your connector, or a manual rescan of the VM you created from the Wiz Security Graph. 

# Start investigating your Outpost + Connector + VM Scan Status.

## First team to get a fully successful OS Disk Workload scan after solving the intentional issues wins a super exclusive Wiz prize.

1. Navigate to your lab page, and select the **Environment Details** tab.

1. Scroll to the bottom of the page and click on the **DELETE ON DEMAND LAB** button.
