#!/usr/bin/env python3

import os
import sys
import subprocess

class VDFFile:
    def __init__(self, f):
        self.f = f

    def tab(self, depth):
        self.f.write("\t" * depth)

    def write_string(self, key, value, depth):
        self.tab(depth)
        self.f.write("\"{}\"\t\t\"{}\"\n".format(key, value).replace("\\","\\\\"))

    def write_dict_item(self, key, value, depth):
        if value is None:
           pass
        elif isinstance(value,dict):
           self.write_dict(key, value, depth)
        elif isinstance(value,str):
           self.write_string(key, value, depth)
        else:
           value.writeTo(self, key, depth)

    def write_open(self, name, depth):
        self.tab(depth)
        self.f.write("\"{}\"\n".format(name))
        self.tab(depth)
        self.f.write("{\n") 
    
    def write_close(self, depth):
        self.tab(depth)
        self.f.write("}\n")

    def write_dict(self, name, d, depth = 0):
        self.write_open(name, depth)
        for key in d:
            self.write_dict_item(key, d[key], depth + 1)
        self.write_close(depth)

class Evaluator:
    def __init__(self, appid):
        self.appid = appid
        self.foreignInstallItems = []

    def addForeignInstallItem(self, foreignInstallItem):
        foreignInstallItem.setAppId(self.appid)
        self.foreignInstallItems.append(foreignInstallItem)

    def getFilename(self):
        return "evaluatorscript_{}.vdf".format(self.appid)

    def writeTo(self, f):
        f.write_dict("evaluatorscript", {k: v for k, v in enumerate(self.foreignInstallItems)})

class ForeignInstallItem:
    def __init__(self, installItem, installPath):
        self.installItem = installItem
        self.installPath = installPath

    def setAppId(self, appId):
        self.appId = appId

    def writeTo(self, f, name, depth):
        f.write_open(name, depth)
        f.write_string("appid", self.appId, depth+1)
        self.installItem.writeTo(f, depth+1)
        f.write_string("foreign_install_path", self.installPath, depth+1)
        f.write_close(depth)

class InstallItem:
    def __init__(self, compat_installscript, commonredist = "0", language = "english", SteamID = "76561197989398569", uninstall = "0"):
        self.language = language
        self.commonredist = commonredist
        self.SteamID = SteamID
        self.uninstall = uninstall
        self.compat_installscript = compat_installscript

    def writeTo(self, f, depth):
        values = {k: v for k, v in vars(self).items() if k != "compat_installscript"}
        for key in values:
            f.write_dict_item(key, values[key], depth)
        f.write_dict("compat_installscript", { "run process": {v.name: v for v in self.compat_installscript } }, depth )

class Process:
    def __init__(self, name, hasrunkey, processString, requirement_os=None, nocleanup = "1"):
        self.name = name
        self.hasrunkey = hasrunkey
        self.processString = processString
        self.nocleanup = nocleanup
        self.requirement_os = requirement_os

    def writeTo(self, f, name, depth):
        values = {k.replace("processString", "process 1"): v for k, v in vars(self).items() if k not in "name" }
        f.write_dict(name, values, depth)

def winepath(path):
    scriptdir = os.path.dirname(os.path.realpath(__file__))
    wine_path = scriptdir + "/dist/bin/wine64"
    return subprocess.check_output([wine_path, "winepath", "-w", path], env = { "WINEPREFIX": scriptdir + "/dist/share/default_pfx", "WINEDEBUG": "-all" }).decode("ascii").rstrip("\n")

vcrun2015x86 = Process("x86 Update 3 14.0.24215.0", "HKEY_LOCAL_MACHINE\\Software\\Valve\\Steam\\Apps\\CommonRedist\\vcredist\\2015", "%INSTALLDIR%\\Microsoft Visual C++ 2015 x86.cmd")
vcrun2015x64 = Process("x64 Update 3 14.0.24215.0", "HKEY_LOCAL_MACHINE\\Software\\Valve\\Steam\\Apps\\CommonRedist\\vcredist\\2015", "%INSTALLDIR%\\Microsoft Visual C++ 2015 x64.cmd", {"is64bitwindows":"1"})
vcrun2015 = InstallItem([vcrun2015x86, vcrun2015x64], "1")

dotnet40Process = Process("4.0", "HKEY_LOCAL_MACHINE\\Software\\Valve\\Steam\\Apps\\CommonRedist\\.NET\\4.0", "%INSTALLDIR%\\Microsoft .NET Framework 4.0.cmd")
dotnet40 = InstallItem([dotnet40Process])

def main():
    installItems = { "vcrun2015": vcrun2015, "dotnet40": dotnet40 }
    scriptdir = os.path.dirname(os.path.realpath(__file__))
    vdf = Evaluator(sys.argv[1])
    for i in range(2, len(sys.argv), 2):
        vdf.addForeignInstallItem(ForeignInstallItem(installItems[sys.argv[i]], winepath(sys.argv[i+1])))
    filepath = scriptdir + "/legacycompat/" + vdf.getFilename()
    with open(filepath, "w") as f:
        vdfFile = VDFFile(f)
        vdf.writeTo(vdfFile)
    print("Created {}. Delete this file if it causes problems or is no longer needed".format(filepath))

if __name__== "__main__":
   main()
