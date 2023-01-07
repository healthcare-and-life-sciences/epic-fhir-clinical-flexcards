![](/images/ahlsbanner.png)
<h1>A-HLS EHR Clinical Data FlexCards Documentation </h1>

The EHR Clinical Data FlexCards enables an organization to show read-only, external clinical data for a patient within Health Cloud. At this time, the accelerator is limited to clinical data from organization’s Epic instances. 

<h2>Overview</h2>

The following clinical objects are included in the Accelerator:
*Patient Information*

* Full Name
* MRN
* Date of Birth
* Age
* Gender
* Marital Status
* PCP
* Preferred Language
* Active and Inactive Patient FYIs

*Contact Information:*

* Address
* Phone Numbers (Home, Work, Mobile)
* Email

*Health Information:*

* Allergies
* Conditions
* Medications
* Longitudinal Care Plan
* Outpatient Care Plan(s)
* Longitudinal Care Team
* Social History

*Appointment Information:*

* Upcoming Appointments
* Past Encounters

![](/images/Flexcard1.png)
<h2>Business Objective</h2>

The EHR Clinical Data FlexCards enables an organization to show a patient’s or member’s clinical data within Salesforce.  

<h3>Business Value and Benefits</h3>

* Reduce IT Cost
* Reduce Implementation Cost
* Improve User Experience
* Improve Patient Satisfaction


<h2>Industry Focus and Workflow</h2>

<h3>Primary Industry:</h3>

* Provider
* Payvider

Primary User Persona:

* Call Center Agent
* Care Coordinator

User Workflow:

* A user opens the patient’s Person Account record in Salesforce and views the clinical data in the form of FlexCards (Lightning Web Components) on the record.


<h2>Package Includes:</h2>

*FlexCards (23)*

* *Patient Demographics:*
    * EpicFHIRPatientInfo
        * EpicFHIRPatientFYI
        * EpicFHIRPatientContactInfo
* *Clinical Information:*
    * EpicFHIRHealthInfoParent
        * EpicFHIRPatientAllergies
        * EpicFHIRPatientConditions
        * EpicFHIRPatientMedications
        * EpicFHIRCarePlanOP
            * EpicFHIRCarePlanActivitiesOP
        * EpicFHIRCarePlanLong
            * EpicFHIRCarePlanProblems
            * EpicFHIRCarePlanLongGoals
            * EpicFHIRCarePlanActivities
        * EpicFHIRCareTeam
        * EpicFHIRSocialHistoryParent
            * EpicFHIRSocialHistory
* *Appointment Information:*
    * EpicFHIRVisitsParent
        * EpicFHIRPatientAppointments
        * EpicFHIRPatientEncounters

Integration Procedures (2)

* EpicFHIR/GetData

Input Options:

| Input Variable      | Possible Values | Required? |
| ----------- | ----------- | ----------- |
| env      | The name of the Custom Setting which stores the fhir endpoint of your fhir server | Y |
| DataType      | **Allergies** - Patient's Allergies, **CarePlanLong** - Longitudinal Care Plan, **CarePlanOP** - Outpatient Care Plan, **Conditions** - Patient's Conditions, **Demographics** - Patient's demographics and contact information, **Encounters** - Patient's past encounters, **Medications** - Patient's Medications, **Social** - Patient's Social History (e.g., Smoking History), **Appointments** - Patient's Upcoming Appointments, **CareTeamLong** - Patient's Longitudinal Care Team, **FYI** - Patient's FYI Flags | Y | 
| ContextId      | {recordId} - do not change this variable | Y | 

* EHRConnect/getToken

DataRaptors (15)

* Extracts:
    * DRGetEpicToken
    * GetPatientEHRId
    * GetCustomSetting
* Posts:
    * DRStoreEpicToken
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

*Custom Apex Class (1)*

* getToken - This apex class authenticates with the configured fhir endpoint to support the reading of clinical data.

Custom Setting (1)

* Epic_FHIR_Endpoint - This setting stores the authentication information for the fhir endpoint that is used.

Custom Object (1)

* Epic_Access__c - This object stores the most recent authentication token and expiration date for reuse.

KeyStore (1)

* FHIRDEMO_KEYSTORE.jks


<h2>Configuration Requirements</h2>

<h3>Pre-Install Configuration Steps:</h3>

1. *EHR Pre-Configuration Steps:*
    1. Identify your fhir.epic.com (https://fhir.epic.com/) endpoint
    2. Confirm that your endpoint is configured such that the following APIs are active - for full reference, please refer to the fhir.epic.com (http://fhir.epic.com/) API documentation.
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
2. *Health Cloud Pre-Configuration Steps:*
    1. Go to Setup > Certificate and Key Management > Create a Self-Signed Certificate. Refer to this guide for more information: https://help.salesforce.com/s/articleView?id=sf.security_keys_creating.htm&type=5
    2. After creating your Self-Signed Certificate, navigate to Setup > Identity Provider and enable Identity Provider. Refer to this guide for more information: https://help.salesforce.com/s/articleView?id=sf.identity_provider_enable.htm&type=5
    3. Navigate back to the Certificate and Key Management > Import from Keystore > upload the FHIREDEMO_KEYSTORE.jks file found in the GitHub repo. Use the password "salesforce1" to import the keuystore.
    4. Add the fhir.epic.com (https://fhir.epic.com/) endpoint to the Remote Site Settings in your Health Cloud org. This will allow you to test the accelerator with the fhir sandbox data.

<h3>Install the Accelerator</h3>

1. Use IDX to install the files located in the GitHub repository here: https://github.com/healthcare-and-life-sciences/epic-fhir-clinical-flexcards
    1. To access the IDX workbench, please navigate to this URL: https://workbench.developerforce.com/login.php
    2. For more information regarding IDX, please review this Trailhead: https://trailhead.salesforce.com/content/learn/modules/omnistudio-developer-tools
2. Install the Epic on FHIR App called “*Salesforce Health Cloud - Clinical Summary*” into your Epic organization.
    1. *Client ID:* 43b0500b-ea80-41d4-be83-21230c837c15

<h3>Post-Install Configuration Steps:</h3>

1. *Add Custom Setting for your endpoint*
    1. Set the following attributes:
        1. Name = “Production”
        2. URL = your organization’s fhir endpoint URL domain. E.g. - 
            https://fhir.epic.com/interconnect-fhir-oauth
        3. client_id = the Client ID for the Salesforce Health Cloud - Clinical Summary FHIR App
        4. jti = salesforce (or your label of choice)
        5. cert = "fhirdemo_cert"

![](/images/Flexcard2.png)
1. Create a single Epic Access record and name the record "Epic". This must be set to Epic in order for the accelerator to work properly.

![](/images/Flexcard3.png)
1. *Configure FlexCards*
    1. By default, each FlexCard is configured to use the Sandbox fhir endpoint. Repeat the following steps for each FlexCard to be used (including Child FlexCards):
        1. On the Setup tab of the FlexCard, change the “env” variable value to the name of the Custom Setting - e.g., “Production”.
        2. Save and Fetch the data
        3. Activate the FlexCard

b. The following FlexCards have been pre-populated with sample data, as the fhir.epic.com (http://fhir.epic.com/) sandbox did not provide real-time test data for validation. 


*EpicFHIRPatientFYI*
1. Setup Pane:
    1. Data Source Type = Integration Procedure
        2. Name = EpicFHIR_GetData
        3. Input Map:
          1. env = “*Production*“ (or the name of the Custom Setting you configured)
          2. ContextId = *{recordId}*
          3. DataType = *FYI*
        4. Click “*Save and Fetch*” to save the configuration
*EpicFHIRCarePlanOP*
1. Setup Pane:
    1. Data Source Type = Integration Procedure
        2. Name = EpicFHIR_GetData
        3. Input Map:
          1. env = “*Production*“ (or the name of the Custom Setting you configured)
          2. ContextId = *{recordId}*
          3. DataType = *CarePlanOP*
        4. Click “*Save and Fetch*” to save the configuration
    2. Click on the Child FlexCard called “*EpicFHIRCarePlanGoalOP*”
        1. Set the *“Data Node” = {records.Goal}*
                
<img src="/images/Flexcard5.png" alt="drawing" width="50"/>

    3. Activate the FlexCard
*EpicFHIRCareTeam*
1. Setup Pane:
    1. Data Source Type = Integration Procedure
        2. Name = EpicFHIR_GetData
        3. Input Map:
          1. env = “*Production*“ (or the name of the Custom Setting you configured)
          2. ContextId = *{recordId}*
          3. DataType = *CareTeamLong*
        4. Click “*Save and Fetch*” to save the configuration

1. *Add the following parent FlexCards to the Person Account Lightning Page:*
    1. *Patient Demographics Information* → Add “*EpicFHIRPatientInfo*”
    2. *Patient Clinical Information* → Add “*EpicFHIRHealthInfoParent*”
    3. *Patient Visit Information* → Add “*EpicFHIRVisitsParent*”
    4. Save your lightning page and activate it appropriately for your users/profiles. 


<h2>Assumptions</h2>

1. A customer has licenses for Health Cloud, and the HINS Managed Package with OmniStudio. These solutions have all been installed and are functional.
2. A customer is assuming Salesforce Lightning Experience — not Classic.
3. Data Model elements that are part of the HINS (Vlocity) Managed package and Health Cloud are all available.
4. The Accelerator uses the Lightning Design System standards and look. Customers may want to apply their own branding which can be achieved.
5. A customer has an administrator/developer who is familiar with IDX and OmniStudio.


<h2>Revision History</h2>

* *Revision Short Description (Month Day, Year)*

    * December 15, 2022

