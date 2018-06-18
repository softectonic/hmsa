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
  export function saveRelatedListItems(param: {jsonData: any}): Promise<any>;
}
declare module "@apex/ProductListController.getLookupCandidates" {
  export function getLookupCandidates(param: {refObjName: any, searchTerm: any}): Promise<any>;
}
declare module "@apex/ProductListController.deleteRelatedRecord" {
  export function deleteRelatedRecord(param: {objectId: any}): Promise<any>;
}
declare module "@apex/ProductListController.getObject" {
  export function getObject(param: {objectId: any}): Promise<any>;
}
declare module "@apex/ProductListController.createRelatedObject" {
  export function createRelatedObject(param: {objectId: any, objectName: any, jsonData: any}): Promise<any>;
}
