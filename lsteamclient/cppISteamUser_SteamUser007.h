#ifdef __cplusplus
extern "C" {
#endif
extern HSteamUser cppISteamUser_SteamUser007_GetHSteamUser(void *);
extern void cppISteamUser_SteamUser007_LogOn(void *, CSteamID);
extern void cppISteamUser_SteamUser007_LogOff(void *);
extern bool cppISteamUser_SteamUser007_BLoggedOn(void *);
extern CSteamID cppISteamUser_SteamUser007_GetSteamID(void *);
extern bool cppISteamUser_SteamUser007_SetRegistryString(void *, EConfigSubTree, const char *, const char *);
extern bool cppISteamUser_SteamUser007_GetRegistryString(void *, EConfigSubTree, const char *, char *, int);
extern bool cppISteamUser_SteamUser007_SetRegistryInt(void *, EConfigSubTree, const char *, int);
extern bool cppISteamUser_SteamUser007_GetRegistryInt(void *, EConfigSubTree, const char *, int *);
extern int cppISteamUser_SteamUser007_InitiateGameConnection(void *, void *, int, CSteamID, CGameID, uint32, uint16, bool, void *, int);
extern void cppISteamUser_SteamUser007_TerminateGameConnection(void *, uint32, uint16);
extern void cppISteamUser_SteamUser007_TrackAppUsageEvent(void *, CGameID, int, const char *);
extern void cppISteamUser_SteamUser007_RefreshSteam2Login(void *);
#ifdef __cplusplus
}
#endif
