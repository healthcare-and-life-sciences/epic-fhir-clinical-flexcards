![](/images/ahlsbanner.png)

# A-HLS EHR Clinical Data FlexCards Documentation 

The EHR Clinical Data FlexCards enables an organization to show read-only, external clinical data for a patient within Health Cloud. At this time, the accelerator is limited to clinical data from organization’s Epic instances. 

The accelerator is compatible with both MuleSoft or via a direct connection via FHIR APIs with Epic. After a few configuration steps, an organization is ready to start using the Patient Search component in their workflows.

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
    * EpicFHIRPatientInfo
        * EpicFHIRPatientFYI
* **Clinical Information:**
    * EpicFHIRHealthInfoParent
        * EpicFHIRAllergies
        * EpicFHIRPatientConditions
        * EpicFHIRPatientMedications
        * EpicFHIRCarePlanOP
        * EpicFHIRCarePlanLong
        * EpicFHIRCareTeam
        * EpicFHIRSocialHistoryParent
            * EpicFHIRSocialHistory
* **Appointment Information:**
    * EpicFHIRVisitsParent
        * EpicFHIRPatientAppointments
        * EpicFHIRPatientEncounters

### Integration Procedures (3)

* EHR/AuthAndDataParent

Input Options:

|Input Variable	|Possible Values	|Required?	|
|---	|---	|---	|
|DataType	|Allergies - Patient's Allergies, CarePlanLong - Longitudinal Care Plan, CarePlanOP - Outpatient Care Plan, Conditions - Patient's Conditions, Demographics - Patient's demographics and contact information, Encounters - Patient's past encounters, Medications - Patient's Medications, Social - Patient's Social History (e.g., Smoking History), Appointments - Patient's Upcoming Appointments, CareTeamLong - Patient's Longitudinal Care Team, PatientFYI - Patient's FYI Flags	|Y	|
|ContextId	|{recordId} - do not change this variable	|Y	|

* EHRConnect/GetData

### DataRaptors (15)

* Extracts:
    * GetPatientEHRId
* Transforms:
    * EpicFHIRPatientAllergiesXMLtoJSON
    * EpicFHIRCarePlanLongXMLtoJSON
    * EpicFHIROPCarePlanXMLtoJSON
    * EpicFHIRPatientConditionsXMLtoJSON
    * EpicFHIRPatientDemographicsXMLToJSON
    * DREpicPatient2JSONtoJSON
    * EpicFHIREncountersXMLtoJSON
    * EpicFHIRMedicationXMLtoJSON
    * EpicFHIRSocialHistoryXMLtoJSON
    * EpicFHIRPatientAppointmentsXMLtoJSON
    * DRTransformCareTeamJSONtoJSON
    * EpicFHIRPatientFYIXMLtoJSON

### **Custom Apex Class (1)**

* ClientCredentialsJWT.cls

* * *

## Configuration Requirements

### Pre-Install Configuration Steps:

1. **EHR Pre-Configuration Steps:**
    1. Identify your [fhir.epic.com](https://fhir.epic.com/) endpoint
    2. Confirm that your endpoint is configured such that the following APIs are active - for full reference, please refer to the [fhir.epic.com](http://fhir.epic.com/) API documentation.
        1. api/FHIR/R4/AllergyIntolerance
        2. api/FHIR/R4/CarePlan
        3. api/FHIR/R4/Condition
        4. api/FHIR/R4/Patient
        5. api/FHIR/R4/Encounter
        6. api/FHIR/R4/MedicationRequest
        7. api/FHIR/R4/Observation
        8. /api/FHIR/STU3/Appointment
        9. api/FHIR/R4/CareTeam
        10. api/FHIR/R4/Flag
    3. Ensure your EHR system's network is configured to accept traffic from your Health Cloud org
    4. Install the Epic on FHIR App called “**Salesforce Health Cloud - Clinical Summary**” into your Epic organization.
        1. **Client ID:** 43b0500b-ea80-41d4-be83-21230c837c15
2. **Salesforce Pre-Installation Steps:**
    1. Ensure your Salesforce Health Cloud org has OmniStudio installed. 
        1. To verify installation, please navigate to Setup > Installed Packages > OmniStudio.
        2. If OmniStudio is not installed, please follow the instructions found here: https://help.salesforce.com/s/articleView?id=sf.os_omnistudio_release_summary_for_installation_and_upgrade.htm&type=5
    2. Create Custom Metadata for Authentication Provider:
        1. Setup > Custom Metadata Types
        2. New Metadata Type - ensure it is named **“ClientCredentialJWT”**
        3. Add the following Custom fields:
            1. aud
            2. callback url
            3. cert
            4. iss
            5. jti
            6. sub
            7. 
![](/images/fcimage2.png)

### Install the Accelerator 

1. Use IDX to install the files located in the GitHub repository here: https://github.com/healthcare-and-life-sciences/epic-fhir-clinical-flexcards
    1. To access the IDX workbench, please navigate to this URL: https://workbench.developerforce.com/login.php
    2. For more information regarding IDX, please review this Trailhead: https://trailhead.salesforce.com/content/learn/modules/omnistudio-developer-tools

### Post-Install Configuration Steps:

1. Create a new Authentication Provider
    1. Setup > Auth Providers
    2. Create a New Authentication Provider
        1. Provider Type: Custom
        2. Name: Epic_JWT_Auth
        3. Plugin: ClientCredentialJWT
        4. iss: 7a88a6d4-453f-4b34-a48e-e4a5c667285a
        5. sub: 7a88a6d4-453f-4b34-a48e-e4a5c667285a
        6. aud: set this to the API endpoint for authentication - either the MuleSoft API or Epic FHIR API - e.g., https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token
        7. jti: salesforce
        8. cert: fhirdemo_cert
        9. callback url: [https://](https://%3Cyour/)<your salesforce org domain>/services/authcallback/Epic_JWT_Auth
![](/images/fcimage3.png) 
2. **Create a new Named Credential**
    1. Setup > Named Credential > New Legacy
        1. Give your Named Credential a name 
        2. Identity Type: Named Principal
        3. Authentication Protocol: OAuth 2.0
        4. Authentication Provider: the name of your Authentication Provider above
        5. “Run Authentication Flow on Save”: Checked
![](/images/fcimage4.png)
3. **Configure FlexCards**
    1. Open each FlexCard
        1. Deactivate the FlexCard
        2. Activate the FlexCard
    2. The following FlexCards have been pre-populated with sample data, as the [fhir.epic.com](http://fhir.epic.com/) sandbox did not provide real-time test data for validation. Therefore, in order to connect these FlexCards with your Epic instance, please follow the subsequent steps. 
        1. **EpicFHIRPatientFYI**
            1. Setup Pane:
                1. Data Source Type = Integration Procedure
                2. Name = EHR_AuthAndDataParent
                3. Input Map:
                    1. ContextId = **{recordId}**
                    2. DataType = **FYI**
                4. Click “**Save and Fetch**” to save the configuration
        2. **EpicFHIRCarePlanOP**
            1. Setup Pane:
                1. Data Source Type = Integration Procedure
                2. Name = EHR_AuthAndDataParent
                3. Input Map:
                    1. ContextId = **{recordId}**
                    2. DataType = **CarePlanOP**
                4. Click “**Save and Fetch**” to save the configuration
            2. Click on the Child FlexCard called “**EpicFHIRCarePlanGoalOP**”
                1. Set the **“Data Node” = {records.Goal}**
![](/images/fcimage5.png)
            3. Activate the FlexCard
        3. **EpicFHIRCareTeam**
            1. Setup Pane:
                1. Data Source Type = Integration Procedure
                2. Name = EHR_AuthAndDataParent
                3. Input Map:
                    1. ContextId = **{recordId}**
                    2. DataType = **CareTeamLong**
                4. Click “**Save and Fetch**” to save the configuration
4. **Add the following parent FlexCards to the Person Account Lightning Page:**
    1. **Patient Demographics Information** → Add “**EpicFHIRPatientInfo**”
    2. **Patient Clinical Information** → Add “**EpicFHIRHealthInfoParent**”
    3. **Patient Visit Information** → Add “**EpicFHIRVisitsParent**”
    4. Save your lightning page and activate it appropriately for your users/profiles. 

* * *

## Assumptions

1. A customer has licenses for Health Cloud withe OmniStudio, or the HINS Managed Package with OmniStudio. These solutions have all been installed and are functional.
2. A customer is assuming Salesforce Lightning Experience — not Classic.
3. Data Model elements that are part of the HINS (Vlocity) Managed package or Health Cloud with OmniStudio are all available.
4. The Accelerator uses the Lightning Design System standards and look. Customers may want to apply their own branding which can be achieved.
5. A customer has an administrator/developer who is familiar with IDX and OmniStudio.

* * *

## Revision History

* **Revision Short Description (Month Day, Year)**

    * December 15, 2022 - Initial Draft
    * January 13, 2023 - Updated
    * April 7, 2023 - updated
    * April 17, 2023 - updated with Named Credential implementation requirements




