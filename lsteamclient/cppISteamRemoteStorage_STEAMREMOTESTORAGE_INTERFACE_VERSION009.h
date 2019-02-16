#ifdef __cplusplus
extern "C" {
#endif
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileWrite(void *, const char *, const void *, int32);
extern int32 cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileRead(void *, const char *, void *, int32);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileForget(void *, const char *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileDelete(void *, const char *);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileShare(void *, const char *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_SetSyncPlatforms(void *, const char *, ERemoteStoragePlatform);
extern UGCFileWriteStreamHandle_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileWriteStreamOpen(void *, const char *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileWriteStreamWriteChunk(void *, UGCFileWriteStreamHandle_t, const void *, int32);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileWriteStreamClose(void *, UGCFileWriteStreamHandle_t);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileWriteStreamCancel(void *, UGCFileWriteStreamHandle_t);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FileExists(void *, const char *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_FilePersisted(void *, const char *);
extern int32 cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetFileSize(void *, const char *);
extern int64 cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetFileTimestamp(void *, const char *);
extern ERemoteStoragePlatform cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetSyncPlatforms(void *, const char *);
extern int32 cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetFileCount(void *);
extern const char * cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetFileNameAndSize(void *, int, int32 *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetQuota(void *, int32 *, int32 *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_IsCloudEnabledForAccount(void *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_IsCloudEnabledForApp(void *);
extern void cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_SetCloudEnabledForApp(void *, bool);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UGCDownload(void *, UGCHandle_t);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetUGCDownloadProgress(void *, UGCHandle_t, int32 *, int32 *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetUGCDetails(void *, UGCHandle_t, AppId_t *, char **, int32 *, CSteamID *);
extern int32 cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UGCRead(void *, UGCHandle_t, void *, int32, uint32);
extern int32 cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetCachedUGCCount(void *);
extern UGCHandle_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetCachedUGCHandle(void *, int32);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_PublishWorkshopFile(void *, const char *, const char *, AppId_t, const char *, const char *, ERemoteStoragePublishedFileVisibility, SteamParamStringArray_t *, EWorkshopFileType);
extern PublishedFileUpdateHandle_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_CreatePublishedFileUpdateRequest(void *, PublishedFileId_t);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UpdatePublishedFileFile(void *, PublishedFileUpdateHandle_t, const char *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UpdatePublishedFilePreviewFile(void *, PublishedFileUpdateHandle_t, const char *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UpdatePublishedFileTitle(void *, PublishedFileUpdateHandle_t, const char *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UpdatePublishedFileDescription(void *, PublishedFileUpdateHandle_t, const char *);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UpdatePublishedFileVisibility(void *, PublishedFileUpdateHandle_t, ERemoteStoragePublishedFileVisibility);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UpdatePublishedFileTags(void *, PublishedFileUpdateHandle_t, SteamParamStringArray_t *);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_CommitPublishedFileUpdate(void *, PublishedFileUpdateHandle_t);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetPublishedFileDetails(void *, PublishedFileId_t);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_DeletePublishedFile(void *, PublishedFileId_t);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_EnumerateUserPublishedFiles(void *, uint32);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_SubscribePublishedFile(void *, PublishedFileId_t);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_EnumerateUserSubscribedFiles(void *, uint32);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UnsubscribePublishedFile(void *, PublishedFileId_t);
extern bool cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UpdatePublishedFileSetChangeDescription(void *, PublishedFileUpdateHandle_t, const char *);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetPublishedItemVoteDetails(void *, PublishedFileId_t);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_UpdateUserPublishedItemVote(void *, PublishedFileId_t, bool);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_GetUserPublishedItemVoteDetails(void *, PublishedFileId_t);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_EnumerateUserSharedWorkshopFiles(void *, CSteamID, uint32, SteamParamStringArray_t *, SteamParamStringArray_t *);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_PublishVideo(void *, EWorkshopVideoProvider, const char *, const char *, const char *, AppId_t, const char *, const char *, ERemoteStoragePublishedFileVisibility, SteamParamStringArray_t *);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_SetUserPublishedFileAction(void *, PublishedFileId_t, EWorkshopFileAction);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_EnumeratePublishedFilesByUserAction(void *, EWorkshopFileAction, uint32);
extern SteamAPICall_t cppISteamRemoteStorage_STEAMREMOTESTORAGE_INTERFACE_VERSION009_EnumeratePublishedWorkshopFiles(void *, EWorkshopEnumerationType, uint32, uint32, uint32, SteamParamStringArray_t *, SteamParamStringArray_t *);
#ifdef __cplusplus
}
#endif
