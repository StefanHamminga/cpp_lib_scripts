# Locate simple single C++ file tests in `./test/` and combine them in a
# `make check` target.

if (EXISTS "${CMAKE_SOURCE_DIR}/test")
    enable_testing()
    # Find tests
    execute_process (
        COMMAND find -L "${CMAKE_SOURCE_DIR}/test/" -mindepth 1 -maxdepth 1 -type f -regex ".*\\.\\(c\\|cpp\\|cxx|c\\+\\+\\)$"
        COMMAND sed -r "s|${CMAKE_SOURCE_DIR}/test/||"
        COMMAND sort
        COMMAND uniq
        COMMAND tr '\n' '\;'
        OUTPUT_VARIABLE TEST_SOURCES
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    message(STATUS "Tests: \n${TEST_SOURCES}")

    set (TEST_LIST)
    foreach (TEST_SOURCE IN LISTS TEST_SOURCES)
        if (NOT "_" STREQUAL "_${TEST_SOURCE}" AND EXISTS "${CMAKE_SOURCE_DIR}/test/${TEST_SOURCE}")
            string(REGEX REPLACE "\\.[^.]+$" "" TEST_NAME "${TEST_SOURCE}")
            message(STATUS "Adding test ${TEST_NAME}")
            add_executable(test_${TEST_NAME} "${CMAKE_SOURCE_DIR}/test/${TEST_SOURCE}")

            # Set any test compilation options here
            target_compile_options(test_${TEST_NAME} PRIVATE "-std=gnu++17;-Wfatal-errors")

            add_test(${TEST_NAME} "test_${TEST_NAME}")
            list (APPEND TEST_LIST test_${TEST_NAME})
        endif()
    endforeach ()

    add_custom_target(check
        COMMAND ${CMAKE_CTEST_COMMAND} --verbose
        DEPENDS ${TEST_LIST}
    )
endif()
