# Welcome to WatchDuck!
WatchDuck is a lightweight, cross-platform web service monitor written entirely in Swift. 
Host your very own auto-updating static status API and with a beautifully designed, customizable status page! 
Having designed with efficiency in mind, WatchDuck does not rely on a database and can be configured with a single YAML file.
Unlike many other status monitors, it provides a comprehensive set of features while being optimized for resource-constrained systems!

WatchDuck is still in an Alpha version, under active development. I welcome any feedback and contributions! Please see the [Contributing](#contributing) section for a set of basic guidelines.

## 🐣 Building and Installation
In the future, WatchDuck will come with an installation script. It will also be available as a prebuilt package. For now, users need to compile it from source and install the binaries manually.

### Compatibility
WatchDuck was designed to be compatible with **macOS and Linux systems that support Swift 6.0**.

Though it was designed to prevent reporting false-positives outages during a disconnect, a reliable network connection is undoubtedly essential for WatchDuck to provide reliable data!

WatchDuck is currently being developed and tested mainly using Swift 6.0.3 on macOS 15.3 / Ubuntu 24.04 LTS.

### Build
1) Make sure you have Swift 6.0 or later installed and added to your system's PATH. For instructions and the latest releases, [see this page on the Swift website](https://www.swift.org/install/).

2) Clone this repository to build the `main` branch and enter the directory.
    **Clone via HTTPS:**
    ```
    git clone https://github.com/BertanT/WatchDuck.git
    cd WatchDuck
    ```
    If the shield badge at the top of this document is indicating that the `main` build is failing, you can also [download the source code of the latest release here](https://github.com/BertanT/WatchDuck/releases/latest/).

3) Build the package! If you are building for development, build for debug. If you are an end-user of WatchDuck, build for release to incorporate all the optimizations.
    
    **Build for debug:**
    ```
    swift build
    ```
    **Build for release:**
    ```
    swift build -c release
    ```

### Install
4) Copy the executable you just built to your local binary path.

    **If you built for debug, copy the debug executable:**
    ```
    sudo cp .build/debug/watchduck /usr/local/bin/
    ```
    **If you built for release, copy the release executable:**
    ```
    sudo cp .build/release/watchduck /usr/local/bin/
    ```

5) If you are on macOS, you will also need to copy your bundle!

    **If you built for debug:**
    ```
    sudo cp .build/debug/*.bundle /usr/local/bin/
    ```
    **If you built for release:**
    ```
    sudo cp .build/release/*.bundle /usr/local/bin/
    ```

You can now return to your home directory by executing `cd`.

### Set Up as a System Service
Following this step will allow WatchDuck to refresh itself on the background at regular intervals. It will also launch on system startup and will try to always keep itself running by automatically re-launching in case of a runtime error (i.e. systemd `Restart=always` / launchd `KeepAlive` true).

Execute the following command and follow the on-screen instructions. A default configuration file will be created for WatchDuck at the specified location.
```
sudo watchduck service-install
```

## 📕 Documentation
A detailed collection of code documentation and an end-user's manual is underway in Apple DocC format and will be hosted online. Users will also be able to build it themselves using Xcode. For now, here are some key things you should know about WatchDuck.

**Disclaimer:** When using WatchDuck to check any website(s), it is your responsibility to ensure that doing so does not break their terms of use. You may also be subject to rate-limiting. We do not endorse that WatchDuck is fit to check any specific website(s), and should not be used for mission-critical purposes. Under AGPL v3, this program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

At this time, this section assumes that you set up WatchDuck as a system service.

* A single YAML configuration file is used to set up all of WatchDuck. When you run `sudo watchduck service-install`, a default configuration file with a single web service check will be created for you and its location will be printed along the on-screen instructions. Please read these instructions carefully. They also contain OS-specific information on how to disable or re-enable WatchDuck's background process should you need to.

* The said default configuration file contains detailed information about each of the customization options and on how to add your own web service checks, all laid out as inline comments. Each customization option is explicitly included in the file, with any options that use the default value commented out. Please make sure to read all of them carefully to start checking your own websites!

* When you are running WatchDuck as a system service and make any changes to the configuration file, you need to disable and re-enable WatchDuck for the changes to take effect. You may also choose to simply reboot your computer.

* WatchDuck always generates logs in the form of a JSON file. These logs can be hosted as a static API using a web server. Since WatchDuck does not use a traditional database to keep things light-weight, this is the only record of outages. As WatchDuck always refers to the data here whenever it runs, **you should never edit the contents of this file!**

* Enabled by default, WatchDuck generates a static HTML webpage that shows the current statuses and historical outage data for each of your web services. Along with the static HTML is a stylesheet and a series of images. By default, these assets are created if they don't already exist, but are never overwritten. This means that you are completely free to customize the contents of the CSS and images to your liking, and WatchDuck will not overwrite them! Further website customization options are also available in the configuration file.

* The JSON output path is a specific file path with a file name that can be customized. The HTML output path is a directory path and the filenames of its contents *cannot* be customized. The default locations of both are defined in the default configuration file. As WatchDuck runs as the root user on the background, make sure that any customized output paths have read and write permissions for root.

* When serving the WatchDuck API (JSON logs) and the webpage, ensure that you have a strict Content Security Policy and other security headers set up properly on your web server (e.g. NGINX) to help minimize the risk of XSS attacks. [Here is a helpful resource from MDN if you want to learn more!](https://developer.mozilla.org/en-US/docs/Web/Security/Attacks/XSS#deploying_a_csp)

* When you remove a web service check from the configuration file, all historic logs for that website will be automatically and irrecoverably deleted on the next run of WatchDuck.

If you run into a bug, please report it as an [Issue](https://github.com/BertanT/WatchDuck/issues) if it hasn't been reported there already. If you have any questions on how to use WatchDuck, you can contact me by creating a new [Discussion](https://github.com/BertanT/WatchDuck/discussions).

## ⚡️ Contributing
I welcome all contributions that help make WatchDuck better! If you are making a pull request that involves code (such as a bug fix or a feature addition), please follow the guidelines below. In all interactions, remember to treat others with kindness and respect, also making sure you follow all of GitHub's terms and guidelines!

### Bug Fixes
Whether you are providing a fix for a known bug or one you just discovered, you should always incorporate the [Issues](https://github.com/BertanT/WatchDuck/issues) page. If there is already an Issue created for the bug you are working on, please link your pull request to that issue. If such issue does not exist yet, please create a new one first. [Here is a helpful resource from GitHub on how to link pull requests to issues.](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue)

### How to Credit Yourself
WatchDuck is licensed under the GNU Affero Public License Version 3 (AGPL v3). In order to credit your work properly according to the license conventions, please make sure to:

* Append to the end of the copyright notices with your name and the current year when you change the contents of an existing file.

* Copy and paste an existing license notice header from another file, change the indicated file name and the creation date, and only add your own copyright notice when you create a new file.

For detailed information on file header formatting, [here is a helpful resource from the GNU website.](https://www.gnu.org/licenses/gpl-howto.html)

Additionally, please add your name to the [Code Contributors](#code-contributors) section in this file as a bullet point. You may link it to your GitHub profile.

## ❤️ Credits
Created with love and passion by Mehmet Bertan Tarakçıoğlu.

### Code Contributors
Nobody else here! Please see the [Contributing](#contributing) section to help make WatchDuck better :)

### Logo Design
The cute little duck watching over all of your web services, drawn by Anday Gün Derya ❤️ ([LinkedIn](https://www.linkedin.com/in/anday-gün-derya-35062a2b2/)).

Copyright (C) 2025 Anday Gün Derya.

## 📜 License
WatchDuck is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License 
as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

WatchDuck is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with WatchDuck.
If not, see <https://www.gnu.org/licenses/>.

###### Copyright (C) 2025 Mehmet Bertan Tarakçıoğlu, under the AGPL v3.
