<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Event_Set_Activity_Type</fullName>
        <field>Activity_Type__c</field>
        <formula>TEXT(Type)</formula>
        <name>Event:  Set Activity Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Event_Set_Subject_Default</fullName>
        <field>Subject</field>
        <formula>&apos;Meeting - &apos; &amp;  Account.Name</formula>
        <name>Event: Set Subject Default</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Event%3A Set Activity Type</fullName>
        <actions>
            <name>Event_Set_Activity_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.Type</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sets the &quot;Activity Type&quot; field from Type, so it can be used in custom report types</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Event%3A Set Subject Default</fullName>
        <actions>
            <name>Event_Set_Subject_Default</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.Subject</field>
            <operation>equals</operation>
            <value>Meeting</value>
        </criteriaItems>
        <description>Set a Default Subject if it still equals &quot;Meeting&quot; on creation.  For AMS and HPA Event Record Types.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
