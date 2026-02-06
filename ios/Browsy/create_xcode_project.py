#!/usr/bin/env python3
"""
Generate Xcode project file for Browsy iOS app.

This script creates a proper .xcodeproj directory with project.pbxproj file
containing all the migrated Swift files organized by folders.
"""

import os
import uuid
from pathlib import Path

def generate_uuid():
    """Generate a 24-character hex UUID for Xcode objects."""
    return uuid.uuid4().hex[:24].upper()

def find_swift_files(base_path):
    """Find all Swift files recursively and organize by directory."""
    swift_files = {}
    base = Path(base_path)

    for swift_file in sorted(base.rglob("*.swift")):
        rel_path = swift_file.relative_to(base)
        folder = str(rel_path.parent) if rel_path.parent != Path('.') else ""

        if folder not in swift_files:
            swift_files[folder] = []
        swift_files[folder].append(str(rel_path.name))

    return swift_files

def create_pbxproj(swift_files_by_folder):
    """Create the project.pbxproj content."""

    # Generate UUIDs for project structure
    project_uuid = generate_uuid()
    main_group_uuid = generate_uuid()
    products_group_uuid = generate_uuid()
    source_group_uuid = generate_uuid()
    target_uuid = generate_uuid()
    app_product_uuid = generate_uuid()
    sources_phase_uuid = generate_uuid()
    frameworks_phase_uuid = generate_uuid()
    resources_phase_uuid = generate_uuid()
    debug_config_uuid = generate_uuid()
    release_config_uuid = generate_uuid()
    project_config_list_uuid = generate_uuid()
    target_config_list_uuid = generate_uuid()
    debug_target_config_uuid = generate_uuid()
    release_target_config_uuid = generate_uuid()

    # Generate UUIDs for files and groups
    file_uuids = {}
    build_file_uuids = {}
    group_uuids = {}

    all_files = []
    for folder, files in swift_files_by_folder.items():
        for file in files:
            file_path = os.path.join(folder, file) if folder else file
            file_uuids[file_path] = generate_uuid()
            build_file_uuids[file_path] = generate_uuid()
            all_files.append(file_path)

    for folder in swift_files_by_folder.keys():
        if folder:  # Don't create UUID for root
            group_uuids[folder] = generate_uuid()

    # Start building the pbxproj content
    pbxproj = """// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
"""

    # Add build files
    for file_path in all_files:
        filename = os.path.basename(file_path)
        pbxproj += f"\t\t{build_file_uuids[file_path]} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuids[file_path]} /* {filename} */; }};\n"

    pbxproj += """/* End PBXBuildFile section */

/* Begin PBXFileReference section */
"""

    # Add file references
    pbxproj += f"\t\t{app_product_uuid} /* Browsy.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Browsy.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"

    for file_path in all_files:
        filename = os.path.basename(file_path)
        pbxproj += f"\t\t{file_uuids[file_path]} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};\n"

    pbxproj += """/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
"""

    pbxproj += f"""\t\t{frameworks_phase_uuid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
"""

    # Main group
    pbxproj += f"""\t\t{main_group_uuid} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{source_group_uuid} /* Browsy */,
\t\t\t\t{products_group_uuid} /* Products */,
\t\t\t);
\t\t\tsourceTree = \"<group>\";
\t\t}};
"""

    # Products group
    pbxproj += f"""\t\t{products_group_uuid} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_product_uuid} /* Browsy.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = \"<group>\";
\t\t}};
"""

    # Source group - organize by folders
    pbxproj += f"""\t\t{source_group_uuid} /* Browsy */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
"""

    # Add folders first
    for folder in sorted(swift_files_by_folder.keys()):
        if folder:
            folder_name = os.path.basename(folder) if '/' in folder else folder
            pbxproj += f"\t\t\t\t{group_uuids[folder]} /* {folder_name} */,\n"

    # Add root-level files
    if "" in swift_files_by_folder:
        for file in swift_files_by_folder[""]:
            file_path = file
            pbxproj += f"\t\t\t\t{file_uuids[file_path]} /* {file} */,\n"

    pbxproj += """\t\t\t);
\t\t\tpath = Browsy;
\t\t\tsourceTree = \"<group>\";
\t\t}};
"""

    # Add subfolder groups
    for folder in sorted(swift_files_by_folder.keys()):
        if not folder:
            continue

        folder_name = os.path.basename(folder) if '/' in folder else folder
        pbxproj += f"""\t\t{group_uuids[folder]} /* {folder_name} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
"""

        for file in swift_files_by_folder[folder]:
            file_path = os.path.join(folder, file)
            pbxproj += f"\t\t\t\t{file_uuids[file_path]} /* {file} */,\n"

        pbxproj += f"""\t\t\t);
\t\t\tpath = {folder_name};
\t\t\tsourceTree = \"<group>\";
\t\t}};
"""

    pbxproj += """/* End PBXGroup section */

/* Begin PBXNativeTarget section */
"""

    pbxproj += f"""\t\t{target_uuid} /* Browsy */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {target_config_list_uuid} /* Build configuration list for PBXNativeTarget "Browsy" */;
\t\t\tbuildPhases = (
\t\t\t\t{sources_phase_uuid} /* Sources */,
\t\t\t\t{frameworks_phase_uuid} /* Frameworks */,
\t\t\t\t{resources_phase_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = Browsy;
\t\t\tproductName = Browsy;
\t\t\tproductReference = {app_product_uuid} /* Browsy.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
"""

    pbxproj += f"""\t\t{project_uuid} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{target_uuid} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {project_config_list_uuid} /* Build configuration list for PBXProject "Browsy" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {main_group_uuid};
\t\t\tproductRefGroup = {products_group_uuid} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_uuid} /* Browsy */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
"""

    pbxproj += f"""\t\t{resources_phase_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
"""

    pbxproj += f"""\t\t{sources_phase_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
"""

    for file_path in all_files:
        filename = os.path.basename(file_path)
        pbxproj += f"\t\t\t\t{build_file_uuids[file_path]} /* {filename} in Sources */,\n"

    pbxproj += """\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
"""

    # Debug configuration
    pbxproj += f"""\t\t{debug_config_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
"""

    # Release configuration
    pbxproj += f"""\t\t{release_config_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
"""

    # Target configurations
    pbxproj += f"""\t\t{debug_target_config_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbaseConfigurationReference = Config/Debug.xcconfig;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tINFOPLIST_FILE = "";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.browsy.ios;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSUPPORTS_MACCATALYST = NO;
\t\t\t\tSUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;
\t\t\t\tSUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD = NO;
\t\t\t\tSWIFT_VERSION = 5.9;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{release_target_config_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbaseConfigurationReference = Config/Release.xcconfig;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tINFOPLIST_FILE = "";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.browsy.ios;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSUPPORTS_MACCATALYST = NO;
\t\t\t\tSUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;
\t\t\t\tSUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD = NO;
\t\t\t\tSWIFT_VERSION = 5.9;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
"""

    pbxproj += f"""\t\t{project_config_list_uuid} /* Build configuration list for PBXProject "Browsy" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_config_uuid} /* Debug */,
\t\t\t\t{release_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{target_config_list_uuid} /* Build configuration list for PBXNativeTarget "Browsy" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_target_config_uuid} /* Debug */,
\t\t\t\t{release_target_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {project_uuid} /* Project object */;
}}
"""

    return pbxproj

def main():
    script_dir = Path(__file__).parent
    browsy_dir = script_dir / "Browsy"

    print("🔍 Finding Swift files...")
    swift_files = find_swift_files(browsy_dir)

    total_files = sum(len(files) for files in swift_files.values())
    print(f"✅ Found {total_files} Swift files in {len(swift_files)} folders")

    print("\n📁 File organization:")
    for folder, files in sorted(swift_files.items()):
        folder_name = folder if folder else "(root)"
        print(f"  {folder_name}: {len(files)} files")

    print("\n🔨 Generating project.pbxproj...")
    pbxproj_content = create_pbxproj(swift_files)

    # Create .xcodeproj directory
    xcodeproj_dir = script_dir / "Browsy.xcodeproj"
    xcodeproj_dir.mkdir(exist_ok=True)

    # Write project.pbxproj
    pbxproj_file = xcodeproj_dir / "project.pbxproj"
    with open(pbxproj_file, 'w') as f:
        f.write(pbxproj_content)

    print(f"✅ Created {pbxproj_file}")
    print("\n🎉 Xcode project created successfully!")
    print(f"\nProject location: {xcodeproj_dir}")
    print("\nNext steps:")
    print("1. Open Browsy.xcodeproj in Xcode on macOS")
    print("2. Configure API key in Config/Debug.xcconfig")
    print("3. Build and run the project")

if __name__ == "__main__":
    main()
