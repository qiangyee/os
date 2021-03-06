/*++

Copyright (c) 2013 Minoca Corp.

    This file is licensed under the terms of the GNU General Public License
    version 3. Alternative licensing terms are available. Contact
    info@minocacorp.com for details. See the LICENSE file at the root of this
    project for complete licensing information.

Module Name:

    TzComp

Abstract:

    This tool compiles textual time zone data into a binary format.

Author:

    Evan Green 2-Aug-2013

Environment:

    Test

--*/

from menv import application, binplace, group;

function build() {
    var almanac;
    var buildApp;
    var entries;
    var sources;
    var tzcompTool;
    var tzCutoffYear = "1980";
    var tzDataDir = "data/";
    var tzDataFiles;
    var tzDefault = "America/Los_Angeles";
    var tzDefaultConfig;
    var tzDefaultData;
    var tzFiles;
    var tzSourceFiles;

    sources = [
        "tzcomp.c",
    ];

    tzSourceFiles = [
        "africa",
        "antarctica",
        "asia",
        "australasia",
        "etcetera",
        "europe",
        "leapseconds",
        "northamerica",
        "southamerica"
    ];

    tzFiles = [];
    for (file in tzSourceFiles) {
        tzFiles += [tzDataDir + file];
    }

    buildApp = {
        "label": "build_tzcomp",
        "output": "tzcomp",
        "inputs": sources,
        "build": true
    };

    entries = application(buildApp);

    //
    // Add the tzcomp tool.
    //

    tzcompTool = {
        "type": "tool",
        "name": "tzcomp",
        "command": "$O/apps/tzcomp/tzcomp $TZCOMP_FLAGS -o $OUT $IN",
        "description": "Compiling Time Zone Data - $OUT"
    };

    entries += [tzcompTool];

    //
    // Add entries for the time zone almanac and time zone default.
    //

    almanac = {
        "type": "target",
        "label": "tzdata",
        "inputs": tzFiles,
        "implicit": [":build_tzcomp"],
        "tool": "tzcomp",
        "nostrip": true,
    };

    tzDefaultConfig = {
        "TZCOMP_FLAGS": ["-z " + tzDefault, "-y" + tzCutoffYear]
    };

    tzDefaultData = {
        "type": "target",
        "label": "tzdflt",
        "inputs": tzFiles,
        "implicit": [":build_tzcomp"],
        "tool": "tzcomp",
        "config": tzDefaultConfig,
        "nostrip": true
    };

    entries += binplace(almanac);
    entries += binplace(tzDefaultData);

    //
    // Create a group for the data files.
    //

    tzDataFiles = [":tzdata", ":tzdflt"];
    entries += group("tz_files", tzDataFiles);
    return entries;
}

