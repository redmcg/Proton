#!/usr/bin/env python3

# dotnet 40 https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe 65e064258f2e418816b304f646ff9e87af101e4c9552ab064bb74d281c38659f

# vcrun2015 https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x86.exe fdd1e1f0dcae2d0aa0720895eff33b927d13076e64464bb7c7e5843b7667cd14
# x64 https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe 5eea714e1f22f1875c1cb7b1738b0c0b1f02aec5ecb95f0fdb1c5171c6cd93a3

import os
import sys
import urllib.request

class DownloadFile:
    def __init__(self, url, sha1):
        self.url = url
        self.sha1 = sha1

    def getFileName(self):
        return self.url[self.url.rfind("/")+1:]

    def getFilePath(self, dest):
        return dest + "/" + self.getFileName()

    def needsCreation(self, dest):
        # TODO: also create on sha1 mismatch
        return not os.path.isfile(self.getFilePath(dest))

    def create(self, dest):
        print("Downloading: {}".format(self.getFileName()))
        urllib.request.urlretrieve (self.url, self.getFilePath(dest))
        # TODO: check sha1

class CommandFile:
    def __init__(self, name, content):
        self.name = name
        self.content = content

    def getFilePath(self, dest):
        return dest + "/" + self.name

    def needsCreation(self, dest):
        # recreate every time (saves a check)
        return True

    def create(self, dest):
        with open(self.getFilePath(dest), "w") as f:
            f.write(self.content)

class Package:
    def __init__(self, fileList, dest):
        self.fileList = fileList
        self.dest = dest

    def create(self, destBase):
        destpath = destBase + "/" + self.dest
        if not os.path.exists(destpath):
            os.makedirs(destpath)
        for packageFile in self.fileList:
            if packageFile.needsCreation(destpath):
                packageFile.create(destpath)


dotnet40 = Package([DownloadFile('https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe', '65e064258f2e418816b304f646ff9e87af101e4c9552ab064bb74d281c38659f'), CommandFile('Microsoft .NET Framework 4.0.cmd', '''@ECHO OFF
start /w "" "%~dp0\dotNetFx40_Full_x86_x64.exe" /q /norestart
IF %ERRORLEVEL% == 3010 EXIT /B 0
EXIT /B %ERRORLEVEL%
''')], "DotNet/4.0")
vcrun2015 = Package([DownloadFile('https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x86.exe', 'fdd1e1f0dcae2d0aa0720895eff33b927d13076e64464bb7c7e5843b7667cd14'), DownloadFile('https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe', '5eea714e1f22f1875c1cb7b1738b0c0b1f02aec5ecb95f0fdb1c5171c6cd93a3'), CommandFile('Microsoft Visual C++ 2015 x86.cmd', '''@ECHO OFF
start /w "" "%~dp0\\vc_redist.x86.exe" /q /norestart
IF %ERRORLEVEL% == 3010 EXIT /B 0
EXIT /B %ERRORLEVEL%
'''), CommandFile('Microsoft Visual C++ 2015 x64.cmd', '''@ECHO OFF
start /w "" "%~dp0\\vc_redist.x64.exe" /q /norestart
IF %ERRORLEVEL% == 3010 EXIT /B 0
EXIT /B %ERRORLEVEL%
''')], "vcredist/2015")
packages = { "dotnet40": dotnet40, "vcrun2015": vcrun2015 }

def main():
    scriptdir = os.path.dirname(os.path.realpath(__file__))
    steambase = scriptdir + "/../.."
    packageBase = steambase + "/steam/steamapps/common/Steamworks Shared/_CommonRedist"
    for package in sys.argv[1:]:
        packages[package].create(packageBase)

if __name__ == "__main__":
    main()
