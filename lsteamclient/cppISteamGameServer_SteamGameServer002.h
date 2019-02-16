#ifdef __cplusplus
extern "C" {
#endif
extern void cppISteamGameServer_SteamGameServer002_LogOn(void *);
extern void cppISteamGameServer_SteamGameServer002_LogOff(void *);
extern bool cppISteamGameServer_SteamGameServer002_BLoggedOn(void *);
extern void cppISteamGameServer_SteamGameServer002_GSSetSpawnCount(void *, uint32);
extern bool cppISteamGameServer_SteamGameServer002_GSGetSteam2GetEncryptionKeyToSendToNewClient(void *, void *, uint32 *, uint32);
extern bool cppISteamGameServer_SteamGameServer002_GSSendSteam2UserConnect(void *, uint32, const void *, uint32, uint32, uint16, const void *, uint32);
extern bool cppISteamGameServer_SteamGameServer002_GSSendSteam3UserConnect(void *, CSteamID, uint32, const void *, uint32);
extern bool cppISteamGameServer_SteamGameServer002_GSRemoveUserConnect(void *, uint32);
extern bool cppISteamGameServer_SteamGameServer002_GSSendUserDisconnect(void *, CSteamID, uint32);
extern bool cppISteamGameServer_SteamGameServer002_GSSendUserStatusResponse(void *, CSteamID, int, int);
extern bool cppISteamGameServer_SteamGameServer002_Obsolete_GSSetStatus(void *, int32, uint32, int, int, int, int, const char *, const char *, const char *, const char *);
extern bool cppISteamGameServer_SteamGameServer002_GSUpdateStatus(void *, int, int, int, const char *, const char *);
extern bool cppISteamGameServer_SteamGameServer002_BSecure(void *);
extern CSteamID cppISteamGameServer_SteamGameServer002_GetSteamID(void *);
extern bool cppISteamGameServer_SteamGameServer002_GSSetServerType(void *, int32, uint32, uint32, uint32, const char *, const char *);
extern bool cppISteamGameServer_SteamGameServer002_GSSetServerType2(void *, int32, uint32, uint32, uint16, uint16, uint16, const char *, const char *, bool);
extern bool cppISteamGameServer_SteamGameServer002_GSUpdateStatus2(void *, int, int, int, const char *, const char *, const char *);
extern bool cppISteamGameServer_SteamGameServer002_GSCreateUnauthenticatedUser(void *, CSteamID *);
extern bool cppISteamGameServer_SteamGameServer002_GSSetUserData(void *, CSteamID, const char *, uint32);
extern void cppISteamGameServer_SteamGameServer002_GSUpdateSpectatorPort(void *, uint16);
extern void cppISteamGameServer_SteamGameServer002_GSSetGameType(void *, const char *);
#ifdef __cplusplus
}
#endif
