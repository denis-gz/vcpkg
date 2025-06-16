if(VCPKG_TARGET_IS_WINDOWS)
    # Building python bindings is currently broken on Windows
    if("python" IN_LIST FEATURES)
        message(FATAL_ERROR "The python feature is currently broken on Windows")
    endif()
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(_static_runtime ON)
    endif()
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        deprfun     deprecated-functions
        examples    build_examples
        python      python-bindings
        test        build_tests
        tools       build_tools
)

# Note: the python feature currently requires `python3-dev` and `python3-setuptools` installed on the system
if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
    vcpkg_add_to_path(${PYTHON3_PATH})

    file(GLOB BOOST_PYTHON_LIB "${CURRENT_INSTALLED_DIR}/lib/*boost_python*")
    string(REGEX REPLACE ".*(python)([0-9])([0-9]+).*" "\\1\\2\\3" _boost-python-module-name "${BOOST_PYTHON_LIB}")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arvidn/libtorrent
    REF ef64db357de11dc8a53f9e95d7685f545619211b # v2.0.11-ef64db35
    SHA512 c22b514b233454a1934b830bb5eea1ba7992699651aedeed6204777d515cc5dec5d2895569cec4210be473c3a5a0ee8941771fdeff50381e1d920020c1a05f32
    HEAD_REF RC_2_0
    PATCHES
		windows.patch
)

vcpkg_from_github(
        OUT_SOURCE_PATH TRYSIGNAL_SOURCE_PATH
        REPO arvidn/try_signal
        REF 105cce59972f925a33aa6b1c3109e4cd3caf583d #2022-10-27
        SHA512 4a0090755831e0e4a1930817345fa5934144421d9a9d710fe8ed3712233fa2fa037fc0e0d4f88b7cc8fb1bc05fe2d55372af1ff47d6fbf5208e03f45f2a424e4
        HEAD_REF master
)

vcpkg_from_github(
        OUT_SOURCE_PATH ASIO_GNUTLS_SOURCE_PATH
        REPO paullouisageneau/boost-asio-gnutls
        REF a57d4d36923c5fafa9698e14be16b8bc2913700a
        SHA512 1e093dd4e999cce9c6d74f1d4c2d20f73512258b83505c307c7d53b8c7ed15626a8e90c8e6a6280827aafa069bc233c0c6f4c9276f1c332e4b141c7c350c47c0
        HEAD_REF master
)

vcpkg_from_github(
        OUT_SOURCE_PATH LIB_SIMULATOR_SOURCE_PATH
        REPO arvidn/libsimulator
        REF 39144efe83fcd38778cf76fc609e3475694642ca #2022-10-27
        SHA512 a021f769d52d127355ecaceaf912bf3e86aaa256d4768d270fbe6066793b6159eddecd0262f3f2158602f883d49b3aac39eb79be5399212cdd7711f921ffa15a
        HEAD_REF master
)

file(COPY ${TRYSIGNAL_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/deps/try_signal)
file(COPY ${ASIO_GNUTLS_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/deps/asio-gnutls)
file(COPY ${LIB_SIMULATOR_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/simulation/libsimulator)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dboost-python-module-name=${_boost-python-module-name}
        -Dstatic_runtime=${_static_runtime}
        -DPython3_USE_STATIC_LIBS=ON
    MAYBE_UNUSED_VARIABLES
        boost-python-module-name
        Python3_USE_STATIC_LIBS
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/LibtorrentRasterbar TARGET_PATH share/LibtorrentRasterbar)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Do not duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
