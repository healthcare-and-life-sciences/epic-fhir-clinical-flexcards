
![](/images/ahlsbanner.png)

# A-HLS EHR Clinical Data FlexCards Documentation 

The EHR Clinical Data FlexCards enables an organization to show read-only, external clinical data for a patient within Health Cloud. At this time, the accelerator is limited to clinical data from organization’s Epic instances. 

The accelerator is compatible with both MuleSoft or via a direct connection via FHIR APIs with Epic. After a few configuration steps, an organization is ready to start using the Patient Search component in their workflows. 

The setup instructions below detail how to connect the Accelerator directly to your Epic instance. Please contact your MuleSoft AE for support in connecting the Accelerator to MuleSoft.

It is assumed that an organization has enabled the appropriate FHIR APIs (detailed below) in their Epic system which is what supports the accelerator.

## Overview

The following clinical objects are included in the Accelerator:

**Patient Information**

* Full Name
* MRN
* Date of Birth
* Age
* Gender
* Marital Status
* PCP
* Preferred Language
* Active and Inactive Patient FYIs

**Contact Information:**

* Address
* Phone Numbers (Home, Work, Mobile)
* Email

**Health Information**

* Allergies
* Conditions
* Medications
* Longitudinal Care Plan
* Outpatient Care Plan(s)
* Longitudinal Care Team
* Social History

**Appointment Information:**

* Upcoming Appointments
* Past Encounters



![](/images/fcimage1.png)

## Business Objective

The EHR Clinical Data FlexCards enables an organization to show a patient’s or member’s clinical data within Salesforce.  

## Business Value and Benefits

* Reduce IT Cost
* Reduce Implementation Cost
* Improve User Experience
* Improve Patient Satisfaction

* * *

## Industry Focus and Workflow

### Primary Industry:

* Provider
* Payer

### Primary User Persona:

* Call Center Agent
* Care Coordinator

### User Workflow:

* A user opens the patient’s Person Account record in Salesforce and views the clinical data in the form of FlexCards (Lightning Web Components) on the record.

* * *

## Package Includes:

### **FlexCards (14 excluding child cards)**

* **Patient Demographics:**
    * EpicFHIRPatientInfoCore
        * EpicFHIRPatientFYICore
* **Clinical Information:**
    * EpicFHIRHealthInfoParentCore
        * EpicFHIRAllergiesCore
        * EpicFHIRPatientConditionsCore
        * EpicFHIRPatientMedicationsCore
        * EpicFHIRCarePlanOPCore
        * EpicFHIRCarePlanLongCore
        * EpicFHIRCareTeamCore
        * EpicFHIRSocialHistoryParentCore
            * EpicFHIRSocialHistoryCore
* **Appointment Information:**
    * EpicFHIRVisitsParentCore
        * EpicFHIRPatientAppointmentsCore
        * EpicFHIRPatientEncountersCore

### Integration Procedures (2)

* EHR/AuthAndDataParent

Input Options:

|Input Variable	|Possible Values	|Required?	|
|---	|---	|---	|
|DataType	|Allergies - Patient's Allergies, CarePlanLong - Longitudinal Care Plan, CarePlanOP - Outpatient Care Plan, Conditions - Patient's Conditions, Demographics - Patient's demographics and contact information, Encounters - Patient's past encounters, Medications - Patient's Medications, Social - Patient's Social History (e.g., Smoking History), Appointments - Patient's Upcoming Appointments, CareTeamLong - Patient's Longitudinal Care Team, PatientFYI - Patient's FYI Flags	|Y	|
|ContextId	|{recordId} - do not change this variable	|Y	|

* EHRConnect/GetData

### DataRaptors (13)

* GetPatientEHRId
* EpicFHIRPatientAllergiesXMLtoJSON
* EpicFHIRCarePlanLongXMLtoJSON
* EpicFHIRMedicationXMLtoJSON
* EpicFHIRSocialHistoryXMLtoJSON
* EpicFHIRPatientAppointmentsXMLtoJSON
* EpicFHIROPCarePlanXMLtoJSON
* EpicFHIRPatientConditionsXMLtoJSON
* EpicFHIRPatientDemographicsXMLToJSON
* DREpicPatient2JSONtoJSON
* EpicFHIREncountersXMLtoJSON
* DRTransformCareTeamJSONtoJSON
* EpicFHIRPatientFYIXMLtoJSON

### **Custom Apex Class (1)**

* ClientCredentialsJWT.cls

## Configuration Requirements

### 1. Pre-Install Configuration Steps:

#### EHR Pre-Installation Steps:

* Confirm that your endpoint is configured such that the following APIs are active - for full reference, please refer to the [fhir.epic.com](http://fhir.epic.com/) API documentation.
	* api/FHIR/R4/AllergyIntolerance
	* api/FHIR/R4/CarePlan
	* api/FHIR/R4/Condition
	* api/FHIR/R4/Patient
	* api/FHIR/R4/Encounter
	* api/FHIR/R4/MedicationRequest
	* api/FHIR/R4/Observation
	* api/FHIR/STU3/Appointment
	* api/FHIR/R4/CareTeam
	* api/FHIR/R4/Flag

#### **Salesforce Pre-Installation Steps:**

* Ensure your Salesforce Health Cloud org has OmniStudio installed - either the Vlocity HINS package or Core OmniStudio. 
        1. To verify installation, please navigate to Setup > Installed Packages > OmniStudio.
    2. Enable Identity Provider according to these steps: https://help.salesforce.com/s/articleView?id=sf.identity_provider_enable.htm&type=5
![](/images/psimage3.png)
### 2. Install the Accelerator 

* Follow the download steps in the **"Download Now"** flow presented on the HLS Accelerators website for this Accelerator which downloads the following GitHub repository on your machine: https://hlsaccelerators.developer.salesforce.com/s/bundle/a9E5f000000PL76EAG/epic-ehr-clinical-data-flexcards
* Unzip the resulting .zip file which is downloaded to your machine. 
* Open the **“OmniStudio”** folder
	* If you have the Vlocity_ins package installed in your org, open the folder titled “Vlocity Version”.
	* If you have Core OmniStudio installed in your org, open the folder titled "OmniStudio Version".
	* Install the DataPack into your org. 
		* In Salesforce, click on **App Launcher** → Search for **"OmniStudio DataPacks"** and click on it.
		* Click on **"Installed"** > Import > From File
		* When the window opens, select the .json file identified in the previous step. Click **"Open"** then click 'Next' 3 times.
		* When prompted, click **"Activate Now"**.

### 3. Integration Configuration

There are 3 different ways that organizations may configure the integration for the accelerator. Click on the method below that supports your organization's integration architecture:

* [MuleSoft Direct](#mulesoft-direct)
* [MuleSoft Anypoint Platform](#mulesoft-anypoint-platform)
* [Epic Direct Connection](#Epic-Direct-Connection)


## MuleSoft Direct


*Available starting June 5, 2023*

Required SKUs:

-   Health Cloud
-   Anypoint Starter or Base

### 1. Complete MuleSoft Direct Configuration:

-   Complete the Setup steps for the  [**Integrations Setup for Industry Integration Solutions**](https://help.salesforce.com/s/articleView?language=en_US&id=sf.industry_integration_solutions.htm&type=5)
    -   In the  **Generic FHIR Client Setup**, enter the following information for the Epic EHR credentials
        -   **Authentication Protocol**: JSON Web Token
        -   **Base URL**: your Epic FHIR server’s base URL
        -   **Token URL**: your Epic FHIR server’s authentication URL
        -   **Client ID**: 43b0500b-ea80-41d4-be83-21230c837c15
        -   **Private Key**  - import the Private Key which is included in the Accelerator download .zip folder
        -   **Non-PRD Test Information**:
            -   **Endpoint**:  [https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token](https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token)
            -   **Client ID**: fe0e3375-fffa-469b-8338-d5fe08f7d3b1
            -   Refer to the  **Epic FHIR App**: Salesforce Health Cloud - Clinical Summary

<h3>2. Configure the Accelerator for MuleSoft Direct</h3>

Update the **EpicFHIRGetData** Integration Procedure to use the MuleSoft Direct connection instead of Epic FHIR APIs directly:

* App Launcher > Integration Procedures > EpicFHIRGetData
	* Create a **New Version** of the Integration Procedures
	* For each of the **HTTP Action** elements, make the following changes:
		* In the **Path** field, remove the “/FHIR/R4” portion of the path such that the Path = /api/AllergyIntolerance (for example)
		* Replace **Epic_Auth_JWT** with the name of the Named Credential resulting from the MuleSoft Direct setup above (e.g. **Health_generic_system_app**)
	* **Activate** your new Integration Procedure version

## MuleSoft Anypoint Platform

<h3>1. Configure MuleSoft</h3>

* Follow the [**Epic Administration System API Setup Guide**](https://anypoint.mulesoft.com/exchange/org.mule.examples/hc-accelerator-epic-us-core-administration-sys-api/minor/1.0/pages/edh-nhj/Setup%20Guide/)
* Create a new **Remote Site** (Setup > Remote Site Settings > New Remote Site) with the URL of the newly-created **MuleSoft app**.
* Create a **Named Credential** for your **MuleSoft app**:
	* Refer to **steps 5 - 8** in this article for the detailed setup: [https://sfdc247.com/2021/11/step-by-step-guide-on-integrating-mulesoft-and-salesforce.html](https://sfdc247.com/2021/11/step-by-step-guide-on-integrating-mulesoft-and-salesforce.html)
	* You do **NOT** need to complete the **External Services** configuration in the article above

<h3>2. Configure the Accelerator for MuleSoft</h3>

* App Launcher > Integration Procedures > EpicFHIRGetData
	* Create a **New Version** of the Integration Procedure
	* For the **HTTP Action** element, make the following changes:
		* In the **Path** field, set it to the URL of the newly-created **MuleSoft app** with the trailing API call - /api/AllergyIntolerance (for example)
		* In the Named Credential field, Replace **Epic_Auth_JWT** with the newly created **Named Credential** for your **MuleSoft app**

## Epic Direct Connection


Required SKUs:
* Health Cloud

<h3>1. EHR Pre-Configuration Steps:</h3>

* Ensure your EHR system's network is configured to accept traffic from your Health Cloud org.
* Install the Epic on FHIR App called “**Salesforce Health Cloud - Clinical Summary**” into your Epic organization. 
	* **Client ID:** 43b0500b-ea80-41d4-be83-21230c837c15

<h3>2. Salesforce Pre-Installation Steps:</h3>

<h4>Create a new Custom Metadata Type </h4>

* Setup > **Custom Metadata Types**
	* New Metadata Type - **must be named** as follows:  **ClientCredentialsJWT**
        * Add the following **Custom fields**. All fields should be **“Text”** fields with a length of **255** characters.
            * aud
            * callback uri
            * cert
            * iss
            * jti
            * sub
![](/images/fcimage2.png)
<h4>Install custom Apex Class</h4>

* Open the **“salesforce-sfdx”** folder in the .zip file that you downloaded for the Accelerator. 
* Use IDX or sfdx to install the files under the “salesforce-sfdx” folder. 
	* Click here to access the [**IDX workbench**](https://workbench.developerforce.com/login.php)
	* For more information regarding IDX, please review this [**Trailhead**](https://trailhead.salesforce.com/content/learn/modules/omnistudio-developer-tools)
* Alternatively, you may create a new Apex Class manually by performing the following:
	* Setup > Apex Classes > New
	* Copy the entire code of the Apex Class in the salesforce-sfdx folder and paste in the new Apex Class editor and Save.
* Import the keystore **FHIRDEMOKEYSTORE.jks** from .zip file. 
	* Setup > **Certificates and Key Management** > Import from **Keystore**
	* **Password**: salesforce1


<h4>Create a new Authentication Provider</h4>

* Setup > Auth Providers
    * Create a New Authentication Provider
        * Provider Type: **ClientCredentialJWT**
        * Name: Epic_JWT_Auth
        * iss: 43b0500b-ea80-41d4-be83-21230c837c15
        * sub: 43b0500b-ea80-41d4-be83-21230c837c15
        * aud: set this to the API endpoint for authentication - either the MuleSoft API or Epic FHIR API - e.g., https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token
        * jti: salesforce
        * cert: fhirdemo_cert
        * callback uri: https://YOURDOMAIN/services/authcallback/Epic_JWT_Auth
        * Execute Registration As: your system administrator User
![](/images/fcimage3.png)
<h4>Configure Remote Site Settings</h4>

* Setup > Remote Site Settings > New
    * Give the Remote Site a name and paste the domain of the API endpoint into the URL field.
    * Click Save.

<h4>Create a new Named Credential</h4>

* Setup > **Named Credential** > **New Legacy**
	* **Name**: **Must be** the following: **Epic Auth JWT**
	* **URL**: the URL of the endpoint you are going to connect to. For example, https://fhir.epic.com/interconnect-fhir-oauth/ 
	* **Identity Type**: Named Principal
	* **Authentication Protocol**: OAuth 2.0
	* **Authentication Provider**: the name of your Authentication Provider above
	* Check the **“Run Authentication Flow on Save”** box

![](/images/fcimage4.png)

![](/images/psimage5.png)


## Configure Accelerator
After completing the respective integration steps, complete the following:

#### 1. Configure FlexCards
* Open each FlexCard and ensure it is Activated. If it is not, do the following:
	* Deactivate the FlexCard
	* Activate the FlexCard
	* For Publish Options, select “Record Page” and click Save.
* The following FlexCards have been pre-populated with sample data, as the [fhir.epic.com](http://fhir.epic.com/) sandbox did not provide real-time test data for validation. Therefore, in order to connect these FlexCards with your Epic instance, please follow the subsequent steps.
	* **EpicFHIRPatientFYI**
		* Setup Pane:
			* Data Source Type = Integration Procedure
			* Name = EHR_AuthAndDataParent   
			* Input Map:
				* ContextId = **{recordId}**
				* DataType = **FYI**
			* Click “**Save and Fetch**” to save the configuration
		* Activate the FlexCard
		* For Publish Options, select “Record Page” and click Save.
	* **EpicFHIRCarePlanOP**
		* Setup Pane:
			* Data Source Type = Integration Procedure
			* Name = EHR_AuthAndDataParent   
			* Input Map:
				* ContextId = **{recordId}**
				* DataType = **CarePlanOP**
			* Click “**Save and Fetch**” to save the configuration
		* Click on the Child FlexCard called “**EpicFHIRCarePlanGoalOP**”
			* Set the **“Data Node” = {records.Goal}**
![](/images/fcimage5.png)
		* Activate the FlexCard
		* For Publish Options, select “Record Page” and click Save.
	 * **EpicFHIRCareTeam**
		* Setup Pane:
			* Data Source Type = Integration Procedure
			* Name = EHR_AuthAndDataParent   
			* Input Map:
				* ContextId = **{recordId}**
				* DataType = **CareTeamLong**
			* Click “**Save and Fetch**” to save the configuration
		* Activate the FlexCard
		* For Publish Options, select “Record Page” and click Save.

#### Add FlexCards to Person Account Lightning Page
* **Add the following parent FlexCards to the Person Account Lightning Page:**
	* **Patient Demographics Information** → Add “**EpicFHIRPatientInfoCore**” 
	* **Patient Clinical Information** → Add “**EpicFHIRHealthInfoParentCore**”
	* **Patient Visit Information** → Add “**EpicFHIRVisitsParentCore**”
	* Save your lightning page and activate it appropriately for your users/profiles. 



## Troubleshooting

1. **When migrating the accelerator to your destination org, an error message that reads “LWC Activation Error >> VlocityCard [{"message":"You put 'lightning__AppPage' in the <targetConfigs> targets attribute, but it isn't specified in the <targets> section.","errorCode":"AURA_COMPILE_ERROR","fields":[]}]"**
    1. The FlexCard should have migrated successfully but was not activated. Navigate to the FlexCard in the destination org and Activate it. Select “Record Page” in the publish options.
2. **When migrating the accelerator to your destination org, an error message that reads that the URL is not found in the Remote Site Settings**
    1. The FlexCard should have migrated successfully but was not activated. Navigate to the FlexCard in the destination org and Activate it. Select “Record Page” in the publish options.
    2. On the FlexCard record list, click the “Warnings” button and add the indicated URLs as Remote Sites in Setup > Remote Site Settings
3. **Error indicating that there is not a child LWC found when activating a FlexCard**
    1. Please activate all child FlexCards before activating parent FlexCards. This should resolve the issue. 

## **Assumptions**

1. A customer has licenses for Health Cloud withe OmniStudio, or the HINS Managed Package with OmniStudio. These solutions have all been installed and are functional. 
2. A customer is assuming Salesforce Lightning Experience — not Classic.
3. Data Model elements that are part of the HINS (Vlocity) Managed package or Health Cloud with OmniStudio are all available.
4. The Accelerator uses the Lightning Design System standards and look. Customers may want to apply their own branding which can be achieved.
5. A customer has an administrator/developer who is familiar with IDX and OmniStudio.
6. A customer is live with Epic EHR and has their FHIR R4 server active.
7. Epic is a trademark of Epic Systems Corporation.



## **Revision History**

* **Revision Short Description (Month Day, Year)**
    * January 4, 2023 - Initial draft
    * January 23, 2023 - Updated documentation
    * April 7, 2023 - Updated documentation
    * May 4, 2023 - updated with configuration steps for MuleSoft customers
    * May 23, 2023 - updated documentation for easier navigation and MuleSoft Direct instructions






