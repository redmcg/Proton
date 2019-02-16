#ifdef __cplusplus
extern "C" {
#endif
extern UGCQueryHandle_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_CreateQueryUserUGCRequest(void *, AccountID_t, EUserUGCList, EUGCMatchingUGCType, EUserUGCListSortOrder, AppId_t, AppId_t, uint32);
extern UGCQueryHandle_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_CreateQueryAllUGCRequest(void *, EUGCQuery, EUGCMatchingUGCType, AppId_t, AppId_t, uint32);
extern UGCQueryHandle_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_CreateQueryUGCDetailsRequest(void *, PublishedFileId_t *, uint32);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SendQueryUGCRequest(void *, UGCQueryHandle_t);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetQueryUGCResult(void *, UGCQueryHandle_t, uint32, SteamUGCDetails_t *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetQueryUGCPreviewURL(void *, UGCQueryHandle_t, uint32, char *, uint32);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetQueryUGCMetadata(void *, UGCQueryHandle_t, uint32, char *, uint32);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetQueryUGCChildren(void *, UGCQueryHandle_t, uint32, PublishedFileId_t *, uint32);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetQueryUGCStatistic(void *, UGCQueryHandle_t, uint32, EItemStatistic, uint32 *);
extern uint32 cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetQueryUGCNumAdditionalPreviews(void *, UGCQueryHandle_t, uint32);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetQueryUGCAdditionalPreview(void *, UGCQueryHandle_t, uint32, uint32, char *, uint32, bool *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_ReleaseQueryUGCRequest(void *, UGCQueryHandle_t);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_AddRequiredTag(void *, UGCQueryHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_AddExcludedTag(void *, UGCQueryHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetReturnLongDescription(void *, UGCQueryHandle_t, bool);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetReturnMetadata(void *, UGCQueryHandle_t, bool);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetReturnChildren(void *, UGCQueryHandle_t, bool);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetReturnAdditionalPreviews(void *, UGCQueryHandle_t, bool);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetReturnTotalOnly(void *, UGCQueryHandle_t, bool);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetLanguage(void *, UGCQueryHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetAllowCachedResponse(void *, UGCQueryHandle_t, uint32);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetCloudFileNameFilter(void *, UGCQueryHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetMatchAnyTag(void *, UGCQueryHandle_t, bool);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetSearchText(void *, UGCQueryHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetRankedByTrendDays(void *, UGCQueryHandle_t, uint32);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_RequestUGCDetails(void *, PublishedFileId_t, uint32);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_CreateItem(void *, AppId_t, EWorkshopFileType);
extern UGCUpdateHandle_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_StartItemUpdate(void *, AppId_t, PublishedFileId_t);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetItemTitle(void *, UGCUpdateHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetItemDescription(void *, UGCUpdateHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetItemUpdateLanguage(void *, UGCUpdateHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetItemMetadata(void *, UGCUpdateHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetItemVisibility(void *, UGCUpdateHandle_t, ERemoteStoragePublishedFileVisibility);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetItemTags(void *, UGCUpdateHandle_t, const SteamParamStringArray_t *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetItemContent(void *, UGCUpdateHandle_t, const char *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetItemPreview(void *, UGCUpdateHandle_t, const char *);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SubmitItemUpdate(void *, UGCUpdateHandle_t, const char *);
extern EItemUpdateStatus cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetItemUpdateProgress(void *, UGCUpdateHandle_t, uint64 *, uint64 *);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SetUserItemVote(void *, PublishedFileId_t, bool);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetUserItemVote(void *, PublishedFileId_t);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_AddItemToFavorites(void *, AppId_t, PublishedFileId_t);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_RemoveItemFromFavorites(void *, AppId_t, PublishedFileId_t);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_SubscribeItem(void *, PublishedFileId_t);
extern SteamAPICall_t cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_UnsubscribeItem(void *, PublishedFileId_t);
extern uint32 cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetNumSubscribedItems(void *);
extern uint32 cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetSubscribedItems(void *, PublishedFileId_t *, uint32);
extern uint32 cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetItemState(void *, PublishedFileId_t);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetItemInstallInfo(void *, PublishedFileId_t, uint64 *, char *, uint32, uint32 *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_GetItemDownloadInfo(void *, PublishedFileId_t, uint64 *, uint64 *);
extern bool cppISteamUGC_STEAMUGC_INTERFACE_VERSION006_DownloadItem(void *, PublishedFileId_t, bool);
#ifdef __cplusplus
}
#endif
