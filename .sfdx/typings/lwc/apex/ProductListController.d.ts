declare module "@salesforce/apex/ProductListController.getReleatedListsMetadata" {
  export default function getReleatedListsMetadata(param: {objectId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getReleatedListMetadata" {
  export default function getReleatedListMetadata(param: {objectId: any, relatedListLabel: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getOpportunityProductMetadata" {
  export default function getOpportunityProductMetadata(param: {objectId: any, relatedListLabel: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getReleatedListItems" {
  export default function getReleatedListItems(param: {objectId: any, relatedlistName: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.saveRelatedListItems" {
  export default function saveRelatedListItems(param: {jsonData: any, initialData: any, selectedData: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getLookupCandidates" {
  export default function getLookupCandidates(param: {refObjName: any, searchTerm: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getObject" {
  export default function getObject(param: {objectId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.createRelatedObject" {
  export default function createRelatedObject(param: {objectId: any, objectName: any, jsonData: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getBillingGroups" {
  export default function getBillingGroups(param: {objectId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getSelectedBillingGroups" {
  export default function getSelectedBillingGroups(param: {objectId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.createBillingGroup" {
  export default function createBillingGroup(param: {billingGroup: any, itemId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getDomesticPartnershipAllowed" {
  export default function getDomesticPartnershipAllowed(): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getRequestedRatingClass" {
  export default function getRequestedRatingClass(): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getRequestedCobraAdmin" {
  export default function getRequestedCobraAdmin(): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getRetroCancellationAllowance" {
  export default function getRetroCancellationAllowance(): Promise<any>;
}
declare module "@salesforce/apex/ProductListController.getRequestedCobraAdminOptions" {
  export default function getRequestedCobraAdminOptions(): Promise<any>;
}
