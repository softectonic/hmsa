<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Oppty_Default_Renewal_Date</fullName>
        <field>Effective_Date__c</field>
        <formula>Initiating_Billing_Group__r.Renewal_Date__c</formula>
        <name>Oppty: Default Renewal Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Oppty%3A Default Renewal Date</fullName>
        <actions>
            <name>Oppty_Default_Renewal_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Renewal,Product Changes</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Run_Automation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
