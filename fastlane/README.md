fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools/fastlane.zip">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>
# Available Actions
## iOS
### ios xcode_plugin
```
fastlane ios xcode_plugin
```
Installs XCode plugin to disable fix it!
### ios match_dev
```
fastlane ios match_dev
```
Installs all required provisionin profiles and certificates
### ios match_prod
```
fastlane ios match_prod
```
Installs all required provisionin profiles and certificates
### ios add_device
```
fastlane ios add_device
```

### ios refresh_profiles
```
fastlane ios refresh_profiles
```

### ios test
```
fastlane ios test
```
Runs all the tests
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios build
```
fastlane ios build
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios deliver_beta
```
fastlane ios deliver_beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios build_appstore
```
fastlane ios build_appstore
```
Deploy a new version to the App Store
### ios deliver_appstore
```
fastlane ios deliver_appstore
```
Deploy a new version to the App Store
### ios new_version_appstore
```
fastlane ios new_version_appstore
```
Build & Deploy a new version to the App Store
### ios set_version
```
fastlane ios set_version
```
Increase Version Number
### ios refresh_dsyms
```
fastlane ios refresh_dsyms
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
