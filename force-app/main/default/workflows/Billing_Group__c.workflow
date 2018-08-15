<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Billing_Group_Set_Customer_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Customer</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Billing Group: Set Customer Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Default_Group_Number</fullName>
        <field>Group_Number__c</field>
        <formula>System_Auto_Number__c</formula>
        <name>Set Default Group Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Billing Group%3A Set Customer Record Type</fullName>
        <actions>
            <name>Billing_Group_Set_Customer_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Billing_Group__c.Group_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Customer_Stage__c</field>
            <operation>equals</operation>
            <value>First Opportunity Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Prospect</value>
        </criteriaItems>
        <description>Sets the Account record type to Customer if it is Prospect and Stage is First Opportunity Won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Default Group Number</fullName>
        <actions>
            <name>Set_Default_Group_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the default Group Number value from the System Auto Number field for new Groups.</description>
        <formula>$User.Run_Automation__c</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
