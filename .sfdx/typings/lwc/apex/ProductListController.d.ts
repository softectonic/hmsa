declare module "@apex/ProductListController.getReleatedListsMetadata" {
  export function getReleatedListsMetadata(param: {objectId: any}): Promise<any>;
}
declare module "@apex/ProductListController.getReleatedListMetadata" {
  export function getReleatedListMetadata(param: {objectId: any, relatedListLabel: any}): Promise<any>;
}
declare module "@apex/ProductListController.getOpportunityProductMetadata" {
  export function getOpportunityProductMetadata(param: {objectId: any, relatedListLabel: any}): Promise<any>;
}
declare module "@apex/ProductListController.getReleatedListItems" {
  export function getReleatedListItems(param: {objectId: any, relatedlistName: any}): Promise<any>;
}
declare module "@apex/ProductListController.saveRelatedListItems" {
  export function saveRelatedListItems(param: {jsonData: any, initialData: any, selectedData: any}): Promise<any>;
}
declare module "@apex/ProductListController.getLookupCandidates" {
  export function getLookupCandidates(param: {refObjName: any, searchTerm: any}): Promise<any>;
}
declare module "@apex/ProductListController.getObject" {
  export function getObject(param: {objectId: any}): Promise<any>;
}
declare module "@apex/ProductListController.createRelatedObject" {
  export function createRelatedObject(param: {objectId: any, objectName: any, jsonData: any}): Promise<any>;
}
declare module "@apex/ProductListController.getBillingGroups" {
  export function getBillingGroups(param: {objectId: any}): Promise<any>;
}
declare module "@apex/ProductListController.getSelectedBillingGroups" {
  export function getSelectedBillingGroups(param: {objectId: any}): Promise<any>;
}
declare module "@apex/ProductListController.createBillingGroup" {
  export function createBillingGroup(param: {billingGroup: any, itemId: any}): Promise<any>;
}
declare module "@apex/ProductListController.getDomesticPartnershipAllowed" {
  export function getDomesticPartnershipAllowed(): Promise<any>;
}
declare module "@apex/ProductListController.getRequestedRatingClass" {
  export function getRequestedRatingClass(): Promise<any>;
}
declare module "@apex/ProductListController.getRequestedCobraAdmin" {
  export function getRequestedCobraAdmin(): Promise<any>;
}
declare module "@apex/ProductListController.getRetroCancellationAllowance" {
  export function getRetroCancellationAllowance(): Promise<any>;
}
declare module "@apex/ProductListController.getRequestedCobraAdminOptions" {
  export function getRequestedCobraAdminOptions(): Promise<any>;
}
