## Must create SPA
must run from powershell or linux?:
az ad sp create-for-rbac --name terraform_spa --role Contributor --scopes /subscriptions/xxxxxxxxxxxxx

Then add TF_VAR_Environment variables for setting the variables used in the _providers.tf file.

<ul>
<li>TF_VAR_ARM_SUBSCRIPTION_ID
<li>TF_VAR_ARM_TENANT_ID
<li>TF_VAR_ARM_CLIENT_ID
<li>TF_VAR_ARM_CLIENT_SECRET
</ul>

## Must accept product terms
must run from linux prompt: az vm image terms accept --urn microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:latest

![screenshot](aiml01work.png)

## Fix for auth issues durring provisioning
Error: reading queue properties for AzureRM Storage Account 
queues.Client#GetServiceProperties: Failure responding to request: 
StatusCode=403 -- Original Error: autorest/azure: Service returned an error. 
Status=403 Code="AuthenticationFailed" Message="Server failed to authenticate the request.
 Make sure the value of Authorization header is formed correctly including the signature.

Fix by running this command to adjust the clock: sudo hwclock -s

Consider always running it before apply.<br/>
<br/>
EX: sudo hwclock -s;terraform apply;

-- https://stackoverflow.com/questions/60485712/terraform-and-azure-unable-to-provision-storage-account
